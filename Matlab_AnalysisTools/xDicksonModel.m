% xDicksonModel.m

% testing the phenomenological qBOLD model given by Dickson et al., (2011), and
% adapting it for ASE (as opposed to GESSE)

clear;
% close all;
setFigureDefaults;


%% Fixed Values

% acquisition parameters
TE  = 80;   % ms
% tau = linspace(-28,64,1000);    % ms
tau = -28:1:64;

% model parameters of importance
zeta = 0.03;
OEF  = 0.40;
T2   = 87;   % ms


%% Model


% values of the coefficients (given by Dickson, for FID):
% B11 =  55.385;
% B12 =  52.719;
% B13 = -0.0242;
% B21 =  35.314;
% B22 =  34.989;
% B23 = -0.0034;
% B31 =  0.3172;
% B32 =  0.3060;
% B33 =  3.1187;

B11 =  56.180;
B12 =  53.667;
B13 = -0.0212;
B21 =  34.891;
B22 =  35.087;
B23 = -0.0035;
B31 =  0.1407;
B32 =  0.3487;
B33 =  2.4672;


% Calculate second order coefficients
A1 = OEF*(B11 - (B12 * exp(-B13*OEF)));
A2 = OEF*(B21 - (B22 * exp(-B23*OEF)));
A3 = OEF*(B31 - (B32 * exp(-B33*OEF)));

% Calculate F
F = ( A1.*(exp(-A2.*abs(tau)) - 1) ) + (A3.*abs(tau));

% Calculate ST
ST = exp(-zeta.*F);

% Add R2 decay
% ST = ST.*exp(-TE./T2);

% ST = log((ST)./max(ST));

%% Plot ASE

figure(2);
plot(tau,ST,'-'); hold on;

legend(['OEF=',num2str(100*OEF),'%, DBV=',num2str(100*zeta),'%'],...
       'Location','SouthWest');
ylabel('ASE Signal [a.u.]');
xlabel('Spin Echo Displacement \tau (ms)');
title('Dickson Phenomenological Model');
xlim([min(tau)-4,max(tau)+4]);
ylim([0.84,1.01]);


%% Random timeline stuff
% 
% % Calculate ST
%
% tt  = linspace(-0,80,1000);
% 
% S1 = exp(-zeta.*A1.*(exp(-A2.*tt) - 1));
% S2 = exp(-zeta.*A3.*tt);
% SR2 = exp(-tt./T2);
% 
% ST = S1.*S2;
% 
% % find the TE point
% TE_ind = find(tt<((TE-tau)/2),1,'last');
% 
% % Flip ST at TE/2
% 
% STF = (exp(-zeta.*A1.*(exp(-A2.*abs(tt-(TE-tau))) - 1)).*exp(-zeta.*A3.*abs(tt-(TE-tau))));
% ST(TE_ind:end) = STF(TE_ind:end);
% 
% ST2 = ST.*SR2;
% 
% % add T2 effect
% % ST = ST.*exp(-R2t.*abs(tau));
% % SN = SN.*exp(-R2t.*abs(tau));
% 
% %% Plot 
% figure;
% 
% % signal
% plot(tt,ST,'-'); hold on;
% % plot(tt,S1,'--');
% % plot(tt,S2,'--');
% plot(tt,ST2,'-');
% % plot(tt,SR2,'--');
% 
% % ASE lines
% plot([(TE-tau)/2,(TE-tau)/2],[0,2],'k:','LineWidth',1);
% plot([TE,TE],[0,2],'k-','LineWidth',2);
% 
% axis([0,max(tt),0,1.1]);
% 
% % legend('Full signal','Double exponential','Exponential decay','Signal w/ R2 decay','R2 decay','Location','SouthWest');
% legend('Reversible Signal','Signal inc. R_2 decay','Location','SouthWest');
% xlabel('Time (ms)');
% ylabel('Magnetization');
% title(['Dickson Model (TE=',num2str(TE),'ms, \tau=',num2str(tau),'ms)']);
% % ylim([0.4,1.0]);