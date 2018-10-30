% xCompareErrors.m

% Load some error surfaces and compare them

clear;
% close all;

setFigureDefaults;

% Load the first error
load('Grid_Results/ErrOEF_84_LinearCorr.mat');
err_1 = errs;
est_1 = ests;
rel_1 = rel_err;

% Load the second error
load('Grid_Results/ErrOEF_84_ExpCorr.mat');
err_2 = errs;
est_2 = ests;
rel_2 = rel_err;

rdiff = rel_2 - rel_1;

% Dimensions:   OEF, DBV

% Key datapoints for comparing
% OEF(52): 40 %    	OEF(88): 55 %       OEF(16): 25   %
% DBV(67):  5 %     DBV(18):  2 %       DBV(92):  6.5 % 

plotGrid(100*rdiff,DBVvals,OEFvals,'cvals',[-50,50]);

disp(['Average error 1:  ',num2str(100*mean(rel_1(:)))]);
disp([' OEF 40, DBV 5  : ',num2str(100*rel_1(52,67))]);
disp([' OEF 55, DBV 2  : ',num2str(100*rel_1(88,18))]);
disp([' OEF 25, DBV 6.5: ',num2str(100*rel_1(16,92))]);

disp(' ');
disp(['Average error 2:  ',num2str(100*mean(rel_2(:)))]);
disp([' OEF 40, DBV 5  : ',num2str(100*rel_2(52,67))]);
disp([' OEF 55, DBV 2  : ',num2str(100*rel_2(88,18))]);
disp([' OEF 25, DBV 6.5: ',num2str(100*rel_2(16,92))]);