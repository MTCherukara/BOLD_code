function F = FabberBar(Data,ParamName,VarNames,SubNames)
% FabberBar.m usage:
%
%       F = FabberBar(Data,VarName)
% 
% Plot a barchart of FABBER results DATA (a Subjects x Variants matrix), 
% with optional name PARAMNAME (string) and optional Variants categories
% VARNAMES (cell array of strings) and optional Subject names categories
% SUBNAMES (cell array of strings). Can optionally return figure handle F.
%
% MT Cherukara
% 20 November 2017

if ~exist('ParamName','var')
    ParamName = 'Parameter Estimate';
end

% Pull Useful Values
subs = size(Data,1); 
vars = size(Data,2);

% Creature Figure
F = figure('WindowStyle','Docked');
hold on; box on;
set(gca,'FontSize',18);

% Plot
bar(Data);

% Label
ylabel(['Inferred ',ParamName]);
ylim([0, 1.15*max(Data(:))]);

xticks(1:subs);
if exist('SubNames','var')
    xticklabels(SubNames);
else
    xlabel('Subjects');
end

if exist('VarNames','var')
    legend(VarNames);
end