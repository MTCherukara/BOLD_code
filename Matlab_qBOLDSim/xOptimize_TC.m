function TC_ideal = xOptimize_TC

% To optimize the value of Tc (the point of transition between the linear-
% exponential and quadratic-exponential regimes in the asymptotic qBOLD model).
% Using code from MTC_qASE.m and its subroutines.

% MT Cherukara
% 9 February 2018
%
% CHANGELOG:
%
% 2019-04-02 (MTC). 
%
% 2019-01-?? (MTC). Updated, as below.
%
% 2018-09-13 (MTC). NB: THIS SCRIPT NEEDS TO BE UPDATED TO REFLECT CHANGES TO
%       THE MODEL CALCULATION FUNCTIONS!!

clear;
close all;

setFigureDefaults;

% Create a parameter structure
params = genParams;

% Scan
params.TE   = 0.084;        % s         - echo time
params.TR   = 3;
params.TI   = 0;
params.contr = 'OEF';
params.incT1 = 0;
params.incT2 = 1;
params.incIV = 1;

% Physiology
params.lam0 = 0.0;         % no units  - ISF/CSF signal contribution
params.zeta = 0.03;         % no units  - deoxygenated blood volume
params.OEF  = 0.40;         % no units  - oxygen extraction fraction

tau = (-16:1:64)/1000; % for testing


%% Calculate the Analytical tissue signal

np = 50;

% 50x50 narrower range
OEFs = 0.21:0.01:0.70;
DBVs = 0.003:0.003:0.15;
TC_ideal = zeros(np,np);
% DW_ideal = zeros(1,np^2);

% Load data from an already-generated dataset
simdir = '../../Data/vesselsim_data/';
datname = 'TE84_vsData_sharan_50.mat';

datIn = load([simdir,'vs_arrays/',datname]);
% datIn = load('ASE_Data/ASE_Grid_1C_50x50_Taus_11_SNR_500.mat');

% find tau indices
[~,Tind,~] = intersect(datIn.tau,tau);
SEind = 3;


for i2 = 1:length(DBVs)
    for i1 = 1:length(OEFs)

        params.OEF = OEFs(i1);
        params.zeta = DBVs(i2);

        % Calculate analytical model
%         params.model = 'Full';
%         S_analytical = qASE_model(tau,params.TE,params);
        S_analytical = squeeze(datIn.S0(i2,i1,Tind))';
%         S_analytical = squeeze(datIn.ase_data(i1,i2,:,Tind))';
        
        % normalize to spin echo
        S_analytical = S_analytical./S_analytical(SEind);

        % Calculate asymptotic model
%         params.model = 'Asymp';    

        myfun = @(x) sum((S_analytical-calcTissueAsymp(tau,params.TE,params,x)).^2);

    %     DW_ideal(ii) = params.dw;
        TC_ideal(i1,i2) = fminbnd(myfun,0.0,4.0);

    %     disp([' OEF  = ',num2str(params.OEF)]);
    %     disp([' DBV  = ',num2str(params.zeta)]);
    %     disp([' Tc   = ',num2str(TC_ideal(ii))]);

    end
end

% Average TC_ideal
TC_best = mean(TC_ideal(:));
disp(['Optimal TC = ',num2str(TC_best)]);

% The best TC is 1.756!!!!

%% Plot Ideal TC as a function of OEF
figure; hold on; box on;
% plot(OEFs,1000*1.5./DW_ideal,':');
% plot(OEFs,1000*1.7./DW_ideal,'--');
plot([20,70],[1.5,1.5],':');
plot([20,70],[TC_best,TC_best],'--');
% ylim([1.49, 1.81]);
plot(100*OEFs,mean(TC_ideal,1),'kx');
xlabel('OEF (%)');
ylabel('Transition Constant (\delta\omega . \tau)');
% ylabel('a,  where  t_C = a/\delta\omega');
% title(['OEF = ',num2str(100*params.OEF),'%']);
% legend('a = 1.5','a = 1.7','Optimized a');

% DBV
figure; hold on; box on;
plot([0.3,15],[1.5,1.5],':');
plot([0.3,15],[TC_best,TC_best],'--');
% ylim([1.49, 1.81]);
plot(100*DBVs,mean(TC_ideal,2),'kx');
xlabel('DBV (%)');
ylabel('Transition Constant (\delta\omega . \tau)');
% ylabel('a,  where  t_C = a/\delta\omega');
% title(['OEF = ',num2str(100*params.OEF),'%']);
% legend('a = 1.5','a = 1.7','Optimized a');

% Surface
figure; hold on;
surf(100*OEFs,100*DBVs,TC_ideal);
view(2); shading flat; axis tight;
axis square; box on;
colorbar;
xlabel('OEF (%)');
ylabel('DBV (%)');

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

end


function ST = calcTissueAsymp(TAU,TE,PARAMS,TC)
    
    DBV = PARAMS.zeta;
    dw  = (4/3)*pi*PARAMS.gam*PARAMS.B0*PARAMS.dChi*PARAMS.Hct*PARAMS.OEF;
    R2p = dw .* DBV;
    
    ST = zeros(1,length(TAU));
    
    for ii = 1:length(TAU)
        
        if abs(TAU(ii)) < (TC/dw)
            % Short tau regime
            ST(ii) = exp(-(0.3.*(R2p.*TAU(ii)).^2)./DBV);
            
        else
            % Long tau regime
            ST(ii) = exp(DBV - (0.52.*R2p.*abs(TAU(ii))));
        end
    end
    
%     ST = PARAMS.S0.*ST.*exp(-PARAMS.R2t.*TE);
    
    ST = ST./ST(3);
end