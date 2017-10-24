function BoxResiduals
% BoxResiduals usage:
%
%       BoxResiduals
%
% Compares results from multiple runs of FABBER by making box-and-whisker
% plots of the residuals.
%
% 
%       Copyright (C) University of Oxford, 2017
%
% 
% Created by MT Cherukara, 24 October 2017
%
% CHANGELOG:

% while loop to keep adding datasets
anotherOne = 1;

% initialize the residuals matrix
allresids = [];
lngresids = []; % for storing the length of each volume
wsk = []; % for calculating whiskers

while anotherOne
    
    % have the user select a Fabber_Results folder
    [~, frdir] = uigetfile('*','Select any file in the desired directory...');
    
    % load the residuals NIFTI in the selected folder
    volresids = read_avw([frdir,'/residuals.nii.gz']);
    
    % vectorise the residuals
    volresids = abs(nonzeros(volresids));
    
    wsk = [wsk; quantile(volresids,[0.25,0.75])];
    
    % record the length
    lngresids = [lngresids; length(volresids)];
    
    % stick them all together
    allresids = [allresids; volresids];
    
    % see if the user wants to add another dataset
    choice = questdlg('Would you like to select another dataset for comparison?',...
                  'Another Dataset',...
                  'Another One!','Plot It','Plot It');
              
    % switch and case and so on
    switch choice
        case 'Another One!'
            anotherOne = 1;
        case 'Plot It'
            anotherOne = 0;
    end % switch choice
    
end % while anotherOne

% define groups for the box-plot
grpresids = ones(sum(lngresids),1);
counter = 1;

for ii = 1:length(lngresids)
    
    grpresids(counter:counter+lngresids(ii)-1) = ii;
    counter = counter + lngresids(ii);
    
end

% calculate the y-axis limits
ww = max( wsk(:,2) + 1.5*(wsk(:,2)-wsk(:,1)) );

% make the box-plot
figure('WindowStyle','Docked');
hold on; box on;
boxplot(allresids,grpresids,'Width',0.75);
ylabel('Subject-wise residual');
ylim([-0.1,1.1]*ww);
set(gca,'FontSize',16);


