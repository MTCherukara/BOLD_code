% AnalyseTRUST_MTC.m
%
% TRUST data analysis script, based heavily on Caitlin O'Brien's script (2017);
% Adapted 29 April 2019 (MTC).
%
% CHANGELOG:

clear;
% close all;
setFigureDefaults;

% Parameters
nt = 6;     % number of TEs
na = 2;     % number of averages

TEs = linspace(0,200,nt)./1000;

% Choose subject (as a STRING!)
subj = '14';


%% Load Data
% Load the TRUST data
datadir = strcat('/Users/mattcher/Documents/DPhil/Data/subject_',subj,'/');
matRaw = read_avw([datadir,'TRUST.nii.gz']);

% Load the appropriate TRUST mask
matMask = read_avw([datadir,'mask_trust.nii.gz']);

% Loop through volumes and extract only the ROI data, and put in in a
% better-shaped matrix
nv = size(matRaw,4);    % number of volumes (should equal 2 * nt * na)
np = sum(matMask(:));   % number of TRUST-contrast voxels


% % Check that the matrix we've loaded is the right size
% if nv ~= nt*na*2
%     error('Incorrect matrix size!')
% end

% Pre-allocate matrix
%       DIMS: TEs, TAG/CONTROL, VOXELS, AVERAGES
matTRUST = zeros(nt,2,np,na);

% Loop through averages
for i1 = 1:na
    
    % Loop through TEs
    for i2 = 1:nt
        
        % Loop through TAG/CONTROL states
        for i3 = [1,2]
            
            % define correct volume index
            vind = (nt*2)*(i1-1) + 2*(i2-1) + i3;
%             disp(['Volume index: ',num2str(vind)]);
            
            % Pull out the correct volume
            matData = squeeze(matRaw(:,:,1,vind));
            
            % Mask it
            vecData = matData(:);
            vecData = vecData(matMask(:) == 1);
            
            % Store it
            %   DIMS: TEs, TAG/CONTROL, VOXELS, AVERAGES
            matTRUST(i2,i3,:,i1) = vecData;
            
            
        end % or i3 = [1,2] - TAG/CONTROL state
    end % for i2 = 1:nt - TEs
end % for i1 = 1:na - averages


%% Process TRUST

% averaging
%   DIMS: TEs, TAG/CONTROL, VOXELS, AVERAGES
if na > 1
    matTRUST = mean(matTRUST,4);
end
matTRUST = squeeze(matTRUST);

% Now DIMS: TEs, TAG/CONTROL, VOXELS

% subtract
matSUB = squeeze(matTRUST(:,1,:)) - squeeze(matTRUST(:,2,:));

% get rid of voxels where it didn't work
sumSUB = sum(matSUB,1);
matSUB(:,sumSUB < 0) = [];

% ROI mean
vecTRUST = mean(matSUB,2);

% Normalize
vecTRUST = vecTRUST./max(vecTRUST);

% Fit an exponential function
coeff_TRUST = fit(TEs', vecTRUST, 'exp1');
R2_TRUST    = -coeff_TRUST.b;

% Print results
disp(['TRUST T2 of blood: ',num2str(1000/R2_TRUST),' ms']);

Hct = 0.40;

% % Calculate OEF (old formula)
OEF = sqrt((R2_TRUST - 11.06)/121.78);

% % Calculate OEF Lu, 2012 formula, from O'Brien:
% A = 247.4*Hct*(1-Hct);
% B = (3.4*(Hct^2)) - (Hct/2);
% C = -13.5 + (80.2*Hct) - (75.9*(Hct^2));
% OEF = -B + sqrt((B^2) - (4*A*(C-R2_TRUST))) ./ (2*A);


disp(['TRUST OEF: ',num2str(100*OEF,3),' %']);
%     R2b  = ( 4.5 + (16.4*Hct)) + ( ((165.2*Hct) + 55.7)*pow(OEF,2.0) );


%% Plot average curve

figure;
plot(1000*TEs,vecTRUST,'x-');
hold on; box on; grid on;
xlabel('TE (ms)');
ylabel('Magnetization (a.u.)');
title(['Subject ',subj,', OEF = ',num2str(100*OEF,3),'%']);

% Plot Exponential decay fit
vecTEs = linspace(TEs(1),TEs(end));
vecFIT = exp(coeff_TRUST.b.*vecTEs);
plot(1000*vecTEs,vecFIT,'--');
    