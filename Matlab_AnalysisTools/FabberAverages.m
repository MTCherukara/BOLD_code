% function FabberAverages(fabber)
    % Loads a particular Fabber dataset and displays the average (mean and
    % median) values of R2' and DBV in the top 8 slices.
    %
    % Actively used as of 2018-08-27
    %
    % Changelog:
    %
    % 3 July 2018 (MTC). Modularized to use MTC_LoadVol (which calls LoadSlice)
    %       to get rid of a bunch of repeated stuff here. Also changed the way
    %       the upper parameter threshold works, so that we now remove voxels
    %       whose values are too high, rather than setting them to an arbitrary
    %       value.
    %
    % 12 March 2018 (MTC). Generalization, enabling selection of variables to
    %       plot in a more generic and extensible way.

clear; 
clc;

% Choose Variables
vars = {'R2p','DBV','OEF'};

% Choose the slices we want
slicenum = 4:9;     % VS - instead of 3:10
% slicenum = 3:8;     % CSF + patient data
% slicenum = 1:6;   % TR = 2

% Choose Data set
setnum = 537;
subnum = 2;

setnum = setnum + subnum - 1;

CSF_subs = containers.Map([ 1, 2, 3, 4, 5 ], ...
                          [ 3, 4, 6, 8, 9 ]);
% subnum = CSF_subs(subnum);     

% Title
disp(['Data from Fabber Set ',num2str(setnum),'. Subject ',num2str(subnum)]);

for vv = 1:length(vars)
    
    % Identify Variable
    vname = vars{vv};
    
    % Load the Data and do all the masking and thresholding
    [volData, volStdv] = MTC_LoadVol(setnum,subnum,vname,slicenum);
   
    % convert certain params to percentages
    if strcmp(vname,'DBV') || strcmp(vname,'OEF') || strcmp(vname,'VC') || strcmp(vname,'lambda')
        volData = volData.*100;
        volStdv = volStdv.*100;
    end
    
    % calculate IQR
    qnt = quantile(volData,[0.75,0.25]);
    iqr = qnt(1) - qnt(2) ./ 2;
    
%     Display results
%     disp('   ');
%     disp(['Median ',vname,': ',num2str(median(volData),4)]);
%     disp(['   IQR ',vname,': ',num2str(iqr,4)]);
    
    disp('   ');
    disp(['Mean ',vname,'   : ',num2str(mean(volData),4)]);
%     disp(['    Std ',vname,': ',num2str(mean(volStdv),4)]);
    disp(['    Std ',vname,': ',num2str(std(volData),4)]);

end

%% Free Energy

% [FEData,RData,MData] = MTC_LoadFreeEnergy(setnum,subnum,slicenum);
% 
% disp('   ');
% % disp(['     Mean Residual : ',num2str(mean(RData),4)]);
% disp([' Absolute Residual : ',num2str(mean(abs(RData)),4)]);
% % disp(['   Median Residual : ',num2str(median(RData),4)]);
% % 
% % disp('   ');
% disp(['      Modelfit SNR : ',num2str(mean(MData)./mean(abs(RData)),4)]);
% 
% disp('   ');
% % disp(['  Mean Free Energy : ',num2str(-mean(FEData),4)]);
% disp(['Median Free Energy : ',num2str(-median(FEData),4)]);
