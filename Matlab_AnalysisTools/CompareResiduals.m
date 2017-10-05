function CompareResiduals
% CompareResiduals usage:
%
%       CompareResiduals
%
% Calculates the mean value of each volume in a pair of NIFTI MRI images
% and compares them. For use in comparing the residuals from qBOLD model
% fitting using FABBER.
%
% 
%       Copyright (C) University of Oxford, 2017
%
% 
% Created by MT Cherukara, 4 October 2017
%
% CHANGELOG:

% first dataset
% have the user select a Fabber_Results folder
[~, frdir] = uigetfile('*','Select any file in the desired directory...');
[resids,dims] = read_avw([frdir,'/residuals.nii.gz']);

nv = dims(4); % number of volumes

% have the user insert the tau range
tinput = inputdlg({'Tau start (ms):','Tau end (ms):'},'Taus (ms)',1,{'0','1'});
taus1 = linspace(str2double(tinput{1}),str2double(tinput{2}),nv);

mrsd1 = zeros(nv,1);

% loop through all volumes and calculate the mean residual
for ii = 1:nv
    vl = abs(squeeze(resids(:,:,:,ii)));
    mrsd1(ii) = mean(vl(:));
end

choice = questdlg('Would you like ot select a second dataset for comparison?',...
                  'Second Dataset',...
                  'Yes','No','No');
              
switch choice
    case 'Yes'
        % second dataset
        % have the user select a Fabber_Results folder
        [~, frdir] = uigetfile('*','Select any file in the desired directory...');
        [resids,dims] = read_avw([frdir,'/residuals.nii.gz']);

        nv = dims(4); % number of volumes

        % have the user insert the tau range
        tinput = inputdlg({'Tau start (ms):','Tau end (ms):'},'Taus (ms)',1,{'0','1'});
        taus2 = linspace(str2double(tinput{1}),str2double(tinput{2}),nv);

        mrsd2 = zeros(nv,1);

        % loop through all volumes and calculate the mean residual
        for ii = 1:nv
            vl = abs(squeeze(resids(:,:,:,ii)));
            mrsd2(ii) = mean(vl(:));
        end
    case 'No'
        taus2 = [];
        mrsd2 = [];
end

choice = questdlg('Would you like ot select a third dataset for comparison?',...
                  'Third Dataset',...
                  'Yes','No','No');
              
switch choice
    case 'Yes'
        % second dataset
        % have the user select a Fabber_Results folder
        [~, frdir] = uigetfile('*','Select any file in the desired directory...');
        [resids,dims] = read_avw([frdir,'/residuals.nii.gz']);

        nv = dims(4); % number of volumes

        % have the user insert the tau range
        tinput = inputdlg({'Tau start (ms):','Tau end (ms):'},'Taus (ms)',1,{'0','1'});
        taus3 = linspace(str2double(tinput{1}),str2double(tinput{2}),nv);

        mrsd3 = zeros(nv,1);

        % loop through all volumes and calculate the mean residual
        for ii = 1:nv
            vl = abs(squeeze(resids(:,:,:,ii)));
            mrsd3(ii) = mean(vl(:));
        end
    case 'No'
        taus3 = [];
        mrsd3 = [];
end


% plot the result
figure('WindowStyle','Docked');
hold on; box on;
plot(taus1,mrsd1,'-','LineWidth',3);
if size(taus2,1) > 0
    plot(taus2,mrsd2,'-','LineWidth',3);
end
if size(taus3,1) > 0
    plot(taus3,mrsd3,'-','LineWidth',3);
end
xlabel('Spin echo offset \tau (ms)');
ylabel('Volume-wise residual');
set(gca,'FontSize',16);



