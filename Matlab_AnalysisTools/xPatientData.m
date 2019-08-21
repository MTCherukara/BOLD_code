% xPatientData.m
%
% Combine and analyse all the patient data
%
% MT Cherukara
% 8 August 2019

clear;
% close all;
setFigureDefaults;

%% LOAD THE DATA

% Subjects
snames = {'100','104','180','182','183'};

% Mask labels
mask_labels = {'Initial Infarct','Final Infarct','Growth','Contralateral'};

% number of subjects
ns = length(snames);

% pre-allocate
% DIMS:         MASKS x SESSIONS x CORRETIONS x SUBJECTS
matR2p_all = zeros(4,2,4,ns);
matDBV_all = zeros(4,2,4,ns);
matOEF_all = zeros(4,2,4,ns);

% loop through and load all the data
for ss = 1:ns
        
    load(strcat('Fabber_Data/patient_',snames{ss},'.mat'));

    matR2p_all(:,:,:,ss) = matR2p;
    matDBV_all(:,:,:,ss) = matDBV;
    matOEF_all(:,:,:,ss) = matOEF;
    
end


%% Line Graph comparing OEF values
msks = [1,3,4];
corr = 1;
mnames = mask_labels(msks);
nm = length(msks);

valsOEF = squeeze(matOEF_all(msks,1,corr,:));

% Plot
figure; hold on;
plot(1:nm,valsOEF,'o-','MarkerSize',10);
grid on; box on;

xticks(1:nm);
xticklabels(mnames);
xlim([0.6,nm+0.4]);
ylabel('OEF (%)');
ylim([10,76]);


% ANOVA
grps = {[1,2],[2,3],[1,3]};
[~,~,stat_OEF] = anova2(valsOEF',1,'off');
c_O = multcompare(stat_OEF,'display','off');
p_O = MC_pvalues(c_O,grps);

% Significance
HO = sigstar(grps,p_O,1);
set(HO,'Color','k')
set(HO(:,2),'FontSize',18);
axis square;


%% The same line graph, but normalized to the Contralateral value

% valsOEF = 100*valsOEF./repmat(valsOEF(3,:),3,1);
% 
% % Plot
% figure; hold on;
% plot(1:nm,valsOEF,'o-','MarkerSize',10);
% grid on; box on;
% 
% xticks(1:nm);
% xticklabels(mnames);
% xlim([0.6,nm+0.4]);
% ylabel('Relative OEF (%)');
% ylim([95,165]);
% axis square;
