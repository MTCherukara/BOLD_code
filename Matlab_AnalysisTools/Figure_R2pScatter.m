% Figure_R2pScatter.m
%
% Make a scatter plot of FABBER inference of simulated data, specifically,
% plotting inferred R2' as a function of true (simulated) OEF, for data
% generated with a fixed DBV (the 50x1 grids). Derived from xSimScatter.x
%
% MT Cherukara
% 8 April 2019
%
% Actively used as of 2019-04-08
%
% CHANGELOG:


clear;
close all;
% setFigureDefaults;

% choose datasets
sets = 506:510;

% variable
vname = 'OEF';


%% Find directories, and load ground truth data and stuff
% Data directory
resdir = '/Users/mattcher/Documents/DPhil/Data/Fabber_ModelFits/';

% number of OEF points
no = 100;

% Ground truth
% OEFvals = linspace(0.21,0.70,no);
OEFvals = linspace(0.01,1,no);
DBVvals = 0.01:0.02:0.09;

% Axis limits
R2plims = [0,8.5];
OEFlims = [0,100*max(OEFvals)];

% Pre-allocate
estR2p = zeros(length(sets),no);
estOEF = zeros(length(sets),no);



%% Loop through Datasets
for ss = 1:length(sets)
    
    % Figure out the results directory we want to load from
    fdname = dir([resdir,'fabber_',num2str(sets(ss)),'_*']);
    fabdir = strcat(resdir,fdname.name,'/');
    
    % Load the data
    volData = LoadSlice([fabdir,'mean_',vname,'.nii.gz'],1);
       
    % Average
    vecData = mean(volData,1);
        
    % Calculate OEF
    vecOEF = vecData./(354.99.*DBVvals(ss));
    
    % Store Results
    estR2p(ss,:) = vecData;
    estOEF(ss,:) = vecOEF;
   
end % for setnum = ....
   


%% Plotting

% Plot R2p estimates
figure; box on; hold on;
for ff = 1:length(sets)
    scatter(100*OEFvals,estR2p(ff,:),[],'filled');
end

legend('DBV = 1%','DBV = 3%','DBV = 5%','DBV = 7%','DBV = 9%','Location','NorthWest')
xlabel('Simulated OEF (%)');

if strcmp(vname,'DBV')
    ylabel('Estimated DBV (%)');
    xlim(OEFlims);
    ylim([0,0.11]);
    yticks(0:0.02:0.10);
    yticklabels({'0','2','4','6','8','10'});
    
    plot([0,100],[0.01,0.01],'-','Color',defColour(1),'LineWidth',1);
    plot([0,100],[0.03,0.03],'-','Color',defColour(2),'LineWidth',1);
    plot([0,100],[0.05,0.05],'-','Color',defColour(3),'LineWidth',1);
    plot([0,100],[0.07,0.07],'-','Color',defColour(4),'LineWidth',1);
    plot([0,100],[0.09,0.09],'-','Color',defColour(5),'LineWidth',1);
elseif strcmp(vname,'OEF')
    ylabel('Estimated OEF (%)');
    axis([OEFlims,0.01*OEFlims]);
    yticklabels({'0','20','40','60','80','100'})
       
else
    ylabel('Estimated R2'' ');
    axis([OEFlims,R2plims]);
end

% legend('SDR Model','Diff. Model (unc.)','Diff. Model (\kappa)','Location','NorthWest');

% Plot OEF estimates
figure; box on; hold on; axis square;
for ff = 1:length(sets)
    scatter(100*OEFvals,100*estOEF(ff,:),[],'filled');
end
plot([0,100],[0,100],'k-','LineWidth',1);

xlabel('Simulated OEF (%)');
ylabel('Estimated OEF (%)');
legend('DBV = 1%','DBV = 3%','DBV = 5%','DBV = 7%','DBV = 9%','Location','NorthWest')

axis([OEFlims,OEFlims]);
% legend('SDR Model','Diff. Model (unc.)','Diff. Model (\kappa)','Location','NorthWest');
