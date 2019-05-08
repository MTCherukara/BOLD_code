% Figure_SingleRadius.m
%
% Make plots showing ASE curves (extravascular only) for single vessel radii (at
% the same time).
%
% Created by MT Cherukara, 6 May 2019

clear;
setFigureDefaults;

% Radii: 3, 10, 17, 30, 42, 100

datadir = '../../Data/vesselsim_data/vs_arrays/';

% choose radii
RR = [3,10,30,100];

% Choose OEF, DBV
OEF = 0.40;
DBV = 0.03;

% Fixed taus
taus = -28:4:68;

% Physiological Parameters
OEFvals = linspace(0.21,0.7,50);
DBVvals = linspace(0.003,0.15,50);

% Find OEF and DBV indices
i_OEF = find(OEFvals == OEF,1);
i_DBV = find(DBVvals == DBV,1);


%% Load the data

% Pre-allocate
S0 = zeros(length(RR),length(taus));

% Loop through radii
for ii = 1:length(RR)
    
    % Radius
    r = RR(ii);
    
    % Load data
    load([datadir,'vsArray50_single_TE_84_R_',num2str(r)]);
    
    Si = squeeze(S_ev(:,i_DBV,i_OEF));
    Si = Si./max(Si);
    
    S0(ii,:) = log(Si) + 1;
    
end % for ii = 1:length(RR)


%% Plotting

figure;
plot(taus,S0,'-');
grid on; axis square;
set(gca,'FontSize',15);
xlabel('Spin Echo Displacement \tau (ms)');
ylabel('Log (Signal)');
axis([-30,70,0.76,1.01]);
legend('R = 3 \mum','R = 10 \mum','R = 30 \mum','R = 100 \mum','Location','SouthWest');
