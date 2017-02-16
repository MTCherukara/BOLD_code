%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%     simplevesselsim                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [storedProtonPhase, p] = simplevesselsim(p)
	
    % make sure there is at least 1 argument (the parameter structure p)
	if nargin < 1
		storedProtonPhase = [];
		p = [];
		return;
	end
	
	% make sure that each p.R has a corresponding p.vesselFraction, p.Hct, p.Y
	if (length(p.R)*length(p.vesselFraction)*length(p.Hct)*length(p.Y)) ~= length(p.R)^4
		storedProtonPhase = [];
		p = [];
		return;
    end
	
	% set up random number generator - not necessary when running locally
% 	if ~isfield(p,'seed')
% 		fid = fopen('/dev/urandom');
% 		p.seed = fread(fid, 1, 'uint32');
% 	end
% 	rng(p.seed); % use a random seed to avoid problems when running on a cluster
	
	% define parameters for simulation
	p.HD = 10; % factor for higher density sampling near vessels
	p.stdDev = sqrt(2*p.D*p.dt/p.HD);
	p.universeSize = p.universeScale*min(p.R);
	p.numSteps = round((p.TE*2)/p.dt);
	p.ptsPerdt = round(p.deltaTE./p.dt); %pts per deltaTE
	
	for k=1:p.N         % p.N = 10000, loop through points
	
		% set up universe
		[vesselOrigins, vesselNormals, R, deltaChi, protonPosit, numVessels(k), vesselVolFrac(k)] = setupUniverse(p);
        
% 		% generate random walk path
        if p.solidWalls
            [protonPosits] = walkingReflection(p,protonPosit,vesselOrigins,vesselNormals);
        else
            [protonPosits] = randomWalk(p,protonPosit);
        end
	
		% calculate field at each point
		[fieldAtProtonPosit, numStepsInVessel(k), numCloseApproaches(k), stepInLargeVessel(k)] = calculateField(p, protonPosits, vesselOrigins, vesselNormals, R, deltaChi, numVessels(k));
	
		% calculate phase at each point
		storedProtonPhase(:,k) = sum(reshape(fieldAtProtonPosit,p.ptsPerdt,p.numSteps/p.ptsPerdt).*p.gamma.*p.dt,1)';

	end
	
	%record useful values
	p.numVessels            = numVessels;
	p.vesselVolFrac         = vesselVolFrac;
	p.numStepsInVessel      = numStepsInVessel;
	p.numCloseApproaches    = numCloseApproaches;
	p.stepInLargeVessel     = stepInLargeVessel;
	
    % timing stuff
	t(2) = now;
	p.totalSimDuration = diff(t).*24*60*60;
    
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%     setupUniverse                   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up the universe of cylindrical vessels
function [vesselOrigins, vesselNormals, R, deltaChi, protonPosit, numVessels, vesselVolFrac] = setupUniverse(p)

    volUniverse = (4/3)*pi*p.universeSize^3;  % p.universeSize = p.universeScale*min(p.R);
    M = 100000; %max number of vessels
    
    % generate some (normalized) random directions (lines from the centre
    % of the universe to the edge), then pick a random point along each
    % line and use that as the origin for each vessel (half of the vessels
    % will begin at the edge of the universe, rather than at the end).
    randomNormals = randn(M,3);
    randomNormals = randomNormals./repmat(sqrt(sum(randomNormals.^2,2)),1,3);
    r = repmat(p.universeSize.*rand(M,1).^(1/3),1,3); % this can be efficiencied, 
    
    r(2:2:end,:) = repmat(p.universeSize,M/2,3); %half of vessel origins on the surface
    vesselOrigins = r.*randomNormals;

    % generate random (normalized) directions for each vessel
    vesselNormals = randn(M,3);
    vesselNormals = vesselNormals./repmat(sqrt(sum(vesselNormals.^2,2)),1,3);
    
    % calculate lengths of vessels in sphere
    a = sum(vesselNormals.^2,2);
    b = 2*sum(vesselOrigins.*vesselNormals,2);
    c = sum(vesselOrigins.^2,2)-p.universeSize.^2;
    
    delta = b.*b-4*a.*c;
    
    u1 = (-b-sqrt(delta))./2./a;
    u2 = (-b+sqrt(delta))./2./a;
    p1 = vesselOrigins+repmat(u1,1,3).*vesselNormals;
    p2 = vesselOrigins+repmat(u2,1,3).*vesselNormals;
    l  = sqrt(sum((p2-p1).^2,2));
        
    %find vessel number cutoff for desired volume fractions
    cutOff = 0;
    for k = 1:length(p.R)
    	R(cutOff+1:M,:)        = repmat(p.R(k),length(cutOff+1:M),1);
        % does deltaChi need to be redone every time? It shouldn't change
    	deltaChi(cutOff+1:M,:) = repmat(p.deltaChi0*p.Hct(k).*(1-p.Y(k)),length(cutOff+1:M),1);
        
    	volSum = (cumsum(l.*pi.*R.^2));
		cutOff = find(volSum<(volUniverse.*sum(p.vesselFraction(1:k))),1,'last');
    end
    
    if cutOff==M
    	disp('Error: Increase max vessels!');
    end
    
    R               = R(1:cutOff);
    deltaChi        = deltaChi(1:cutOff);
    vesselOrigins   = vesselOrigins(1:cutOff,:);
    vesselNormals   = vesselNormals(1:cutOff,:);
	vesselVolFrac   = volSum(cutOff)/volUniverse;
    numVessels      = cutOff;
    
    protonPosit = [0 0 0];
    
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%     randomWalk                      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [protonPosits] = randomWalk(p,protonPosit)

	protonPosits        = p.stdDev.*randn(p.numSteps*p.HD,3);   
	protonPosits(1,:)   = protonPosit;
	protonPosits        = cumsum(protonPosits);
	
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%     walkingReflection               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [cumulPosits] = walkingReflection(p,protonPosit,vesselOrigins,vesselNormals)

    basicPosits         = p.stdDev.*randn(p.numSteps.*p.HD,3);
    cumulPosits         = basicPosits;
    cumulPosits(1,:)    = protonPosit;
    cumulPosits         = cumsum(cumulPosits);
    
    nv = size(vesselOrigins,1);
    
    % define positive and negative versions of basicPosits, for reflecting
    invPosits(:,:,1) = basicPosits;
    invPosits(:,:,2) = -basicPosits;
    
    % counter
    invert = 2;
    
    Q1 = vesselOrigins + vesselNormals.*0.5;
    Q2 = vesselOrigins - vesselNormals.*0.5;
    QD = Q2-Q1;
    
    for ii = 2:(p.HD*p.numSteps)
        pos = repmat(cumulPosits(ii,:),nv,1);
        
        QDPQ = abs(cross(QD,pos-Q1));
        
        if min(max(QDPQ,[],2)) < p.R(1)
            % relflection algorithm (working)
            previous = repmat(cumulPosits(ii-1,:),(p.HD*p.numSteps-ii)+1,1);
            cumulPosits(ii:end,:) = previous + cumsum(invPosits(ii:end,:,invert));
            invert = mod(invert,2) + 1; % switch this between 1 and 2 each time
        end
    end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%     calculateField                  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%calculate magnetic field at proton location
