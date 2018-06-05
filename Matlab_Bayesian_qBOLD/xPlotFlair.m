% xPlotFlair.m
%
% Making a plot illustrating what FLAIR does
%
% MT Cherukara
% 31 May 2018

clear;
% close all;

setFigureDefaults;

T1t = 1.200;        % tissue T1
T1b = 1.580;        % blood T1
T1e = 3.870;        % CSF T1

TP = 0.350;         % Pre-Inversion time (for plotting)
TI = 1.210;         % Inversion time
TR = 3.000;         % Repetition time
TT = 11.000;         % Total run time (for plotting)

M0 = 1;

% time
tt = 0:0.001:TT;
nt = length(tt);

% find the index of the inversion point and readout points
iI = 1000*(TP);         % inversion
iR = 1000*(TP+TR);      % first TR
i2 = iR+(1000*TR)-1;    % second TR

% calculate ideal TI given T1 and TR
Tideal = T1e.*(log(2) - log(1+exp(-TR/T1e)));

% iI = find(tt > TP,1);

% re-centre time-points to be around TI
tt = tt - TP;

% inverted signal
St = M0.*(1-2*exp(-tt/T1t)+exp(-TR/T1t));
Sb = M0.*(1-2*exp(-tt/T1b)+exp(-TR/T1b));
Se = M0.*(1-2*exp(-tt/T1e)+exp(-TR/T1e));

% signal before inversion
St(1:iI) = M0;
Sb(1:iI) = M0;
Se(1:iI) = M0;

% calculate second TR
tr = 0.001:0.001:TR;
i2 = iR+(1000*TR)-1;

St(iR:i2) = M0.*(1-2*exp(-tr/T1t)+exp(-TR/T1t));
Sb(iR:i2) = M0.*(1-2*exp(-tr/T1b)+exp(-TR/T1b));
Se(iR:i2) = M0.*(1-2*exp(-tr/T1e)+exp(-TR/T1e));

% calculate third TR
iR = i2+1;
i2 = iR+(1000*TR)-1;

St(iR:i2) = M0.*(1-2*exp(-tr/T1t)+exp(-TR/T1t));
Sb(iR:i2) = M0.*(1-2*exp(-tr/T1b)+exp(-TR/T1b));
Se(iR:i2) = M0.*(1-2*exp(-tr/T1e)+exp(-TR/T1e));

% plot
figure(); hold on; box on;

% signal zero line
plot([-TT,TT],[0,0],'k-','LineWidth',1);

% RF events
plot([   TR,   TR],[-1.5,1.5],'k--','LineWidth',1);     % Second Inversion
plot([TR+TI,TR+TI],[-1.5,1.5],'k--','LineWidth',1);     % Second Readout
plot([ 2*TR, 2*TR],[-1.5,1.5],'k--','LineWidth',1);     % Third Inversion
% plot([Tideal,Tideal],[-1.5,1.5],'k--','LineWidth',1);     % Third Inversion


% Compartment signals
Lt = plot(tt,St,'-','Color',defColour(1));
Lb = plot(tt,Sb,'-','Color',defColour(2));
Le = plot(tt,Se,'-','Color',defColour(3));

% Axis
axis([(TR-TP),(2*TR+TP),-1.1,1.1]);
ylabel('Steady-State  M_z');
xlabel('Time');
legend([Lt,Lb,Le],'Tissue Signal','Blood Signal','CSF Signal','Location','SouthEast');
% xticks([0,Tideal]);
xticks([TR,TR+TI,2*TR]);
xticklabels({'0','TI','TR'});