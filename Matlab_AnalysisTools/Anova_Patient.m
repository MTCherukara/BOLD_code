% Anova_Patient.m
%
% Perform unbalanced ANOVA on patient data, comparing three regions (Initial
% ROI, Growth, and Contralateral)
%
% MT Cherukara
% 9 August 2019

clear;
% close all;
setFigureDefaults;


%% OPTIONS

% Choose FABBER dataset
setnum = 225;
tstr = 'Patient 5 \kappa,\eta-Corrected';

% Choose variable 
vname = 'OEF';

% Thresholds
threshes = containers.Map({'R2p', 'DBV', 'OEF', 'VC', 'DF', 'lambda', 'Ax' , 'R2'},...
                          [ 30  ,  0.5  ,  1   ,  1  ,  15 ,   1     ,  30  ,  50 ]);  

% Define which groups (of masks) we want to compare
grps = {[1,2],[2,3],[1,3]};

oneset = 1;


%% LOAD DATA

% Results directory
resdir = '/Users/mattcher/Documents/DPhil/Data/Fabber_Results/';

% Figure out the results directory we want to load from
fdname = dir([resdir,'fabber_',num2str(setnum),'_*']);
fabdir = strcat(resdir,fdname.name,'/');

slicenum = 1:8;

CC = strsplit(fabdir,'_p');     % need a 3-digit subject number
subnum = CC{2}(1:3);
C2 = strsplit(CC{2},'ses');     % also need a Session Number (1,5)
sesnum = C2{2}(1);

maskdir = ['/Users/mattcher/Documents/BIDS_Data/qbold_stroke/sourcedata/sub-',...
    subnum,'/ses-00',sesnum,'/func-ase/'];

% Load three masks
mskInit = LoadSlice([maskdir,'mask_initROI.nii.gz'],slicenum);
mskGrow = LoadSlice([maskdir,'mask_growth.nii.gz'],slicenum);
mskCont = LoadSlice([maskdir,'mask_finalROI.nii.gz'],slicenum);

% Load the data
volData = LoadSlice([fabdir,'mean_',vname,'.nii.gz'],slicenum);

% Pull out threshold value
thrsh = threshes(vname);

% Apply mask and vectorize
vecInit = abs(volData(:).*mskInit(:));
vecGrow = abs(volData(:).*mskGrow(:));
vecCont = abs(volData(:).*mskCont(:));

% Labels
vecLabs = [1*ones(length(vecInit),1); ...
           2*ones(length(vecGrow),1); ...
           3*ones(length(vecCont),1)];
       
% Collect the data together
vecData = [vecInit; vecGrow; vecCont];

% Identify bad voxels
badData = (vecData <= 0) + ~isfinite(vecData) + (vecData > thrsh);

% Remove bad voxels
vecData(badData ~= 0) = [];
vecLabs(badData ~= 0) = [];


%% DO STATISTICS
if oneset

    % Group mean and STD
    dataMean = [mean(vecData(vecLabs==1)), mean(vecData(vecLabs==2)), mean(vecData(vecLabs==3))];
    dataStd  = [std(vecData(vecLabs==1)), std(vecData(vecLabs==2)), std(vecData(vecLabs==3))];

    % ANOVA
    [~,~,A_stats] = anovan(vecData,vecLabs,'display','off');

    c_O = multcompare(A_stats,'display','off');

    p_O = MC_pvalues(c_O,grps);


    % Plot a bar chart
    mask_labels = {'Initial Infarct','Growth','Contralateral'};

    figure; hold on; grid on;
    bar(1:3,100*dataMean,0.6);
    box on;
    xlim([0.5,3.5]);
    ylabel('OEF (%)');
    xticks(1:3);
    xticklabels(mask_labels);
    ylim([0,60]);
    title(tstr);


    % Significance
    HO = sigstar(grps,p_O,1);
    set(HO,'Color','k')
    set(HO(:,2),'FontSize',18);
    axis square;



else
    %% LOAD THE SECOND DATASET
    
    % Choose FABBER dataset
    setnum = setnum + 1;


    % Figure out the results directory we want to load from
    fdname = dir([resdir,'fabber_',num2str(setnum),'_*']);
    fabdir = strcat(resdir,fdname.name,'/');

    slicenum = 1:8;

    CC = strsplit(fabdir,'_p');     % need a 3-digit subject number
    subnum = CC{2}(1:3);
    C2 = strsplit(CC{2},'ses');     % also need a Session Number (1,5)
    sesnum = C2{2}(1);

    maskdir = ['/Users/mattcher/Documents/BIDS_Data/qbold_stroke/sourcedata/sub-',...
        subnum,'/ses-00',sesnum,'/func-ase/'];

    % Load three masks
    mskInit = LoadSlice([maskdir,'mask_initROI.nii.gz'],slicenum);
    mskGrow = LoadSlice([maskdir,'mask_growth.nii.gz'],slicenum);
    mskCont = LoadSlice([maskdir,'mask_contraGM.nii.gz'],slicenum);

    % Load the data
    volData = LoadSlice([fabdir,'mean_',vname,'.nii.gz'],slicenum);

    % Pull out threshold value
    thrsh = threshes(vname);

    % Apply mask and vectorize
    vecInit = abs(volData(:).*mskInit(:));
    vecGrow = abs(volData(:).*mskGrow(:));
    vecCont = abs(volData(:).*mskCont(:));


    %% EXTEND THE DATA AND LABELS MATRICES

    % Labels
    vecLabs = [vecLabs; ...
               4*ones(length(vecInit),1); ...
               5*ones(length(vecGrow),1); ...
               6*ones(length(vecCont),1)];

    % Collect the data together
    vecData = [vecData; vecInit; vecGrow; vecCont];

    % Identify bad voxels
    badData = (vecData <= 0) + ~isfinite(vecData) + (vecData > thrsh);

    % Remove bad voxels
    vecData(badData ~= 0) = [];
    vecLabs(badData ~= 0) = [];

    % Normalize
    m1 = mean(vecData(vecLabs==3));
    m2 = mean(vecData(vecLabs==6));

    vecDataN = [vecData(vecLabs<3.5)./m1; vecData(vecLabs>3.5)./m2];
    % 
    % vecData(vecLabs<3.5) = vecData(vecLabs<3.5)./m1;
    % vecData(vecLabs>3.5) = vecData(vecLabs>3.5)./m2;



    %% NOW DO MORE ANOVA

    % grps = {[1,2], [2,3], [1,3], [4,5], [5,6], [4,6], [1,4], [2,5]};
    grps = {[2,3], [1,3], [4,5], [1,4], [2,5]};

    [~,~,A_stats] = anovan(vecDataN,vecLabs,'display','off');

    c_O = multcompare(A_stats,'display','off');

    p_O = MC_pvalues(c_O,grps);

    % disp(p_O' < 0.05)


    %% BOX PLOTS

    clrs = [ 0, 0, 0; ...
             0.0433, 0.7411, 0.7394; ...
             0.7945, 0.2758, 0.4731 ];

    figure;
    boxplot(100*vecData,vecLabs,'Symbol','','Colors',clrs);
    hold on; box on; 
    ylabel('OEF (%)');
    ylim([0,100]);
    title('Patient 5');
    xticklabels({'','Presentation','','','Follow-up',''});
    % xticklabels({'P-Initial','P-Growth','P-Contra','F-Initial','F-Growth','F-Contra'});
    % xtickangle(315);

    HO = sigstar(grps,p_O,1);
    set(HO,'Color','k')
    set(HO(:,2),'FontSize',18);

    axis square;
end