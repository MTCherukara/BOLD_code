% FabberCurves.m
% Display an averaged-out ASE curve from FABBER "modelfit" data, or from other
% 4D ASE-type datasets (designed for use with the VS dataset)
%
% MT Cherukara
% 
% Actively used as of 2018-09-19


clear;
% close all;

setFigureDefaults;

% Parameters
% slices = 4:9;       % VS data
slices = 1:6;       % s11 FLAIR data

% Subject number
subnum = 11;

%% Load the data

% Have the users specify a file to load, which will be either ASE data, or
% modelfit, or residual
[dname, ddir] = uigetfile('*.nii.gz','Select NIFTY Data to load...');

% % Extract the VS number from the chosen directory's name
% C = strsplit(ddir,'vs');
% VSnum = C{2}(1);
% 
% % Load the appropriate grey-matter mask
% Maskslice = LoadSlice(['/Users/mattcher/Documents/DPhil/Data/validation_sqbold/vs',...
%                        VSnum,'/mask_gm_60.nii.gz'],slices);

if subnum < 10
    s_subnum = strcat('0',num2str(subnum));
else
    s_subnum = num2str(subnum);
end

Maskslice = LoadSlice(['/Users/mattcher/Documents/DPhil/Data/subject_',...
                       s_subnum,'/mask_GM_80_FLAIR.nii.gz'],slices);


% Load the data
Dataset = LoadSlice([ddir,dname],slices);


%% Do some averaging

% number of time-points
nt = size(Dataset,4);

% Pre-allocate results vectors
Sig_mean = zeros(1,nt);
Sig_std  = zeros(1,nt);
Sig_med  = zeros(1,nt);
Sig_iqr  = zeros(1,nt);


% Loop through time points:
for ii = 1:nt
    
    Dataslice = Dataset(:,:,:,ii);
    
    % Apply mask and vectorize
    Dataslice = Dataslice(:).*Maskslice(:);
    
    % Remove zeros
    Dataslice(Dataslice == 0) = [];
    
    % Calculate signal averages
    Sig_mean(ii) = nanmean(Dataslice);
    Sig_std(ii)  = nanstd(Dataslice);
    Sig_med(ii)  = nanmedian(Dataslice);
    
    qnt = quantile(Dataslice,[0.75,0.25]);
    Sig_iqr(ii)  = (qnt(1) - qnt(2)) ./ 2;

end


%% Plot

% tau values
if nt == 24
    taus = (-28:4:64)./1000; % VS
elseif nt == 14
    taus = [-28, -20, -12, -4, 0, 4, 8, 16, 24, 32, 40, 48, 56, 64]./1000;
elseif nt == 11
    taus = (-16:8:64)./1000; % AMICI Protocol
else
    taus = (1:1:nt)./1000;
end

% Normalize to values around the spin echo
SEind = find(abs(taus) < 1e-6,1);
Sig_medN  = Sig_med./mean(Sig_med(SEind-1:SEind+1));
Sig_meanN = Sig_mean./mean(Sig_med(SEind-1:SEind+1));


figure();
hold on; box on;
plot(1000*taus,log(Sig_mean),'-');

xlabel('Spin echo displacement \tau (ms)')
ylabel('ASE Signal');
% title(['Subject vs',VSnum,' (GM average)']);

% xlim([-32,68]);

