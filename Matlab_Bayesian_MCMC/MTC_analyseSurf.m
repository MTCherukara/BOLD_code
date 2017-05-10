% MTC_analyseSurf

% analysis of surfASE data

clear;

load('ASE_SurfData_sigma_5');


% choose which values of OEF and DBV we want to specifically look at
OEF_1 = 0.4;
DBV_1 = 0.05;

[~,i1] = min(abs(OEF - OEF_1));
[~,i2] = min(abs(DBV - DBV_1));

% isolate 3D matrices for those chosen values
SY = squeeze(S0(:,i2,:,:));     % matrix with changes in OEF (or Y)
SZ = squeeze(S0(i1,:,:,:));     % matrix with changes in DBV (or Z)

% compute difference in signal along both ends of surface
SYG = squeeze( SY(1,:,:) - SY(end,:,:) );
SZG = squeeze( SZ(1,:,:) - SZ(end,:,:) );

% relative differences
% SYG = SYG./squeeze(SY(1,:,:));
% SZG = SZG./squeeze(SZ(1,:,:));

% normalized differences
% SYG = SYG./max(SYG(:));
% SZG = SZG./max(SZG(:));


%% Plot Results
figure();
imagesc(1000*tau,1000*TE,SYG); hold on;
c=colorbar;
xlabel('180 Pulse Offset \tau (ms)');
ylabel('Echo Time TE (ms)');
title(['OEF Contrast (DBV = ',num2str(DBV_1),')'])
set(gca,'FontSize',16,'YDir','normal');
set(c,'FontSize',16)
set(gcf,'WindowStyle','docked');

figure();
imagesc(1000*tau,1000*TE,SZG); hold on;
c=colorbar;
xlabel('180 Pulse Offset \tau (ms)');
ylabel('Echo Time TE (ms)');
title(['DBV Contrast (OEF = ',num2str(OEF_1),')'])
set(gca,'FontSize',16,'YDir','normal');
set(c,'FontSize',16)
set(gcf,'WindowStyle','docked');
