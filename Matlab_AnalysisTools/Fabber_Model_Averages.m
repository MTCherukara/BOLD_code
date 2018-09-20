% Fabber_Model_Averages.m
%
% Load a Fabber dataset and calculates the average values of the paramaters.
% Designed for use with the phenomenological qBOLD model. Based on the script
% FabberAverages.m

clear; 
clc;

% Variable names
vars = {'b11','b12','b13','b21','b22','b23','b31','b32','b33'};

% Set number
setnum = 110;

% Slices
slicenum = 1:9;

% Title
disp(['Data from Fabber Set ',num2str(setnum),':']);

% Directory
resdir = '/Users/mattcher/Documents/DPhil/Data/Fabber_ModelFits/';
fdname = dir([resdir,'fabber_',num2str(setnum),'_*']);
fabdir = strcat(resdir,fdname.name,'/');

% First, have a look at OEF estimation
OEFslice = LoadSlice([fabdir,'mean_OEF.nii.gz'],slicenum);
% DBVslice = LoadSlice([fabdir,'mean_DBV.nii.gz'],slicenum);

% Make a mask of all bad OEF voxels
badOEF = (OEFslice > 1.0) + (OEFslice < 0.0);

% calculate average OEFs
OEFvalues = OEFslice.*(1-badOEF);
OEFav = sum(OEFvalues,2)./sum(OEFvalues~=0,2);

% vectorize this, for later
badOEF = badOEF(:);

% store all the B values in a single vector (for later analyis)
bb = zeros(length(vars),1);

% Loop through variables
for vv = 1:length(vars)
    
    % Identify Variable
    vname = vars{vv};
    
    % Load Data and Standard Deviation
    Datslice = LoadSlice([fabdir,'mean_',vname,'.nii.gz'],slicenum);
    Stdslice = LoadSlice([fabdir,'std_',vname,'.nii.gz'],slicenum);

    % Remove bad voxels
    Datslice = Datslice(:);
    Datslice(badOEF ~= 0) = [];
    
    Stdslice = Stdslice(:);
    Stdslice(badOEF ~= 0) = [];
    
    vmn = mean(Datslice);
    vsd = mean(Stdslice);
    vSR = abs(vmn)./vsd;
    
    % Average and display the results
    disp(['  ',vname,' = ',num2str(vmn),' +/- ',num2str(vsd),' (SNR=',num2str(vSR),')']);
    
    bb(vv) = vmn;

end

%% Free Energy

FEnSlice = LoadSlice([fabdir,'freeEnergy.nii.gz'],slicenum);
ResSlice = LoadSlice([fabdir,'residuals.nii.gz'],slicenum);





% [FEData,RData,MData] = MTC_LoadFreeEnergy(setnum,subnum,slicenum);
% 5
% % disp('   ');
% % disp(['     Mean Residual : ',num2str(mean(RData),4)]);
% % disp([' Absolute Residual : ',num2str(mean(abs(RData)),4)]);
% % disp(['   Median Residual : ',num2str(median(RData),4)]);
% % 
% % disp('   ');
% % disp(['      Modelfit SNR : ',num2str(mean(MData)./mean(abs(RData)),4)]);
% 
% disp('   ');
% disp(['  Mean Free Energy : ',num2str(-mean(FEData),4)]);
% disp(['Median Free Energy : ',num2str(-median(FEData),4)]);
