function [storedProtonPhase p]=simplevesselsim(p)
	
	if nargin<1
		storedProtonPhase=[];
		p=[];
		return;
	end
	
	%make sure that each p.R has a corresponding p.vesselFraction, p.Hct, p.Y
	if (length(p.R)*length(p.vesselFraction)*length(p.Hct)*length(p.Y))~=length(p.R)^4
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
		[vesselOrigins, vesselNormals, R, deltaChi, protonPosit, numVessels(k), vesselVolFrac(k)] = setupUniverse(p);

		%tp(2,k)=now;
	
		%generate random walk path
		[protonPosits] = randomWalk(p,protonPosit);

		%tp(3,k)=now;
	
		%calculate field at each point
		[fieldAtProtonPosit numStepsInVessel(k) numCloseApproaches(k) stepInLargeVessel(k)]=calculateField(p, protonPosits, vesselOrigins, vesselNormals, R, deltaChi, numVessels(k));
	
		%tp(4,k)=now;
	
		%calculate phase at each point
		storedProtonPhase(:,k)=sum(reshape(fieldAtProtonPosit,p.ptsPerdt,p.numSteps/p.ptsPerdt).*p.gamma.*p.dt,1)';

		%tp(5,k)=now;
	
	end
	
	%record useful values
	p.numVessels=numVessels;
	p.vesselVolFrac=vesselVolFrac;
	p.numStepsInVessel=numStepsInVessel;
	p.numCloseApproaches=numCloseApproaches;
	p.stepInLargeVessel=stepInLargeVessel;
	
	%p.timeProfiling=tp;
	
	t(2)=now;
	p.totalSimDuration=diff(t).*24*60*60;

	%keyboard;

return;

