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
OEF = pv1;

% load R2' data
load('Grid_Results/Grid_190529_R2p.mat');
posR = pos;
DBV = 100*pv2;
R2p = pv1;

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
%
% OEF distributuon:
%       Mean=41.1, SD=14.5 (35.3%)
%
% R2' distribution: 
%       Mean=4.30, SD=0.33 (7.7%)

%% Correlation analysis

% [gDBV, gOEF] = meshgrid(OEF,DBV);
% 
% vec_OEF = gOEF(:);
% vec_DBV = gDBV(:);
% vec_pos = posO(:);
% 
% [srt_pos, srt_ind] = sort(vec_pos,1,'descend');
% 
% npoints = 100000;
% 
% top_OEF = vec_OEF(srt_ind(1:npoints));
% top_DBV = vec_DBV(srt_ind(1:npoints));
% 
% [rh,pval] = corr(top_OEF,top_DBV);
% disp(['R = ',num2str(rh,3),' (p = ',num2str(pval,3),')']);
