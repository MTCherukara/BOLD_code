% Anova_RunAll.m
%
% Takes the data created by Anova_LoadAllSubs.m and then does ANOVA on it. 
%
% MT Cherukara
% 18 June 2019

clear;

%% INITIALIZATION

% Parameter Name
pnames = {'R2p';'DBV';'OEF'};

% Set numbers
fsets = [876,846:5:871];
nsets = length(fsets);

% Set labels
lbls = {'FP-2C','NF-2C','NF-3C','NF-T1','NF-T2','NF-BF','NF-FC'};

% Which pairs of FSETS do we want to compare?
grps =  {[1,2],[1,3],[1,4],[1,5],[1,6],[1,7]};

% Matrix size - HARDCODED
nvox = 12682;

% Pre-allocate huge matrix
matAllData = zeros(nsets,length(pnames),nvox);

% Pre-allocate p-value results array
matPvals = zeros(length(pnames),length(grps));


%% LOAD EVERYTHING
for ss = 1:nsets
    
    % Load the data
    load(['Fabber_Data/AllSub_Data_',num2str(fsets(ss)),'.mat']);
    
    % Stick it in a huge matrix
    matAllData(ss,:,:) = vecAllData;
    
end % for ss = 1:nsets


%% NOW DO ANOVA FOR EACH PARAMETER
for pp = 1:length(pnames)
    
    % Pull out data
    matParData = squeeze(matAllData(:,pp,:));
    
    % ANOVA
    [~,~,daStats] = anova2(matParData',1,'off');
    daC = multcompare(daStats,'display','off');
    
    % Pull out p-values
    pvls = MC_pvalues(daC,grps);
    
    % Store p-values
    matPvals(pp,:) = pvls;
    
end % for pp = 1:length(pnames)


