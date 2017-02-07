% MTC_simAnalyse.m

% Analysis of vessel simulation data

% MT Cherukara
% Created 7 February 2017

% clear;

% optional arguments
includeT2 = 1;

[dataname,datadir] = uigetfile('*.mat','Select Vessel Simulation Dataset...');
load(strcat(datadir,dataname));


%% compare normalized differences with errorbars, without T2
meanu = mean(sASE_u,2); % calculate the mean
meann = mean(sASE_n,2);
meann = meann./meanu;   % normalise it - normal-dist first
meanu = meanu./meanu;   

stdu = std(sASE_u,[],2);    % calculate standard deviation
stdn = std(sASE_n,[],2);
stdu = stdu./meanu;         % normalise it
stdn = stdn./meanu;

%% plot data without T2 effects
figure(11)
errorbar(1000*tASE,meanu,stdu,'-','LineWidth',1.5); hold on;
errorbar(1000*tASE+1,meann,stdn,'--','LineWidth',1.5); % add an offset, so we can see them better
axis([-62 62 0.95 1.05])
legend(['Y = ',num2str(p.Y)],'Y = N(0.7,0.1)','Location','North');
ylabel('Signal Normalised to Uniform Distribution');
xlabel('Spin Echo offset \tau (ms)');
set(gca,'FontSize',12);
title(['Y = ',num2str(p.Y),...
     ', R = ',num2str(p.R*1e6),'\mum',...
     ', D = ',num2str(p.D),'m^2/s',...
     ', T_2 = 0']);


%% Optional steps
if includeT2
    
    % calculate again
    for j = 1:10
        [sASE_u(:,j), tASE]  = plotASE(p,Phase_u(:,:,j),'display',false,'T2EV',0.11);
        [sASE_n(:,j), tASE]  = plotASE(p,Phase_n(:,:,j),'display',false,'T2EV',0.11);
    end
    
    % normalise and scale
    meanu = mean(sASE_u,2); % calculate the mean
    meann = mean(sASE_n,2);
    meann = meann./meanu;   % normalise it - normal-dist first
    meanu = meanu./meanu;   

    stdu = std(sASE_u,[],2);    % calculate standard deviation
    stdn = std(sASE_n,[],2);
    stdu = stdu./meanu;         % normalise it
    stdn = stdn./meanu;
    
    % plot
    figure(12)
    errorbar(1000*tASE,meanu,stdu,'-','LineWidth',1.5); hold on;
    errorbar(1000*tASE+1,meann,stdn,'--','LineWidth',1.5); % add an offset, so we can see them better
    axis([-62 62 0.95 1.05])
    legend(['Y = ',num2str(p.Y)],'0.6\leqY\leq0.8','Location','North');
    ylabel('Signal Normalised to Uniform Distribution');
    xlabel('Spin Echo offset \tau (ms)');
    set(gca,'FontSize',12);
    title(['Y = ',num2str(p.Y),...
         ', R = ',num2str(p.R*1e6),'\mum',...
         ', D = ',num2str(p.D),'m^2/s',...
         ', T_2 = 110ms']);
     
end