function [totalField, numStepsInVessel, numCloseApproaches, stepInLargeVessel] = calculateField(p, protonPosits, vesselOrigins, vesselNormals, R, deltaChi, numVessels)
	
	% store original values for later use
	protonPositsHD  = protonPosits;
	vesselOriginsHD = vesselOrigins;
	vesselNormalsHD = vesselNormals;
	
	protonPosits  = protonPosits(1:p.HD:end,:);
	protonPosits  = repmat(permute(protonPosits,[3 2 1]),numVessels,1,1);
	vesselOrigins = repmat(vesselOrigins,1,1,p.numSteps);
	vesselNormals = repmat(vesselNormals,1,1,p.numSteps);
	
	relPosits = protonPosits - vesselOrigins;
	
	% perpendicular distance from proton to vessel
	r = squeeze(sqrt(sum((relPosits-repmat(dot(relPosits,vesselNormals,2),1,3,1).*vesselNormals).^2,2)));

	% elevation angle between vessel and the z-axis (just do it for one time step and repmat later)
	theta = acos(dot(vesselNormals(:,:,1),repmat([0 0 1],numVessels,1,1),2));
        
    % np = zeros(numVessels,3,p.numSteps); % this line may not be necessary
	np = relPosits-repmat(dot(relPosits,vesselNormals,2),1,3,1).*vesselNormals;
	np = np./repmat(sqrt(sum(np.^2,2)),1,3,1);
	nb = cross(repmat([0 0 1],numVessels,1,p.numSteps),vesselNormals);
	nb = nb./repmat(sqrt(sum(nb.^2,2)),1,3,1);
	nc = cross(vesselNormals,nb);
	nc = nc./repmat(sqrt(sum(nc.^2,2)),1,3,1);

	% azimuthal angle in plane perpendicular to vessel
	phi = squeeze(acos(dot(np,nc,2)));
	
	% calculate fields when proton is outside or inside a vessel
	fields_extra = p.B0.*2.*pi.*repmat(deltaChi,1,p.numSteps).*(repmat(R,1,p.numSteps)./r).^2.*cos(2.*phi).*sin(repmat(theta,1,p.numSteps)).^2;
	fields_intra = p.B0.*2.*pi./3.*repmat(deltaChi,1,p.numSteps).*(3.*cos(repmat(theta,1,p.numSteps)).^2-1);

	% combine fields based on whether proton is inside/outside the vessel
	mask   = r < repmat(R,1,p.numSteps);
	fields = fields_extra.*(~mask)+fields_intra.*mask;
	
	% CONSIDER CLEARING NO LONGER NEEDED VARIABLES HERE
    clear fields_extra fields_intra nb nc np relPosits phi protonPosits
		
	% START HD
	% find vessels within R^2/r^2<0.04 of the proton
	vesselsHD    = find(sum(r<sqrt(repmat(R,1,p.numSteps).^2./0.04),2)>0);
	numVesselsHD = length(vesselsHD);
	
	if (( numVesselsHD > 0 ) && ( p.HD > 1 ))
	
		protonPositsHD  = repmat(permute(protonPositsHD,[3 2 1]),numVesselsHD,1,1);
		vesselOriginsHD = repmat(vesselOriginsHD(vesselsHD,:),1,1,p.numSteps*p.HD);
		vesselNormalsHD = repmat(vesselNormalsHD(vesselsHD,:),1,1,p.numSteps*p.HD);
		RHD         = R(vesselsHD);
		deltaChiHD  = deltaChi(vesselsHD);
		relPositsHD = protonPositsHD-vesselOriginsHD;
	
		% perpendicular distance from proton to vessel
		rHD = permute(sqrt(sum((relPositsHD-repmat(dot(relPositsHD,vesselNormalsHD,2),1,3,1).*vesselNormalsHD).^2,2)),[1 3 2]);

		% elevation angle between vessel and the z-axis (just do it for one time step and repmat later)
		thetaHD = acos(dot(vesselNormalsHD(:,:,1),repmat([0 0 1],numVesselsHD,1,1),2));
	
		% npHD = zeros(numVesselsHD,3,p.numSteps*p.HD); % may be unnecessary
		npHD = relPositsHD-repmat(dot(relPositsHD,vesselNormalsHD,2),1,3,1).*vesselNormalsHD;
		npHD = npHD./repmat(sqrt(sum(npHD.^2,2)),1,3,1);
		nbHD = cross(repmat([0 0 1],numVesselsHD,1,p.numSteps*p.HD),vesselNormalsHD);
		nbHD = nbHD./repmat(sqrt(sum(nbHD.^2,2)),1,3,1);
		ncHD = cross(vesselNormalsHD,nbHD);
		ncHD = ncHD./repmat(sqrt(sum(ncHD.^2,2)),1,3,1);

		% azimuthal angle in plane perpendicular to vessel
		phiHD = permute(acos(dot(npHD,ncHD,2)),[1 3 2]);
		
		% calculate fields when proton is outside or inside a vessel
		fields_extraHD = p.B0.*2.*pi.*repmat(deltaChiHD,1,p.numSteps*p.HD).*(repmat(RHD,1,p.numSteps*p.HD)./rHD).^2.*cos(2.*phiHD).*sin(repmat(thetaHD,1,p.numSteps*p.HD)).^2;
		fields_intraHD = p.B0.*2.*pi./3.*repmat(deltaChiHD,1,p.numSteps*p.HD).*(3.*cos(repmat(thetaHD,1,p.numSteps*p.HD)).^2-1);
		
		% combine fields based on whether proton is inside/outside the vessel
		maskHD   = rHD < repmat(RHD,1,p.numSteps*p.HD);
		fieldsHD = fields_extraHD.*(~maskHD)+fields_intraHD.*maskHD;

		%downsample to standard time step
		fields(vesselsHD,:) = permute(mean(reshape(fieldsHD,numVesselsHD,p.HD,p.numSteps),2),[1 3 2]);
	
	end

	%record number of close approaches to vessels
	numCloseApproaches = numVesselsHD;

	% END HD
		
	% sum fields over all vessels
	totalField = p.B0 + sum(fields,1);

	% record how long the proton spent inside vessels
	numStepsInVessel = sum(sum(mask));
	
	% record whether the proton passed into a "large" vessel (R>4mum)
	if numStepsInVessel>0
		stepInLargeVessel = max(R(find(sum(mask,2)>0)))>4e-6;
	else
		stepInLargeVessel=0;
    end
return;