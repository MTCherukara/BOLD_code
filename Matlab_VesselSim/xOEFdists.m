% xOEFdists.m
% 
% Analyzing some very OLD simulated OEF-distribution data
%
% MT Cherukara
% 16 July 2019

clear;

% timings
TE = 0.074;
tau = (-28:4:68)./1000;

% Load the data
load('newStoredPhase/VSdata_VesselDist_Average_Diff.mat');
ph_3s = Phase_u;

% Load the data
load('newStoredPhase/VSdata_VesselDist_Triple_Diff.mat');
ph_3d = abs(Phase_u);
NN = size(Phase_u,2);
DBV = sum(p.vesselFraction);

% Figure out important values
TEind = TE/p.deltaTE;
SEind = round((TE-tau)./(2.*p.deltaTE),0);

% Pre-allocate
PhaseS = zeros(length(tau),NN);
PhaseD = zeros(length(tau),NN);

% Pre-sum
cumPhaseS = cumsum(ph_3s,1);
cumPhaseD = cumsum(ph_3d,1);


% Calculate phase history
for kk = 1:length(tau)
    
    PhaseS(kk,:) = cumPhaseS(SEind(kk),:) - ( cumPhaseS(TEind,:)  - cumPhaseS(SEind(kk),:) );
    PhaseD(kk,:) = cumPhaseD(SEind(kk),:) - ( cumPhaseD(TEind,:)  - cumPhaseD(SEind(kk),:) );

end            

% Calculate ASE signal
sig0S = abs(sum(exp(-1i.*PhaseS),2)./NN);
shapeS = -log(sig0S)./DBV;
sigS = 1-(DBV.*shapeS);
sigS = sigS./max(sigS);

% Repeat for Diffusive
sig0D = abs(sum(exp(-1i.*PhaseD),2)./NN);
shapeD = -log(sig0D)./DBV;
sigD = 1-(DBV.*shapeD);
sigD = sigD./max(sigD);


%% Plot
figure;
plot(1000*tau,sigS,'-');
hold on; grid on; axis square;
plot(1000*tau,sigD,'-');
axis([-30,70,0.73,1.01]);
ylabel('Log (Signal)');
xlabel('Spin Echo Displacement \tau (ms)');
title('Diffusion')
legend('Single OEF','Multiple OEF','Location','SouthWest');
