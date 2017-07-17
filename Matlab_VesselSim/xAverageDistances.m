% xAverageDistances.m
%
% use the function xVesselDistances to figure out a relationship between
% vessel radius and average distance to closest vessel

clear; clf;

p = gentemplate;
p.vesselFraction = 0.02;

nReps = 100; % number of repeats to do at each radius

R = (10:5:200)*1e-6; % range from 10 to 200 um

Dists = zeros(length(R),1);

for ii = 1:length(R)
    
    disp(['Calculating radius ',num2str(ii),' of ',num2str(length(R)),'...']);
    
    p.R = R(ii);
    Di = zeros(nReps,1);
    
    for jj = 1:nReps
        Di(jj) = xVesselDistances(p);
    end
    Dists(ii) = mean(Di);
    
end

% plot a graph
figure('WindowStyle','Docked');
plot(R*1e6,Dists*1e6,'-','LineWidth',2);
xlabel('Radius (\mum)');
ylabel('Distance to Nearest Vessel (\mum)');