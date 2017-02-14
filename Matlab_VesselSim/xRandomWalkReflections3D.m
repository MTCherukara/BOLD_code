% xRandomWalkReflections3D.m

% To test generating a random-walk pattern which is reflected whenever it
% hits a particular boundary in space, for use in the simplevesselsim to
% simulate solid boundaries of vessel walls. 

% For testing the same thing, but in 3D

% MT Cherukara
% 14 February 2017

clear; close all;

tic;

% standard parameters from the vessel simulator
stdDev   = 2e-7;
HD       = 10;
numSteps = 600;     % normally 600, but we'll keep it a bit shorter for now
radius   = 1e-6;
usize    = 9e-4;    % universe size (scale * r)
zeta     = 0.05;    % volume occupied by vesselss

initPosit = [0,0,0];

% number of vessels
nv = 100000;

%% generate vessels using the same method as vesselsim
disp('Generating Universe...');

volUniverse = (4/3)*pi*usize^3;

randomNormals = randn(nv,3);
randomNormals = randomNormals./repmat(sqrt(sum(randomNormals.^2,2)),1,3);
r = repmat(usize.*rand(nv,1).^(1/3),1,3); 

r(2:2:end,:) = repmat(usize,nv/2,3); %half of vessel origins on the surface
vesselOrigins = r.*randomNormals;

% generate random (normalized) directions for each vessel
vesselNormals = randn(nv,3);
vesselNormals = vesselNormals./repmat(sqrt(sum(vesselNormals.^2,2)),1,3);

% calculate lengths of vessels in sphere
a = sum(vesselNormals.^2,2);
b = 2*sum(vesselOrigins.*vesselNormals,2);
c = sum(vesselOrigins.^2,2)-usize.^2;

delta = b.*b-4*a.*c;

u1 = (-b-sqrt(delta))./2./a;
u2 = (-b+sqrt(delta))./2./a;
p1 = vesselOrigins+repmat(u1,1,3).*vesselNormals;
p2 = vesselOrigins+repmat(u2,1,3).*vesselNormals;
l  = sqrt(sum((p2-p1).^2,2));

%find vessel number cutoff for desired volume fractions
volSum = (cumsum(l.*pi.*radius.^2));
cutOff = find(volSum<(volUniverse.*zeta),1,'last');

vesselOrigins   = vesselOrigins(1:cutOff,:);
vesselNormals   = vesselNormals(1:cutOff,:);
nv = cutOff;

clear u1 u2 p1 p2 l a b c delta 

%% generate random walk
protonPosits = stdDev.*randn(numSteps.*HD,3);
cumulativePosits      = protonPosits;
cumulativePosits(1,:) = initPosit;
cumulativePosits      = cumsum(cumulativePosits);

% define negative version of protonPosits, which we'll quickly pull from
% when we need to reflect the cumulative walk
invPosits(:,:,1) = protonPosits;
invPosits(:,:,2) = -protonPosits;

invert = 2; % start with the negative version of protonPosits ready to go
refl   = 0; % counter

% also define lines running along vessels (Q1 and Q2) which will be used to
% calculate distance:
Q1 = vesselOrigins + vesselNormals.*0.5;
Q2 = vesselOrigins - vesselNormals.*0.5;
QD = Q2-Q1;

%% loop through the entire random walk, finding points where the path
% touches a vessel, and reflecting them
disp('Randomly Walking...');
for ii = 2:(HD*numSteps)      % skip the first point
    pos = cumulativePosits(ii,:);
    
    QDPQ = abs(cross(QD,pos-Q1)); % calculate cross product in one go
    % don't need to calculate normal at all, just need to make sure that
    % the smallest 
    
    if min(max(QDPQ,[],2)) < radius
            % relflection algorithm (working)
            cumulativePosits(ii:end,:) = cumulativePosits(ii-1,:) + cumsum(invPosits(ii:end,:,invert));
            invert = mod(invert,2) + 1; % switch this between 1 and 2 each time
            refl = refl + 1; % count the total number of relfections
    end
end

toc;

disp(['Total reflections: ',num2str(refl)]);