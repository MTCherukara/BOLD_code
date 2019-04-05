% xStrokeFigures.m
%
% Making some illustrative figures for various things - not using any actual
% data

clear;
close all;

setFigureDefaults;

%% Physiological Parameters as functions of CBF
% Based on Figure 1 from Leigh et al., 2007 (JCBFM)

% for plotting base percentages, 100% - CBF
base = linspace(0,100,101);

% Physiological parameters
CBF_CBFs = [100,  0];
CBF_vals = [100,  0];


ADC_CBFs = [ 100, 23, 15, 0 ];
ADC_vals = [   5,  5,  2, 2 ];

CMR_CBFs = [ 100, 45, 35, 18, 0 ];
CMR_vals = [  50, 50, 80,  0  0 ];

OEF_CBFs = [ 100, 35, 18, 0 ];
OEF_vals = [  40, 90,  0, 0 ];

% plot CBF
figure;
subplot(4,1,1);
plot(100-CBF_CBFs,CBF_vals,'Color','k');
box off;
xticks([0,20,40,60,80,100]);
xticklabels({});
ylim([0,100]); yticks([]);
ylabel('CBF');
set(get(gca,'ylabel'),'Rotation',0,...
                      'HorizontalAlignment','right',...
                      'position',[-1,50,-1],...
                      'color','k');

% plot ADC
subplot(4,1,2);
plot(100-ADC_CBFs,ADC_vals,'Color',defColour(4));
box off;
xticks([0,20,40,60,80,100]);
xticklabels({});
ylim([1,6]); yticks([]);
ylabel('ADC');
set(get(gca,'ylabel'),'Rotation',0,...
                      'HorizontalAlignment','right',...
                      'position',[-1,3,-1],...
                      'color',defColour(4));

% plot CMRO2
subplot(4,1,3);
plot(100-CMR_CBFs,CMR_vals,'Color',defColour(2)); 
box off;
xticks([0,20,40,60,80,100]);
xticklabels({});
ylim([0,100]); yticks([]);
ylabel('CMRO_2');
set(get(gca,'ylabel'),'Rotation',0,...
                      'HorizontalAlignment','right',...
                      'position',[-1,50,-1],...
                      'color',defColour(2));
                  
% plot OEF
subplot(4,1,4);
plot(100-OEF_CBFs,OEF_vals,'Color',defColour(1)); 
box off;
ylim([0,100]); yticks([]);
ylabel('OEF');
set(get(gca,'ylabel'),'Rotation',0,...
                      'HorizontalAlignment','right',...
                      'position',[-1,50,-1],...
                      'color',defColour(1));

% x axis labels
xlabel('CBF (% of baseline)');
xticks([0,20,40,60,80,100]);
xticklabels({'100','80','60','40','20','0'});