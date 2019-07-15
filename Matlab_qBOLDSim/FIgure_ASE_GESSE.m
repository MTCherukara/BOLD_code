% Figure_ASE_GESSE.m
%
% Plots some example ASE and GESSE curves, with the same parameters, using the
% models in He and Yablonskiy (2007)
%
% MT Cherukara
% 15 July 2019

clear;
close all;

setFigureDefaults;

% Parameters
OEF = 0.40;
DBV = 0.03;
TE  = 0.084;


%% Make ASE Data
% Create SDR-ASE data
param = genParams('incIV',false,'incT2',true,...
                  'Model','Full','TE',TE,...
                  'OEF',0.40,'DBV',0.042);
              
param.R2t = param.R2t.*0.1;
              
% Make the data 
tmod = linspace(-16,64)./1000;
S_ASE = qASE_model(tmod,TE,param);
S_ASE = S_ASE./max(S_ASE);

% Plot ASE
figure;
plot(1000*tmod,(S_ASE),'-','LineWidth',2);
axis square;
xlim([-16,64]);
ylim([0.7,1.02]);
yticks([1]);
yticklabels({'S_0'});

xlabel('Spin Echo Displacement \tau (ms)');
ylabel('ASE Signal');


%% Make GESSE Data

% times
TE = 0.032;
tt = linspace(0,80)./1000;

dw = param.dw;

% Calculate GESSE
fint = zeros(1,length(tt));    % pre-allocate

for ii = 1:length(tt)
    
    if tt(ii) <= (TE/2)
        
        t0 = tt(ii).*dw;
        
    else
        
        t0 = (tt(ii)-TE).*dw;
    
    end

    % integrate
    fnc0 = @(u) (2+u).*sqrt(1-u).*(1-besselj(0,1.5*t0.*u))./(u.^2);
    fint(ii) = integral(fnc0,0,1);
        
end

S_GESSE = exp(-DBV.*fint./3).*exp(-param.R2t.*tt);
S_GESSE = S_GESSE./max(S_GESSE);

% Plot GESSE
figure;
plot(1000*tt,(S_GESSE),'-','LineWidth',2);
axis square;
xlim([0,80]);
ylim([0.75,1.02]);
yticks([1]);
yticklabels({'S_0'});

xlabel('Time (ms)');
ylabel('GESSE Signal');