% Set up the universe of cylindrical vessels
function [vesselOrigins, vesselNormals, R, deltaChi, protonPosit, numVessels, vesselVolFrac] = setupUniverse(p)

    volUniverse = (4/3)*pi*p.universeSize^3;
    M=100000; %max number of vessels
    
    %uniform random distribution of vessel seed points in sphere
    %vesselOrigins=(rand(M,3)-0.5).*2.*p.universeSize;
    %withinSphere=find(sqrt(sum(vesselOrigins.^2,2))<=p.universeSize);
    %vesselOrigins=vesselOrigins(withinSphere,:);
    
    %distribute some vessel origins within sphere and some on surface (50-50)
    randomNormals=randn(M,3);
    randomNormals=randomNormals./repmat(sqrt(sum(randomNormals.^2,2)),1,3);
    r=repmat(p.universeSize.*rand(M,1).^(1/3),1,3);
    %r=repmat(p.universeSize,M,3);
    r(2:2:end,:)=repmat(p.universeSize,M/2,3); %half of vessel origins on the surface
    vesselOrigins=r.*randomNormals;
    
    %uniform random distribution of random normals (orientations)
    %vesselNormals=randn(length(withinSphere),3);
    %vesselNormals=vesselNormals./repmat(sqrt(sum(vesselNormals.^2,2)),1,3);
    %vesselNormals=repmat([0 0 1],length(withinSphere),1);

    vesselNormals=randn(M,3);
    vesselNormals=vesselNormals./repmat(sqrt(sum(vesselNormals.^2,2)),1,3);
    
    %calculate lengths of vessels in sphere
    a=sum(vesselNormals.^2,2);
    b=2*sum(vesselOrigins.*vesselNormals,2);
    c=sum(vesselOrigins.^2,2)-p.universeSize.^2;
    delta=b.*b-4*a.*c;
    u1=(-b-sqrt(delta))./2./a;
    u2=(-b+sqrt(delta))./2./a;
    p1=vesselOrigins+repmat(u1,1,3).*vesselNormals;
    p2=vesselOrigins+repmat(u2,1,3).*vesselNormals;
    l=sqrt(sum((p2-p1).^2,2));
        
    %find vessel number cutoff for desired volume fractions
    cutOff=0;
    for k=1:length(p.R)
    	R(cutOff+1:M,:)=repmat(p.R(k),length(cutOff+1:M),1);
    	deltaChi(cutOff+1:M,:)=repmat(p.deltaChi0*p.Hct(k).*(1-p.Y(k)),length(cutOff+1:M),1);
    	volSum=(cumsum(l.*pi.*R.^2));
		cutOff=find(volSum<(volUniverse.*sum(p.vesselFraction(1:k))),1,'last');
	end
    
    if cutOff==M
    	disp('Error: Increase max vessels!');
    end
    
    R=R(1:cutOff);
    deltaChi=deltaChi(1:cutOff);
    vesselOrigins=vesselOrigins(1:cutOff,:);
    vesselNormals=vesselNormals(1:cutOff,:);
	vesselVolFrac = volSum(cutOff)/volUniverse;
    numVessels = cutOff;
    
    protonPosit=[0 0 0];
    
    %figure;
    %plot3([p1(1:cutOff,1); p2(1:cutOff,1)],[p1(1:cutOff,2); p2(1:cutOff,2)],[p1(1:cutOff,3); p2(1:cutOff,3)],'-')
    
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
function [totalField numStepsInVessel numCloseApproaches stepInLargeVessel] = calculateField(p, protonPosits, vesselOrigins, vesselNormals, R, deltaChi, numVessels)
	
	%store original values for later use
	protonPositsHD=protonPosits;
	vesselOriginsHD=vesselOrigins;
	vesselNormalsHD=vesselNormals;
	
	protonPosits=protonPosits(1:p.HD:end,:);
	protonPosits=repmat(permute(protonPosits,[3 2 1]),numVessels,1,1);
	vesselOrigins=repmat(vesselOrigins,1,1,p.numSteps);
	vesselNormals=repmat(vesselNormals,1,1,p.numSteps);
	
	relPosits=protonPosits-vesselOrigins;
	
	%perpendicular distance from proton to vessel
	r=squeeze(sqrt(sum((relPosits-repmat(dot(relPosits,vesselNormals,2),1,3,1).*vesselNormals).^2,2)));

	%elevation angle between vessel and the z-axis (just do it for one time step and repmat later)
	theta=acos(dot(vesselNormals(:,:,1),repmat([0 0 1],numVessels,1,1),2));
	
	np=zeros(numVessels,3,p.numSteps);
	np=relPosits-repmat(dot(relPosits,vesselNormals,2),1,3,1).*vesselNormals;
	np=np./repmat(sqrt(sum(np.^2,2)),1,3,1);
	nb=cross(repmat([0 0 1],numVessels,1,p.numSteps),vesselNormals);
	nb=nb./repmat(sqrt(sum(nb.^2,2)),1,3,1);
	nc=cross(vesselNormals,nb);
	nc=nc./repmat(sqrt(sum(nc.^2,2)),1,3,1);

	%azimuthal angle in plane perpendicular to vessel
	phi=squeeze(acos(dot(np,nc,2)));
	
	%calculate fields when proton is outside or inside a vessel
	fields_extra=p.B0.*2.*pi.*repmat(deltaChi,1,p.numSteps).*(repmat(R,1,p.numSteps)./r).^2.*cos(2.*phi).*sin(repmat(theta,1,p.numSteps)).^2;
	fields_intra=p.B0.*2.*pi./3.*repmat(deltaChi,1,p.numSteps).*(3.*cos(repmat(theta,1,p.numSteps)).^2-1);

	%combine fields based on whether proton is inside/outside the vessel
	mask=r<repmat(R,1,p.numSteps);
	fields=fields_extra.*(~mask)+fields_intra.*mask;
	
	%CONSIDER CLEARING NO LONGER NEEDED VARIABLES HERE
		
	%START HD
	%find vessels within R^2/r^2<0.04 of the proton
	vesselsHD=find(sum(r<sqrt(repmat(R,1,p.numSteps).^2./0.04),2)>0);
	numVesselsHD=length(vesselsHD);
	
	if and(numVesselsHD>0,p.HD>1)
	
		protonPositsHD=repmat(permute(protonPositsHD,[3 2 1]),numVesselsHD,1,1);
		vesselOriginsHD=repmat(vesselOriginsHD(vesselsHD,:),1,1,p.numSteps*p.HD);
		vesselNormalsHD=repmat(vesselNormalsHD(vesselsHD,:),1,1,p.numSteps*p.HD);
		RHD=R(vesselsHD);
		deltaChiHD=deltaChi(vesselsHD);
		
		relPositsHD=protonPositsHD-vesselOriginsHD;
	
		%perpendicular distance from proton to vessel
		rHD=permute(sqrt(sum((relPositsHD-repmat(dot(relPositsHD,vesselNormalsHD,2),1,3,1).*vesselNormalsHD).^2,2)),[1 3 2]);

		%elevation angle between vessel and the z-axis (just do it for one time step and repmat later)
		thetaHD=acos(dot(vesselNormalsHD(:,:,1),repmat([0 0 1],numVesselsHD,1,1),2));
	
		npHD=zeros(numVesselsHD,3,p.numSteps*p.HD);
		npHD=relPositsHD-repmat(dot(relPositsHD,vesselNormalsHD,2),1,3,1).*vesselNormalsHD;
		npHD=npHD./repmat(sqrt(sum(npHD.^2,2)),1,3,1);
		nbHD=cross(repmat([0 0 1],numVesselsHD,1,p.numSteps*p.HD),vesselNormalsHD);
		nbHD=nbHD./repmat(sqrt(sum(nbHD.^2,2)),1,3,1);
		ncHD=cross(vesselNormalsHD,nbHD);
		ncHD=ncHD./repmat(sqrt(sum(ncHD.^2,2)),1,3,1);

		%azimuthal angle in plane perpendicular to vessel
		phiHD=permute(acos(dot(npHD,ncHD,2)),[1 3 2]);
		
		%calculate fields when proton is outside or inside a vessel
		fields_extraHD=p.B0.*2.*pi.*repmat(deltaChiHD,1,p.numSteps*p.HD).*(repmat(RHD,1,p.numSteps*p.HD)./rHD).^2.*cos(2.*phiHD).*sin(repmat(thetaHD,1,p.numSteps*p.HD)).^2;
		fields_intraHD=p.B0.*2.*pi./3.*repmat(deltaChiHD,1,p.numSteps*p.HD).*(3.*cos(repmat(thetaHD,1,p.numSteps*p.HD)).^2-1);
		
		%combine fields based on whether proton is inside/outside the vessel
		maskHD=rHD<repmat(RHD,1,p.numSteps*p.HD);
		fieldsHD=fields_extraHD.*(~maskHD)+fields_intraHD.*maskHD;

		%downsample to standard time step
		fields(vesselsHD,:)=permute(mean(reshape(fieldsHD,numVesselsHD,p.HD,p.numSteps),2),[1 3 2]);
	
	end

	%record number of close approaches to vessels
	numCloseApproaches=numVesselsHD;

	%END HD
		
	%sum fields over all vessels
	totalField= p.B0 + sum(fields,1);

	%record how long the proton spent inside vessels
	numStepsInVessel=sum(sum(mask));
	
	%record whether the proton passed into a "large" vessel (R>4mum)
	if numStepsInVessel>0
		stepInLargeVessel=max(R(find(sum(mask,2)>0)))>4e-6;
	else
		stepInLargeVessel=0;
	end

	%keyboard;
	
	%fields=p.B0.*2.*pi.*p.deltaChi.*(p.R./r).^2.*cos(2.*phi).*sin(repmat(theta,1,1,p.numSteps)).^2;
	%fields_intra=p.B0.*2.*pi./3.*p.deltaChi.*(3.*cos(repmat(theta,1,1,p.numSteps)).^2-1);
	%fields(r<p.R)=0; %really should be calculating field inside vessel
	%fields=fields

    %totalField= p.B0 + sum(fields,1);
    %totalField=squeeze(totalField);  
    
    %keyboard;
return;




