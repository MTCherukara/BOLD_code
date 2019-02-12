function h = plotGrid(Z,X,Y,varargin)
    % Plot a 2D grid of OEF against DBV. Usage:
    %
    %       h = plotGrid(Z,X,Y,varargin)
    %
    % A (moderately) generalizable function that plots a 2D surface plot of some
    % variable Z (M x N array) against X (length N vector) and Y(length M
    % vector). Returns figure handle H. Also takes optional name-value pair
    % arguments of the following:
    %
    %           xlabel, ylabel, title, cmap, cscale
    %
    % 
    %       Copyright (C) University of Oxford, 2018
    %
    % 
    % Created by MT Cherukara, 25 October 2018
    %
    % CHANGELOG:
    %
    

% Parse optional arguments
q = inputParser;

% Main arguments
addRequired( q, 'Z' , @ismatrix );
addOptional( q, 'X' , linspace(0.0100,0.07,size(Z,2)) , @isvector );
addOptional( q, 'Y' , linspace(0.1875,0.60,size(Z,1)) , @isvector );

% Name-Value pair arguments
addParameter( q, 'xlabel' , 'DBV (%)');     % X-axis data name (DBV)
addParameter( q, 'ylabel' , 'OEF (%)');     % Y-axis data name (OEF)
addParameter( q, 'title'  , ' '      );     % Figure title
addParameter( q, 'cmap'   , 'jet'    );   	% Colormap (jet for errors)
addParameter( q, 'cvals'  , [-50,50], @isnumeric );     % Z range

% Parse the input
parse(q,Z,X,Y,varargin{:});
r = q.Results;

% Pull out the data
Data  = r.Z;
Xvals = r.X;
Yvals = r.Y;

% Make sure data supplied is of the correct size
if ( size(Data,1) ~= length(Yvals) ) || ( size(Data,2) ~= length(Xvals) ) 
    error('Dimensions inconsistent!');
end

% Plot the figure
h = figure; hold on; box on;
surf(Xvals,Yvals,Data);

% Make it look right
view(2); shading flat;
colorbar;
colormap(r.cmap);
caxis(r.cvals);
axis([min(Xvals),max(Xvals),min(Yvals),max(Yvals)]);
axis square;

% Do the labels
xlabel(r.xlabel);
% if strcmp(r.xlabel,'DBV (%)')
%     xticks(0.01:0.01:0.07);
%     xticklabels({'1','2','3','4','5','6','7'});
% end

ylabel(r.ylabel);
% if strcmp(r.ylabel,'OEF (%)')
%     yticks(0.2:0.1:0.6);
%     yticklabels({'20','30','40','50','60'})
% end

title(r.title)

