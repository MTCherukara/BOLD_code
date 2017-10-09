% xPlotGrid3D.m
% 
% A way of visualising 3D grid search data
%
% Created 6 October 2017

function xPlotGrid3D
    % Main Function
    
% Load in Grid Search Data
load('~/Documents/DPhil/Data/GridSearches/CSF_Grids/Grid_50_OEF_1000.mat');

np = max(size(pos));
nz = min(size(pos));

val1 = linspace(0,1,nz);

fig1 = MakeFig;

% loop through 50 slices in the shortest dimension
for ii = 2:(nz-1)
    
    pslice = squeeze(pos(ii,:,:));
    
    PlotGrid(fig1,vals,pslice,trv(2:3),{'DBV';'CSF'});
    title(['OEF = ',num2str(val1(ii))]);
%     pause(0.2);
    print(['temp_plots/Grid_OEF_slice_',num2str(ii)],'-dpng');
    
end % for ii = 1:nz
    

return; % function xPlotGrid3D

function fg = MakeFig
    % Makes a figure window (and docks it), and returns the handle
    
    fg = figure;
    set(fg,'WindowStyle','docked');
    hold on; box on;
    set(gca,'FontSize',16);
    
return; % function fg = MakeFig

function PlotGrid(fg,vals,grd,truevals,pnames)
    % Plots an imagesc of GRD on figure FG, with axes VALS, optionally 
    % adding a cross at TRUEVALS and axis labels PNAMES
    
    figure(fg); 
    
    imagesc(vals(2,:),vals(1,:),grd,[0 1]); hold on;
    
    if exist('truevals','var')
        plot([truevals(2),truevals(2)],[  0, 30],'w-','LineWidth',2);
        plot([  0, 30],[truevals(1),truevals(1)],'w-','LineWidth',2);
    end

    % Label the other axes based on parameter choice
    if exist('pnames','var');
        xlabel(pnames{2});
        ylabel(pnames{1});
    end


    axis([vals(2,1),vals(2,end),vals(1,1),vals(1,end)]);
    set(gca,'YDir','normal');
    
return; %  function PlotGrid(fg,vals,grd,truevals,pnames)

