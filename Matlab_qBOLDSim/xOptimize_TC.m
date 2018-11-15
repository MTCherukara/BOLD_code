% xOptimize_TC.m

% To optimize the value of Tc (the point of transition between the linear-
% exponential and quadratic-exponential regimes in the asymptotic qBOLD model).
% Using code from MTC_qASE.m and its subroutines.

% MT Cherukara
% 9 February 2018
%
% CHANGELOG:
%
% 2018-09-13 (MTC). NB: THIS SCRIPT NEEDS TO BE UPDATED TO REFLECT CHANGES TO
%       THE MODEL CALCULATION FUNCTIONS!!

clear;
% close all;

setFigureDefaults;

% constants 
params.B0   = 3.0;          % T         - static magnetic field
params.dChi = 2.64e-7;      % parts     - susceptibility difference
params.gam  = 2.67513e8;    % rad/s/T   - gyromagnetic ratio

% scan parameters 
TE  = 0.074;        % s         - echo time
% tau = linspace(-0.060,0.072,1000); % for visualising
tau = (-28:1:64)/1000; % for testing


% model fitting parameters
params.S0   = 100;          % a. units  - signal
params.R2t  = 1/0.087;      % 1/s       - rate constant, tissue
params.R2e  = 4;            % 1/s       - rate constant, extracellular
params.dF   = 5;            % Hz        - frequency shift
params.lam0 = 0.000;        % no units  - ISF/CSF signal contribution
params.zeta = 0.05;        % no units  - deoxygenated blood volume
params.OEF  = 0.25;        % no units  - oxygen extraction fraction
params.Hct  = 0.400;        % no units  - fractional hematocrit
params.geom = 0.3;          % no units  - quadratic regime geometry factor

params.dw   = (4/3)*pi*params.gam*params.dChi*params.Hct*params.OEF*params.B0;   
   

%% Calculate the Analytical tissue signal

OEFs = linspace(0.2,0.6,50);
DBVs = linspace(0.01,0.05,50);
TC_ideal = zeros(1,21);
DW_ideal = zeros(1,21);

for ii = 1:length(OEFs)
    
    params.OEF = OEFs(ii);
%     params.zeta = DBVs(ii);
    
    params.dw   = (4/3)*pi*params.gam*params.dChi*params.Hct*params.OEF*params.B0;   

    S_analytical = MTC_ASE_bessel(tau,TE,params);

    myfun = @(x) sum((S_analytical-MTC_ASE_tissue(tau,TE,params,x)).^2);

    DW_ideal(ii) = params.dw;
    TC_ideal(ii) = fminbnd(myfun,0.5,3.0);

%     disp([' OEF  = ',num2str(params.OEF)]);
%     disp([' DBV  = ',num2str(params.zeta)]);
%     disp([' Tc   = ',num2str(TC_ideal(ii))]);
    
end

%% Plot Ideal TC as a function of OEF or DBV
figure; hold on; box on;
% plot(OEFs,1000*1.5./DW_ideal,':');
% plot(OEFs,1000*1.7./DW_ideal,'--');
plot([0.2,0.6],[1.5,1.5],':');
plot([0.2,0.6],[1.7,1.7],'--');
ylim([1.45, 1.95]);
plot(OEFs,TC_ideal,'kx');
xlabel('OEF');
% ylabel('t_C (ms)');
ylabel('a,  where  t_C = a/\delta\omega');
% title(['OEF = ',num2str(100*params.OEF),'%']);
legend('a = 1.5','a = 1.7','Optimized a');


%% Plot Analytical and Asymptotic Solutions together

% S_analytical = MTC_ASE_bessel(tau,TE,params);
% S_asymptotic = MTC_ASE_tissue(tau,TE,params,1.7/params.dw);
% S_shrtregime = MTC_ASE_tissue(tau,TE,params,1.0);
% S_longregime = MTC_ASE_tissue(tau,TE,params,0);
% 
% 
% figure;
% hold on; box on;
% plot(1000*tau,log(S_analytical));
% plot(1000*tau,log(S_shrtregime));
% plot(1000*tau,log(S_longregime));
% plot(1000*tau,log(S_asymptotic));
% axis([-26, 26, -0.92, -0.80]);
% legend('Analytical','Short \tau','Long \tau','Asymptotic');
% xlabel('\tau (ms)');
% ylabel('Log Signal');
% title(['OEF = ',num2str(100*params.OEF),'%, DBV = ',num2str(100*params.zeta),'%']);


% Find areas of signifcant difference between asymptotic and analytical models
% S_diff = abs(S_analytical-S_asymptotic);
% S_diff = S_diff./S_analytical; % take ratio
% 
% figure;
% hold on; box on;
% plot(tau,S_diff);
% xlim([tau(1), tau(end)]);
% ylim([0, 7e-3]);
% 
% xlabel('\tau (s)');
% ylabel('Relative Signal Difference');
% title(['OEF = ',num2str(100*params.OEF),'%, DBV = ',num2str(100*params.zeta),'%']);
