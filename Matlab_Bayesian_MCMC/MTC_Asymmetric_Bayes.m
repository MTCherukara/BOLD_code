% MTC_Asymmetric_Bayes.m
% Perform Bayesian inference on ASE/BOLD data from MTC_qBOLD.m
%
% Based on MTC_Bayes_BOLD.m

% MT Cherukara
% 16 May 2016 (origin)

clear;
% close all;
tic;
%% Load Data - use 20-May-2016
load('ASE_Data_04.mat');

sigma = params.sig;   % real std of noise
sigma_weight = 2/(sigma.^2);

ns = length(S_sample); % number of data points
np = 1000; % number of points to perform Bayesian analysis on

% remove CSF component
params.lam0 = 0;

[~,t0] = min(abs(T_sample));    % index of zero-point
% normalize S_sample, if this hasn't been done already
S_sample = S_sample./S_sample(t0);

%% Bayesian inference on a single parameter using 1D grid search
% 
% v_t = 0.03; % true value of OEF
% va = linspace(0,0.1,np); % OEF must be in interval {0,1}
% S_model = zeros(np,ns);
% 
% % step through values of the parameter and calculate the model for each one
% % of those, at all time points
% for ii = 1:np
%     params.zeta = va(ii);
%     S_val = MTC_qASE_model(T_sample,params);
%     S_model(ii,:) = S_val./S_val(t0);
% end
% 
% S_samp = repmat(S_sample,np,1);
% 
% % compare the model against the data for each value of the parameter - this
% % is the likelihood (which is proportional to the posterior in the case of
% % uniform (zero) priors)
% lik = exp(-sum((S_samp-S_model).^2,2)/sigma);
% % lik = lik/sum(lik); % normalize
% 
% % plot posterior (=likelihood) distribution
% figure(1);
% plot([v_t, v_t],[0, 1.1*max(lik)],'r-','LineWidth',2); hold on;
% plot(va,lik,'k-','LineWidth',2);
% axis([min(va), max(va), 0, 1.1*max(lik)]);
% xlabel('Deoxygenated Blood Volume (DBV)');
% % xlabel('Oxygen Extraction Fraction (OEF)');
% % xlabel('Fractional Hematocrit Hct');
% ylabel('Posterior Distribution');
% % title(['ASE. OEF = 0.5, SNR = ',num2str(1/sigma)])
% % title(['ASE. \zeta = 0.03, SNR = ',num2str(1/sigma)])
% set(gca,'FontSize',16);

%% Bayesian Inference on two parameters, using grid search

tr1 = params.OEF;  % real value of OEF = 0.5
tr2 = params.zeta; % real value of zeta = 0.03;

w1 = linspace(0.1,0.7,np);
w2 = linspace(0,0.1,np);

pos = zeros(np,np);

for i1 = 1:np
%     disp(['Calculating iteration ',num2str(i1),' of ',num2str(np)]);
    
    for i2 = 1:np

            params.OEF = w1(i1);
            params.zeta = w2(i2);

            S_mod = MTC_qASE_model(T_sample,params);
            S_mod = S_mod./S_mod(t0);

            pos(i1,i2) = exp(-sum((S_sample-S_mod).^2)./(sigma));
    end
end

% pos = pos/sum(pos(:)); % normalize posterior
toc;
% plot
figure();
imagesc(w2,w1,pos); hold on; colorbar;
plot([tr2,tr2],[  0, 30],'w-','LineWidth',2);
plot([  0, 30],[tr1,tr1],'w-','LineWidth',2);
ylabel('Oxygen Extraction Fraction (OEF)');
xlabel('Deoxygenated Blood Volume (DBV)');
title(['SNR = ',num2str(1/sigma)]);
axis([min(w2),max(w2),min(w1),max(w1)]);
set(gca,'FontSize',16,'YDir','normal');
set(gcf,'WindowStyle','docked');

