% xErrorTTest.m
%
% Load two sets of simulated error data and do a t-test between them
%
% MT Cherukara
% 30 July 2019

clear;

%% Load the data

% Distname
dname = 'Lauwers';

% Error Set 1
load(['Errors_',dname,'Unc.mat']);
err_R2p_1 = err_R2p;
err_DBV_1 = err_DBV;
err_OEF_1 = err_OEF;

% Error Set 2
load(['Errors_',dname,'Kappa.mat']);
err_R2p_2 = err_R2p;
err_DBV_2 = err_DBV;
err_OEF_2 = err_OEF;

% Error Set 3
load(['Errors_',dname,'KappaEta.mat']);
err_R2p_3 = err_R2p;
err_DBV_3 = err_DBV;
err_OEF_3 = err_OEF;

% Error Set 4
load(['Errors_',dname,'Tan.mat']);
err_R2p_4 = err_R2p;
err_DBV_4 = err_DBV;
err_OEF_4 = err_OEF;


%% Put it all together
% Figure out min length
l_min = min([length(err_OEF_1),length(err_OEF_2),length(err_OEF_3),length(err_OEF_4)]);

% Put it all together
all_R2p = [err_R2p_1(1:l_min), err_R2p_2(1:l_min), err_R2p_3(1:l_min)];
all_DBV = [err_DBV_1(1:l_min), err_DBV_2(1:l_min), err_DBV_3(1:l_min)];
all_OEF = [err_OEF_1(1:l_min), err_OEF_2(1:l_min), err_OEF_3(1:l_min), err_OEF_4(1:l_min)];


%% DO ANOVA
grps = {[1,2],[1,3],[2,3]};

% R2p
[~,~,stat_R2p] = anova2(all_R2p,1,'off');
c_R = multcompare(stat_R2p,'display','off');
p_R = MC_pvalues(c_R,grps);

% DBV
[~,~,stat_DBV] = anova2(all_DBV,1,'off');
c_D = multcompare(stat_DBV,'display','off');
p_D = MC_pvalues(c_D,grps);

% OEF
[~,~,stat_OEF] = anova2(all_OEF,1,'off');
c_O = multcompare(stat_OEF,'display','off');
p_O = MC_pvalues(c_O,{[1,2],[1,3],[1,4],[2,3],[3,4]});



%% Do t-tests
% [~,pR2p] = ttest2(err_R2p_1,err_R2p_2,'vartype','unequal');
% [~,pDBV] = ttest2(err_DBV_1,err_DBV_2,'vartype','unequal');
% [~,pOEF] = ttest2(err_OEF_1,err_OEF_2,'vartype','unequal');
% 
% % Display results
% disp(['R2'' error p-value: ',num2str(pR2p)]);
% disp(['DBV error p-value: ' ,num2str(pDBV)]);
% disp(['OEF error p-value: ' ,num2str(pOEF)]);

