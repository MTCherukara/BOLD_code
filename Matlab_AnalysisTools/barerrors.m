function barerrors(errors,data)
% barerrors usage:
%
%       barerrors(errors,data)
%
% Plots a bar chart (as if bar(data) was called), but with error-bars
% given by ERRORS. Designed for use with barcharts.m
%
% Created by MT Cherukara, 8 November 2017
%
% CHANGELOG:

% make sure the input data is legit
assert(size(data,1) == size(errors,1),'Inputs must be the same size!');
assert(size(data,2) == size(errors,2),'Inputs must be the same size!');

ng = size(data,1); % number of groups (subjects)
nb = size(data,2); % number of bars per group

% Plot a bar chart
figure('WindowStyle','Docked');
hold on; box on;
bar(data);
set(gca,'FontSize',16);
xticks(1:ng);

% Figure out where the centres of each bar are
cents = repmat((1:ng)',1,nb);

% for odd numbers of bars per group
if mod(nb,2) == 1
    coffs = -((nb-1)/2)/(nb+1.5):1/(nb+1.5):((nb-1)/2)/(nb+1.5);
else
    % this is completely wrong!
    coffs = linspace(-0.4,0.4,nb);
end

cents = cents + repmat(coffs,ng,1);

% Plot the errorbars
errorbar(cents,data,errors,'k.','LineWidth',2);