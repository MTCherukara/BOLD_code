% xRandomWalkReflections.m

% To test generating a random-walk pattern which is reflected whenever it
% hits a particular boundary in space, for use in the simplevesselsim to
% simulate solid boundaries of vessel walls. Currently run in 2 dimensions
% (but it should be trivial to extend it to 3)

% MT Cherukara
% 14 February 2017

clear; close all;

% standard parameters from the vessel simulator
stdDev   = 2e-7;
HD       = 10;
numSteps = 100;     % normally 600, but we'll keep it a bit shorter for now
radius   = 0.5e-6;

initPosit = [0,0];

% generate random walk
protonPosits = stdDev.*randn(numSteps.*HD,2);
cumulativePosits      = protonPosits;
cumulativePosits(1,:) = initPosit;
cumulativePosits      = cumsum(cumulativePosits);

% % display
% figure(1);
% plot(cumulativePosits(:,1),cumulativePosits(:,2),'-','LineWidth',1.5);
% axis equal;

% now, impose blocked out areas above and below % y=2e-6, to simulate
% vessels in those spaces
vesselOrigins = [2,2;2,-2].*1e-6;
vesselNormals = [1,-1;1,0];
vesselRadii   = radius.*ones(length(vesselOrigins),1);

nv = size(vesselOrigins,1);     % number of vessels

% define negative version of protonPosits, which we'll quickly pull from
% when we need to reflect the cumulative walk
invPosits(:,:,1) = protonPosits;
invPosits(:,:,2) = -protonPosits;

invert = 2; % start with the negative version of protonPosits ready to go

% loop through the entire random walk, finding points where the path
% touches a vessel, and reflecting them
for ii = 2:(HD*numSteps)      % skip the first point
    pos = cumulativePosits(ii,:);
    
    % calculate distance from proton to each vessel origin
%     posd = repmat(pos,nv,1) - vesselOrigins;
%     dstn = arrayfun(@(idx) norm(posd(idx,:)), 1:size(posd,1));

    dstn = zeros(1,nv);
    for jj = 1:nv
        Q1 = vesselOrigins(jj,:) + vesselNormals(jj,:).*1e-4;
        Q2 = vesselOrigins(jj,:) - vesselNormals(jj,:).*1e-4;
        dstn(jj) = abs(det([Q2-Q1;pos-Q1]))./2e-4;
%         dstn(jj) = norm(pos-vesselOrigins(jj,:));
    end
    
    if min(dstn) < radius
%     if (pos(2) > 2e-6) || (pos(2) < -2e-6)
            % relflection algorithm (working)
            cumulativePosits(ii:end,:) = cumulativePosits(ii-1,:) + cumsum(invPosits(ii:end,:,invert));
            invert = mod(invert,2) + 1; % switch this between 1 and 2 each time
            
%             disp(['Reflecting ',num2str(pos),' to ',num2str(cumulativePosits(ii,:))]);
    end
end

% display new version
figure(2);
plot(cumulativePosits(:,1),cumulativePosits(:,2),'x-','LineWidth',1.5);
axis equal
hold on;
% for jj = 1:nv
%     coords = MTC_circle(vesselOrigins(jj,1),vesselOrigins(jj,2),radius);
%     plot(coords(1,:),coords(2,:),'k-','LineWidth',2);
% end
for jj = 1:nv
    Q1 = vesselOrigins(jj,:) + vesselNormals(jj,:).*1e-4;
    Q2 = vesselOrigins(jj,:) - vesselNormals(jj,:).*1e-4;
    plot([Q1(1),Q2(1)],[Q1(2),Q2(2)],'k-','LineWidth',2);
end