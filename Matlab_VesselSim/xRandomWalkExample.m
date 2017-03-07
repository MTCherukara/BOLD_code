% xRandomWalkExample.m

% Illustrate the vessel sim in 2D

clear; close all;

p = gentemplate;

p.N = 1;

p.R = 2e-5;     % radius, in m
p.D = 1e-8;     % diffusion, in m^2/s
p.Y = 0.6;      % oxygenation fraction (1-OEF) 
p.vesselFraction = 0.07;    % DBV

numSteps = 500; % for random walk

p.deltaChi = p.deltaChi0.*p.Hct.*(1-p.Y);
p.solidWalls = 0;

% from simplevesselsim>>main

p.HD = 1; % factor for higher density sampling near vessels
p.stdDev = sqrt(2*p.D*p.dt/p.HD);
p.universeSize = p.universeScale*min(p.R);
p.numSteps = round((p.TE*2)/p.dt);
p.ptsPerdt = round(p.deltaTE./p.dt); %pts per deltaTE

% from setupUniverse (converted to 2D)
volUniverse = pi*p.universeSize^2;  % p.universeSize = p.universeScale*min(p.R);
M = 1000; %max number of vessels

randomNormals = randn(M,2);
randomNormals = randomNormals./repmat(sqrt(sum(randomNormals.^2,2)),1,2);
r = repmat(p.universeSize.*rand(M,1).^(1/2),1,2); % this can be efficiencied,

vesselOrigins = r.*randomNormals;

% % see origins
% figure(1);
% plot(vesselOrigins(:,1),vesselOrigins(:,2),'.');

% find the cut-off point and stuff
R           = repmat(p.R,M,1);
deltaChi    = repmat(p.deltaChi0*p.Hct.*(1-p.Y),M,1);

volSum = cumsum(pi.*R.^2);

cutOff = find(volSum<(volUniverse.*p.vesselFraction),1,'last');

R               = R(1:cutOff);
deltaChi        = deltaChi(1:cutOff);
vesselOrigins   = vesselOrigins(1:cutOff,:);
vesselVolFrac   = volSum(cutOff)/volUniverse;
numVessels      = cutOff;

figure(2);
coords = MTC_circle(vesselOrigins(1,1),vesselOrigins(1,2),R(1));
plot(coords(1,:),coords(2,:),'b-'); hold on;
axis([-1,1,-1,1].*5e-4);

F1(numVessels+numSteps) = struct('cdata',[],'colormap',[]);
F1(1) = getframe(gcf);

for ii = 2:numVessels
    figure(2); 
    coords = MTC_circle(vesselOrigins(ii,1),vesselOrigins(ii,2),p.R);
    plot(coords(1,:),coords(2,:),'b-');
    drawnow;
    F1(ii) = getframe(gcf);
end

% random walk bit
initPosit = [0,0];

% generate random walk
protonPosits = 5.*p.stdDev.*randn(numSteps.*p.HD,2);
cumulativePosits      = protonPosits;
cumulativePosits(1,:) = initPosit;
cumulativePosits      = cumsum(cumulativePosits);

% prepare for inverting
invPosits(:,:,1) = protonPosits;
invPosits(:,:,2) = -protonPosits;

invert = 2; % start with the negative version of protonPosits ready to go

% loop through and find stuff out
for jj = 2:(p.HD*numSteps)
    
    pos = cumulativePosits(jj,:);
    
    dstn = zeros(1,numVessels);
    
    for kk = 1:numVessels 
        dstn(kk) = sqrt((vesselOrigins(kk,1)-pos(1)).^2 + (vesselOrigins(kk,2)-pos(2)).^2);
    end
    
    if min(dstn) < p.R
        cumulativePosits(jj:end,:) = cumulativePosits(jj-1,:) + cumsum(invPosits(jj:end,:,invert));
        invert = mod(invert,2) + 1; % switch this between 1 and 2 each time
    end
end

figure(2);
plot(cumulativePosits(1,1),cumulativePosits(1,2),'rx');
drawnow;
F1(numVessels+1) = getframe(gcf);

for ii = 2:numSteps
    figure(2);
    plot(cumulativePosits(ii-1:ii,1),cumulativePosits(ii-1:ii,2),'r-');
    drawnow;
    F1(numVessels+ii) = getframe(gcf);
end
