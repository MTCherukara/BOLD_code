function [storedProtonPhase p]=simplebloodsim(p)

	if nargin<1
		storedProtonPhase=[];
		p=[];
		return;
	end
	
	%only a single radius, haematocrit and oxygen sat allowed
	if (length(p.Hct).*length(p.Y).*length(p.R))>1
		storedProtonPhase=[];
		p=[];
		return;
	end
	
	t(1)=now;
	
	%set up random number generator
	if ~isfield(p,'seed')
		fid=fopen('/dev/urandom');
		p.seed=fread(fid, 1, 'uint32');
	end
	rng(p.seed); %use a random seed to avoid problems when running on a cluster
	
	%define parameters for simulation
	p.HD = 10; %factor for higher density sampling near vessels
	p.stdDev = sqrt(2*p.D*p.dt/p.HD);
	p.universeSize=p.universeScale*min(p.R);
	p.numSteps=round((p.TE*2)/p.dt);
	p.ptsPerdt=round(p.deltaTE./p.dt); %pts per deltaTE

	for k=1:p.N
	
		%tp(1,k)=now;
	
		%set up universe
		[rbcOrigins, protonPosit, numRBCs(k), rbcVolFrac(k)] = setupUniverse(p);

		%tp(2,k)=now;
	
		%generate random walk path
		[protonPosits] = randomWalk(p,protonPosit);

		%tp(3,k)=now;
	
		%calculate field at each point
		[fieldAtProtonPosit numStepsInRBC(k) numCloseApproaches(k)]=calculateField(p, protonPosits, rbcOrigins, numRBCs(k));
	
		%tp(4,k)=now;
	
		%calculate phase at each point
		storedProtonPhase(:,k)=sum(reshape(fieldAtProtonPosit,p.ptsPerdt,p.numSteps/p.ptsPerdt).*p.gamma.*p.dt,1)';

		%tp(5,k)=now;
	
	end
	
	%record useful values
	p.numRBCs=numRBCs;
	p.rbcVolFrac=rbcVolFrac;
	%p.numStepsInVessel=numStepsInVessel;
	%p.numCloseApproaches=numCloseApproaches;
	%p.stepInLargeVessel=stepInLargeVessel;
	
	%p.timeProfiling=tp;
	
	t(2)=now;
	p.totalSimDuration=diff(t).*24*60*60;

	%keyboard;

return;

% Set up the universe of spherical blood cells
function [rbcOrigins, protonPosit, numRBCs, rbcVolFrac] = setupUniverse(p)

    volUniverse = (4/3)*pi*p.universeSize^3;
    M=100000; %max number of red blood cells
       
    %distribute some red blood cell origins within sphere
    randomNormals=randn(M,3);
    randomNormals=randomNormals./repmat(sqrt(sum(randomNormals.^2,2)),1,3);
    r=repmat(p.universeSize.*rand(M,1).^(1/3),1,3);
    rbcOrigins=r.*randomNormals;
       
    %find red blood cell number cutoff for desired volume fractions
    volSum=(cumsum(1:M).*4./3.*pi.*p.R.^3);
	cutOff=find(volSum<(volUniverse.*p.Hct),1,'last');
    
    if cutOff==M
    	disp('Error: Increase max vessels!');
    end
    
    rbcOrigins=rbcOrigins(1:cutOff,:);
	rbcVolFrac = volSum(cutOff)/volUniverse;
    numRBCs = cutOff;
    
    protonPosit=[0 0 0];
        
    %keyboard;
    
return;

%random walk
function [protonPosits] = randomWalk(p,protonPosit);

	protonPosits=p.stdDev.*randn(p.numSteps*p.HD,3);
	protonPosits(1,:)=protonPosit;
	protonPosits=cumsum(protonPosits);
	%protonPosits=protonPosits(1:p.HD:end,:);
	
return;

%calculate magnetic field at proton location
function [totalField numStepsInRBC numCloseApproaches] = calculateField(p, protonPosits, rbcOrigins, numRBCs)
	
	%store original values for later use
	protonPositsHD=protonPosits;
	rbcOriginsHD=rbcOrigins;
	
	protonPosits=protonPosits(1:p.HD:end,:);
	protonPosits=repmat(permute(protonPosits,[3 2 1]),numRBCs,1,1);
	rbcOrigins=repmat(rbcOrigins,1,1,p.numSteps);
	
	relPosits=protonPosits-rbcOrigins;
	
	%perpendicular distance from proton to red blood cell
	r=squeeze(sqrt(sum(relPosits.^2,2)));
	
	%elevation angle between red blood cell and the z-axis 
	theta=squeeze(acos(dot(relPosits,repmat([0 0 1],numRBCs,1,p.numSteps),2)));
	
	%calculate fields when proton is outside or inside a red blood cell
	fields_extra=p.B0.*(4.*pi./3).*(p.deltaChi0.*(1-p.Y)).*(p.R./r).*(3.*(cos(theta).^2)-1);
	fields_intra=zeros(size(fields_extra));

	%combine fields based on whether proton is inside/outside the vessel
	mask=r<repmat(p.R,numRBCs,p.numSteps);
	fields=fields_extra.*(~mask)+fields_intra.*mask;
	
	%CONSIDER CLEARING NO LONGER NEEDED VARIABLES HERE

	%START HD
	%find red blood cells within R^/r<0.04 of the proton
	rbcsHD=find(sum(r<sqrt(repmat(p.R,numRBCs,p.numSteps)./0.04),2)>0);
	numRBCsHD=length(rbcsHD);
	
	if and(numRBCsHD>0,p.HD>1)
	
		protonPositsHD=repmat(permute(protonPositsHD,[3 2 1]),numRBCsHD,1,1);
		rbcOriginsHD=repmat(rbcOriginsHD(rbcsHD,:),1,1,p.numSteps*p.HD);
		
		relPositsHD=protonPositsHD-rbcOriginsHD;
	
		%perpendicular distance from proton to red blood cell
		rHD=permute(sqrt(sum(relPositsHD.^2,2)),[1 3 2]);

		%elevation angle between red blood cell and the z-axis
		thetaHD=permute(acos(dot(relPositsHD,repmat([0 0 1],numRBCsHD,1,p.numSteps*p.HD),2)),[1 3 2]);

		%calculate fields when proton is outside or inside a red blood cell
		fields_extraHD=p.B0.*(4.*pi./3).*(p.deltaChi0.*(1-p.Y)).*(p.R./rHD).*(3.*(cos(thetaHD).^2)-1);
		fields_intraHD=zeros(size(fields_extraHD));

		%combine fields based on whether proton is inside/outside the vessel
		maskHD=rHD<repmat(p.R,numRBCsHD,p.numSteps*p.HD);
		fieldsHD=fields_extraHD.*(~maskHD)+fields_intraHD.*maskHD;

		%downsample to standard time step
		fields(rbcsHD,:)=permute(mean(reshape(fieldsHD,numRBCsHD,p.HD,p.numSteps),2),[1 3 2]);
	
	end

	%record number of close approaches to vessels
	numCloseApproaches=numRBCsHD;

	%END HD
		
	%sum fields over all red blood cells
	totalField= p.B0 + sum(fields,1);

	%record how long the proton spent inside vessels
	numStepsInRBC=sum(sum(mask));
    
    %keyboard;
return;




