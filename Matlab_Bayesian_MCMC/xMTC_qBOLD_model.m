% xMTC_qBOLD_model.m

% analytical look at the quantitative BOLD model in ASE, based on He and
% Yablonskiy 2007 (originally based on Yablonskiy & Haacke, 1994)

clear; close all;

% constant parameters
OEF = 0.40
DBV = 0.03;
R2t = 1; % make this slower than normal so we can see it better
dw  = 355*OEF;
TE  = 0.074; % 74 ms
tau = 0.01; 

n = 1000; % number of points

t = linspace(0,0.1,n); % time from 0 to 100 ms

Sr2 = exp(-R2t.*t); % R2 decay component
Szt = zeros(1,n);

Tf = (TE - tau)/2; % flip time

% calculate analytical form
for ii = 1:n

    if t(ii) < Tf
        tt = t(ii);
    else
        tt = t(ii) - (TE-tau);
    end

%     tt = t(ii) - ((TE-tau));
    fun = @(u) ((2+u).*sqrt(1-u)./(u.^2)).*(1-besselj(0,1.5.*dw.*tt.*u));
    grl = integral(fun,0,1);

    Szt(ii) = exp(-DBV.*grl./3);

end % for ii = 1:n

tsw = 1.5/dw; % time for switching regimes

Sas = zeros(1,n);
% calculate asymptotic forms
for ii = 1:n
    tt = t(ii);
    
    % long t, before flip
    if tt < Tf
        Sas(ii) = exp(DBV-DBV.*dw.*tt);
        
    % short t, around echo
    elseif abs(tt-TE+tau) < tsw
        Sas(ii) = exp(-(0.3).*DBV.*(dw.*(TE-tt-tau)).^2);
        
    % long t, after echo
    elseif tt > (TE+tsw-tau)
        Sas(ii) = exp(DBV-DBV.*dw.*(tt-TE+tau));
        
    % long t, after flip but before echo
    else
        Sas(ii) = exp(DBV-DBV.*dw.*(TE-tau-tt));
    end % if
        
end % for ii = 1:n


% Plot a figure for a single tau value
figure('WindowStyle','Docked');
hold on; box on;
% plot([TE,TE],[0,1],'k-');     % for non-log vesion
% plot([Tf,Tf],[0,1],'k--');
plot([TE,TE],[-1,1],'k-');      % for log version
plot([Tf,Tf],[-1,1],'k--');
p.a = plot(t,log(Sr2),'-','LineWidth',2);
p.b = plot(t,log(Szt),'-','LineWidth',2);
p.c = plot(t,log(Sr2.*Szt),'-','LineWidth',2);
p.d = plot(t,log(Sr2.*Sas),':','LineWidth',2);
% axis([0.06,0.09,-0.2,0.1]);
axis([0, 0.1, -0.3, 0.1]);

legend([p.a,p.b,p.c,p.d],'R2 decay','Vascular Effect','Complete Model','Asymptotic Model','Location','SouthWest');
xlabel('Time (s)');
ylabel('Log signal');
set(gca,'FontSize',16);

% % Plot a figure for asymptotic forms
% figure('WindowStyle','Docked');
% hold on; box on;
% plot(t,log(Sshrt),'-','LineWidth',2);
% plot(t,log(Slong),'-','LineWidth',2);
% plot(t,log(Sass),'-','LineWidth',2);
% axis([0, 0.1,-0.5,0]);