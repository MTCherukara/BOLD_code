% xCalcErrors.m

% load some ASE signal results and calculate the error between them...


clear;

dataname = 'signalResults/VS_Signal_31-Aug-2017_';

for ii = 1:34
    load([dataname,num2str(ii),'_ASE.mat']);
    
    allsig(:,ii) = sig;
end

sigm = mean(allsig,2);
sige = std(allsig,0,2);
save('signalResults/VSsignal_Convergence2','p','allsig','t');