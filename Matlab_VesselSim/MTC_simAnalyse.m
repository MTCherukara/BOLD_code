% MTC_simAnalyse.m

% Analysis of vessel simulation data

% MT Cherukara
% Created 7 February 2017

clear;
close all;

% optional arguments
includeT2 = 1;  % include T2 elements
NormMean  = 1;  % normalise plots

%% Load data
[dataname,datadir] = uigetfile('*.mat','Select Vessel Simulation Dataset...');
load(strcat(datadir,dataname));

%% Calculate without T2
% calculate the mean and standard deviation of both
meanu = mean(sASE_u,2);
meann = mean(sASE_n,2);
stdu = std(sASE_u,[],2);
stdn = std(sASE_n,[],2);

% normalise
if NormMean
    meann = meann./meanu;   % means - normal-dist first
    meanu = meanu./meanu;   
    stdu = stdu./meanu;     % standard deviations
    stdn = stdn./meanu;
end

% variables for plotting things
xls = 1000*p.TE + 2;

%% plot data without T2 effects
figure(11)
errorbar(1000*tASE,meanu,stdu,'-','LineWidth',1.5); hold on;
errorbar(1000*tASE+1,meann,stdn,'--','LineWidth',1.5); % add an offset, so we can see them better
legend(['Y = ',num2str(p.Y)],'Y = N(0.7,0.1)','Location','North');
ylabel('Signal Normalised to Uniform Distribution');
xlabel('Spin Echo offset \tau (ms)');
set(gca,'FontSize',12);
title(['Y = ',num2str(p.Y),...
     ', R = ',num2str(p.R*1e6),'\mum',...
     ', D = ',num2str(p.D),'m^2/s',...
     ', T_2 = 0']);
 if NormMean
     axis([-xls, xls, 0.95, 1.05]);
 else
     axis([-xls, xls, 0, 1]);
 end


%% Calculate the same stuff, but with T2
if includeT2
    
    sASE_u  = zeros(round(500*p.TE)+1,length(X));
    sASE_n  = zeros(round(500*p.TE)+1,length(X));
    
    % calculate again
    for j = 1:10
        [sASE_u(:,j), ~   ]  = MTC_plotSignal(p,Phase_u(:,:,j),'sequence','ASE','display',false,'T2EV',0.11);
        [sASE_n(:,j), tASE]  = MTC_plotSignal(p,Phase_n(:,:,j),'sequence','ASE','display',false,'T2EV',0.11);
    end
    
    % calculate the mean and standard deviation of both
    meanu = mean(sASE_u,2); 
    meann = mean(sASE_n,2);
    stdu = std(sASE_u,[],2); 
    stdn = std(sASE_n,[],2);

    % normalise and scale
    if NormMean
        meann = meann./meanu;   % means - normal-dist first
        meanu = meanu./meanu;   
        stdu = stdu./meanu;     % standard deviations
        stdn = stdn./meanu;
    end
    
    % plot
    figure(12)
    errorbar(1000*tASE,meanu,stdu,'-','LineWidth',1.5); hold on;
    errorbar(1000*tASE+1,meann,stdn,'--','LineWidth',1.5); % add an offset, so we can see them better
    legend(['Y = ',num2str(p.Y)],'Y = N(0.7,0.1)','Location','North');
    ylabel('Signal Normalised to Uniform Distribution');
    xlabel('Spin Echo offset \tau (ms)');
    set(gca,'FontSize',12);
    title(['Y = ',num2str(p.Y),...
         ', R = ',num2str(p.R*1e6),'\mum',...
         ', D = ',num2str(p.D),'m^2/s',...
         ', T_2 = 110ms']);
     % set axis
     if NormMean
         axis([-xls, xls, 0.95, 1.05]);
     else
         axis([-xls, xls, 0, 1]);
     end
     
end