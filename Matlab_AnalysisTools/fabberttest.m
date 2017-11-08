% fabberttest.m
% does a t test between two fabber datasets
% MT Cherukara

clear;

% specify this stuff
dname = '/gm_DBV.nii.gz';
fab1 = '114';
fab2 = '117';

% load the data
resdir = '/Users/mattcher/Documents/DPhil/Data/Fabber_Results/';
fdn1 = dir([resdir,'fabber_',fab1,'_*']);
fdn2 = dir([resdir,'fabber_',fab2,'_*']);
data1 = LoadSlice([resdir,fdn1.name,dname]);
data2 = LoadSlice([resdir,fdn2.name,dname]);

data1 = abs(data1(:));
data2 = abs(data2(:));
mpoints = all([data1,data2],2);

data1 = data1(mpoints);
data2 = data2(mpoints);

[H1,P1] = ttest(data1,data2);
[H2,P2] = ttest2(data1,data2);
disp(['Unpaired two-sample t-test. P = ',num2str(P2)]);
disp(['Paired t-test. P = ',num2str(P1)]);