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
fsets = [801:5:831];
nsets = length(fsets);

% Set labels
lbls = {'FP-2C','NF-2C','NF-3C','NF-T1','NF-T2','NF-BF','NF-FC'};

% Which pairs of FSETS do we want to compare?
grps =  {[1,2],[1,3],[1,4],[1,5],[1,6],[1,7]};

% Matrix size - HARDCODED
% nvox = 12682;       % 80% GM, slices 3:8
% nvox = 13262;       % 80% GM, slices 2:6
% nvox = 12145;       % 95% GM, slices 2:6
nvox = 3780;        % 20% CSF in 60% GM, slices 2:8 (AllSub_Data_CSF_20...)

% Pre-allocate huge matrix
matAllData = zeros(nsets,length(pnames),nvox);

% Pre-allocate p-value results array
matPvals = zeros(length(pnames),length(grps));

% thresholds
threshes = containers.Map({'R2p', 'DBV', 'OEF', 'VC', 'DF', 'lambda', 'Ax' , 'R2'},...
                          [ 30  ,  1   ,  1   ,  1  ,  15 ,   1     ,  30  ,  50 ]);  


%% LOAD EVERYTHING
for ss = 1:nsets
    
    % Load the data
    load(['Fabber_Data/AllSub_Data_CSF_20_',num2str(fsets(ss)),'.mat']);
    
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


%% NOW RUN DABEST (FSCATJIT2)
% for pp = 3%:length(pnames)
%     
%     % parameter name
%     pname = pnames{pp};
%     
%     % Pull out data
%     matParData = squeeze(matAllData(:,pp,:));
%     
%     % Make two long vectors
%     vecParData = zeros(nsets*nvox,1);
%     vecParSets = zeros(nsets*nvox,1);
%     
%     % Create indices
%     i1 = 1;
%     i2 = nvox;
%     
%     % Loop through sets, filling in the vectors
%     for ss = 1:nsets
%         
%         vecParData(i1:i2) = matParData(ss,:);
%         vecParSets(i1:i2) = repmat(ss,nvox,1);
%         
%         % update indices for next time
%         i1 = i1 + nvox;
%         i2 = i2 + nvox;
%         
%     end
%     
%     % Threshold out ridiculous values
%     thrs = threshes(pname);
%     
%     % indices that exceed the threshold
%     vecBad = vecParData > thrs;
%     
%     % Remove bad values
%     vecParData(vecBad == 1) = [];
%     vecParSets(vecBad == 1) = [];
%         
%     
% %     % Data array
% %     arrData = table2array(vecParData);
% %     
% %     % Indentifiers array
% %     arrIdentifiers = table2array(char(vecParSets));
%     
%     % Run FSCATJIT2
%     fsresult = FscatJit2(vecParSets,vecParData);
%     
% end % for pp = 1:length(pnames)


