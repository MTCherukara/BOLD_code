% Figure_PatientBars.m
%
% Plot a bar chart showing patient data. Based on barcharts_new.m
%
% MT Cherukara
% 8 August 2019


clear;
% close all;
setFigureDefaults;

%% Plotting Information

% choose patient number
pat_id = '104';

% choose which dimension to reduce (1 = pick a session, 2 = pick a correction)
dimred = 2;

% choose Session (1 = ses-001, 2 = ses-004) or a Correction
sesnum = 1;

% choose which masks we want
msks = [1,3,4];

% Mask labels
mask_labels = {'Initial Infarct','Final Infarct','Growth','Contralateral'};

% Load the Data
load(strcat('Fabber_Data/patient_',pat_id,'.mat'));

% Pull out the right masks
mlbls = mask_labels(msks);
matR2p = matR2p(msks,:,:);
matDBV = matDBV(msks,:,:);
matOEF = matOEF(msks,:,:);

% pull out the right session
if dimred == 1
    sesR2p = squeeze(matR2p(:,sesnum,:));
    sesDBV = squeeze(matDBV(:,sesnum,:));
    sesOEF = squeeze(matOEF(:,sesnum,:));
else
    sesR2p = squeeze(matR2p(:,:,sesnum));
    sesDBV = squeeze(matDBV(:,:,sesnum));
    sesOEF = squeeze(matOEF(:,:,sesnum));
end

% normalize to contralateral
sesOEF = 100*sesOEF./repmat(sesOEF(3,1),3,2);


%% Bar Chart Plotting

bpos = 1:length(msks);

% % Plot R2p
% figure; hold on; grid on;
% bar(bpos,sesR2p);
% box on;
% xticks(bpos);
% xticklabels(mlbls);
% if dimred == 1
%     legend('uncorr.','\kappa corr.','\kappa\eta corr.','Location','SouthEast');
% else
%     legend('Presentation','1 Week','Location','SouthEast');
% end
% ylabel('R_2'' (s^-^1)');
% title('Mean R2'' Estimates');
% xtickangle(330);

% % Plot DBV
% figure; hold on; grid on;
% bar(bpos,sesDBV);
% box on;
% xticks(bpos);
% xticklabels(mlbls);
% if dimred == 1
%     legend('uncorr.','\kappa corr.','\kappa\eta corr.','Location','SouthEast');
% else
%     legend('Presentation','1 Week','Location','SouthEast');
% end
% ylabel('DBV (%)');
% title('Mean DBV Estimates');
% xtickangle(330);

% Plot OEF
figure; hold on; grid on;
bar(bpos,sesOEF);
box on;
xticks(bpos);
xticklabels(mlbls);
ylim([40,160]);
if dimred == 1
    legend('uncorr.','\kappa corr.','\kappa\eta corr.','linear','Location','SouthEast');
else
    legend('Presentation','1 Week','Location','South');
end
ylabel('OEF (%)');
title('Mean OEF Estimates');
xtickangle(330);


