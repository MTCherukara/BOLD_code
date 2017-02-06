% Analysis of Bayes results

clear; close all;

load('Bayes_4var_10k.mat');
SAMPLES = SAMPLES(:,2:end);
npar = size(SAMPLES,1);

X0 =     [0.5, 0.1, 10,  0.5]; % starting points for OEF, lambda, R2t, S0
LIMITS = [  0,   0,  1,  0 ;...
            1,   1, 50,  2 ]; 

var_name = {'OEF','lambda','R2t','S0'};
h_data = zeros(npar,25);
h_pos  = zeros(npar,25);

for ff = 1:npar
    [h_data(ff,:),h_pos(ff,:)] = hist(SAMPLES(ff,:),25);
end

figure('units','normalized','outerposition',[0.0 0.2 (0.25*npar) 0.6]);
for f2 = 1:npar
    subplot(1,npar,f2);
    plot(h_pos(f2,:),h_data(f2,:),'r-','LineWidth',2);
    ylabel('Posterior Distribution');
    xlabel(var_name{f2});
    set(gca,'FontSize',16);
end
