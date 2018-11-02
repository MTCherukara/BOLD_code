% voxelwise_anova.m
%
% calculates variation between fabber data-sets, on a voxel-wise basis using
% ANOVA. Derived from FabberAverages.m
%
% MT Cherukara
% 2 July 2018


clear; 
clc;
% close all;

CSF_data = 0;


%% Choosing Stuff
% Choose which datasets and variables we want to compare
vname = 'R2p';              % variable name
fsets = [621, 622, 623, 624];    % FABBER datasets of interest
subnum = 11;                 % subject number
nsets = length(fsets);      % number of sets
% fsets = fsets + subnum - 1;     % automatically adjust the set numbers

    
% Specific things depending on the data-set
if CSF_data
    slices = 2:8;
    
    % Define the right subject numbers for loading masks later on 
    CSF_subs = containers.Map([ 1, 2, 3, 4, 5 ], ...
                              [ 3, 4, 6, 8, 9 ]);
    subnum = CSF_subs(subnum);     
    
else
%     slices = 3:10;
    slices = 1:6;     % sub 11 FLAIR

end


% For plotting later, define a maximum y-axis value based on the variable:
yMax = containers.Map({'R2p', 'DBV' , 'OEF' , 'VC', 'DF', 'lambda'}, ...
                      [ 8.3 ,  0.17 ,  0.55 ,  1  ,  15 ,   1     ]);  
                      
% Pre-allocate some arrays for Data and Variances
        % these are deliberately too big, but since the exact number of data
        % points may vary between sets, we will do it like this, then cut them
        % down to the length of the largest set, and then deal with the extra
        % zeros later
volData = zeros(5000,nsets);
volStd  = zeros(5000,nsets);

% pre-assign the max and min lengths, which will be replaced in the loop
maxLength = 1; 
minLength = 1e5;


%% Loop through datasets, loading each one 
for ii = 1:nsets
    
    % pull out the set number
    setnum = fsets(ii);
    
    % load data using MTC_LoadVol
    [volDataRaw, volStdRaw] = MTC_LoadVol(setnum,subnum,vname,slices);
    
    % pull out the length of the data
    dataLength = length(volDataRaw);
    
    % decide what the length of the longest and shortest datasets are
    maxLength = max(maxLength,dataLength);
    minLength = min(minLength,dataLength);
    
    % assign data into the pre-allocated arrays
    volData(1:dataLength,ii) = volDataRaw;
    volStd (1:dataLength,ii) = volStdRaw;
    
end

% cut off excess zeros in the data arrays
volData = volData(1:minLength,:);
volStd  = volStd (1:minLength,:);


%% Analysis
% averages
aData = mean(volData);
aStd  = mean(volStd);

% ANOVA
[~,~,daStats] = anova2(volData,1,'off');
daC = multcompare(daStats,'display','off');

% Pick the comparisons we want 
grps = {[1,2];[1,3];[1,4]};

% Pre-allocate p-value array
pvls = zeros(length(grps),1);

% Loop through comparison pairs and extract p values from the multcompare array
for gg = 1:length(grps)
    
    grp = grps{gg};
    comp_line = (daC(:,1) == grp(1)) .* (daC(:,2) == grp(2));
    pvls(gg) = daC((comp_line==1),6);

end


%% Plotting
% Plot Bar Chart
setFigureDefaults;
figure(subnum); clf;
hold on; box on;
bar(1:nsets,aData,0.6);

% Add Errorbars
errorbar(1:nsets,aData,aStd,'k.','LineWidth',2,'MarkerSize',1);

% Set Axes
axis([0.5,nsets+0.5,0,yMax(vname)]);
xticks(1:nsets);
ylabel(vname);
title(['Subject ',num2str(subnum)]);
% yticklabels({'0','10','20','30','40','50','60','70'});      % for OEF

% label the data
if CSF_data
%     xticklabels({'FLAIR','R_2'' fit','T_1 seg.','T_2 seg.','T_2 biexp.'});
    xticklabels({'FP R2e=4','NF R2e=4','FP R2e=0.5','NF R2e=0.5'});
else
%     xticklabels({'L. Model','1C. Model','2C. Model'});
    xticklabels({'Uncorrected','Constant \alpha','Constant \alpha,\beta','\alpha(OEF), Constant \beta'});
end

% Add Significance Information
HD = sigstar(grps,pvls,1);
set(HD,'Color','k')
set(HD(:,2),'FontSize',16);

