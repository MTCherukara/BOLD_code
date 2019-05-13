% Figure_VesselDistributions.m
%
% Displaying the form of the various vessel distributions on a single graph
%
% Based on figure_sharan.m (and similar) by NPB.
%
% Created by MT Cherukara, 3 May 2019

clear;
close all;
setFigureDefaults;


%% Make the distributions

% Sharan
Rr_sh = [ 2.8, 7.5 , 15  , 22.5, 45  ,   90 ];
Vr_sh = [ 0.4, 0.12, 0.12, 0.12, 0.12, 0.12 ];
Rs_sh = 1:1:100;
Vf_sh = zeros(1,100);
for ii = 1:length(Rr_sh)
    Vf_sh(Rs_sh==round(Rr_sh(ii))) = Vr_sh(ii);
end

% Jochimsen (a.k.a. Frechet)
Rs_jo = 1:1:100;
Vr_jo = gevpdf(Rs_jo,0.41,5.8,10.1);
Vf_jo = Vr_jo./sum(Vr_jo);
Vf_jo(Rs_jo<3) = 0;

% Lauwers
Rs_la = 1:1:100;
Dt_la = 1./sqrt(2.*Rs_la);
Vr_la = normpdf(Dt_la,0.38,0.07);
Vf_la = Vr_la./sum(Vr_la);
Vf_la(Rs_la<3) = 0;


%% Plot Them All Together

figure;
hold on; box on; grid on; axis square;
stairs(Rs_sh,Vf_sh,'LineWidth',2,'Color',defColour(1));
stairs(Rs_jo,Vf_jo,'LineWidth',2,'Color',defColour(2));
stairs(Rs_la,Vf_la,'LineWidth',2,'Color',defColour(4));
axis([0,100,0,0.41]);
xlabel('Vessel radius (\mum)');
ylabel('Relative volume fraction');
legend('Sharan distribution','Jochimsen distribution','Lauwers distribution');


%% Plot Them Separately

figure;
subplot(1,3,1);
stairs(Rs_sh,Vf_sh,'LineWidth',2);
box on; grid on; axis square;
axis([0,100,0,0.5]);
xlabel('Vessel radius (\mum)');
ylabel('Relative volume fraction');
title('Sharan distribution');

subplot(1,3,2);
stairs(Rs_jo,Vf_jo,'LineWidth',2);
box on; grid on; axis square;
axis([0,100,0,0.1]);
xlabel('Vessel radius (\mum)');
ylabel('Relative volume fraction');
title('Jochimsen distribution');

subplot(1,3,3);
stairs(Rs_la,Vf_la,'LineWidth',2);
box on; grid on; axis square;
axis([0,100,0,0.25]);
xlabel('Vessel radius (\mum)');
ylabel('Relative volume fraction');
title('Lauwers distribution');
