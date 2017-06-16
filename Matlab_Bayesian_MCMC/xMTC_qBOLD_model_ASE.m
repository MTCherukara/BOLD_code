% xMTC_qBOLD_model.m

% analytical look at the quantitative BOLD model in ASE, based on He and
% Yablonskiy 2007 (originally based on Yablonskiy & Haacke, 1994)

clear; close all;

% constant parameters
DBV = 0.03;
R2t = 5; % make this slower than normal so we can see it better
dw  = 142; % apparently
TE  = 0.074; % 74 ms
tau = 0.01; 

n = 100; % number of points

taus = -40:1:40;
Stau = zeros(1,length(taus));

for jj = 1:length(taus);
    tau = 0.001*taus(jj); % select a tau value
    
    Tf = (TE - tau)/2; % flip time
    
    Sr2 = exp(-R2t.*TE);

    
    fun = @(u) ((2+u).*sqrt(1-u)./(u.^2)).*(1-besselj(0,1.5.*dw.*abs(tau).*u));
    grl = integral(fun,0,1);

    Szt = exp(-DBV.*grl./3);
    
    Stau(jj) = Sr2.*Szt;
    
end % for jj = 1:length(taus);

%% Plot a figure for ASE acquisition
figure('WindowStyle','Docked');
hold on; box on;
% plot([TE,TE],[0,1],'k-');     % for non-log vesion
% plot([Tf,Tf],[0,1],'k--');
% plot([TE,TE],[-0.6,0],'k-');      % for log version
% plot([Tf,Tf],[-0.6,0],'k--');
p.a = plot(taus,log(Stau),'-','LineWidth',2);
% p.b = plot(t,log(Szt),'-','LineWidth',2);
% p.c = plot(t,log(Sr2.*Szt),'-','LineWidth',2);

% legend([p.a,p.b,p.c],'R2 decay','Vascular Effect','Total','Location','SouthWest');
xlabel('TE offset \tau (ms)');
ylabel('Log signal');
set(gca,'FontSize',16);