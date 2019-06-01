% xCompareGrids.m
%
% For comparing marginalized distributions from grid search, specifically to see
% whether DBV is more or less uncertain depending on whether the OEF-DBV or
% R2'-DBV model is used.
%
% MT Cherukara
% 29 May 2019

clear;
close all;
setFigureDefaults;

% load OEF data
load('Grid_Results/Grid_190529_OEF.mat');
posO = pos;

% load R2' data
load('Grid_Results/Grid_190529_R2p.mat');
posR = pos;
DBV = 100*pv2;

% marginalize, exponentialize, and normalize
sposO = sum(exp(posO),1);
sposR = sum(exp(posR),1);

sposO = sposO./max(sposO);
sposR = sposR./max(sposR);

% Plot
figure;
plot(DBV,sposO);
hold on; box on; grid on; axis square;
plot(DBV,sposR);
xlabel('DBV (%)');
ylabel('Likelihood (a.u.)');
legend('OEF Model','R2'' Model');

% Results
%
% OEF Gaussian fit: Mean=2.78, Var=1.10, SD=1.05
% R2' Gaussian fit: Mean=3.02, Var=1.30, SD=1.14