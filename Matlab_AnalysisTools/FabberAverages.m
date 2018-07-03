% function FabberAverages(fabber)
    % Loads a particular Fabber dataset and displays the average (mean and
    % median) values of R2' and DBV in the top 8 slices.
    %
    % Actively used as of 2018-06-27
    %
    % Changelog:
    %
    % 3 July 2018 (MTC). Modularized to use MTC_LoadVol (which calls LoadSlice)
    %       to get rid of a bunch of repeated stuff here. Also changed the way
    %       the upper parameter threshold works, so that we now remove voxels
    %       whose values are too high, rather than setting them to an arbitrary
    %       value.
    %
    % 12 March 2018 (MTC). Generalization, enabling selection of variables to
    %       plot in a more generic and extensible way.

clear; 
clc;
% close all;

% Choose Variables
vars = {'R2p','DBV','OEF','VC'};

% Choose the slices we want
% slicenum = 3:10;    % VS
slicenum = 2:8;     % CSF + patient data
% slicenum = 1:6;   % TR = 2

% Choose Data set
setnum = 486;
subnum = 5;

setnum = setnum + subnum - 1;

CSF_subs = containers.Map([ 1, 2, 3, 4, 5 ], ...
                          [ 3, 4, 6, 8, 9 ]);
subnum = CSF_subs(subnum);     

% Title
disp(['Data from Fabber Set ',num2str(setnum),'. Subject ',num2str(subnum)]);

for vv = 1:length(vars)
    
    % Identify Variable
    vname = vars{vv};
    
    % Load the Data and do all the masking and thresholding
    [volData, volStdv] = MTC_LoadVol(setnum,subnum,vname,slicenum);
   
    % convert certain params to percentages
    if strcmp(vname,'DBV') || strcmp(vname,'OEF') || strcmp(vname,'VC') || strcmp(vname,'lambda')
        volData = volData.*100;
        volStdv = volStdv.*100;
    end
    
    % Display results
    disp('   ');
    disp(['Mean ',vname,'   : ',num2str(mean(volData),4)]);
    if strcmp(vname,'VC')
        disp(['    Std ',vname,': ',num2str(std(volData),4)]);
    else
        disp(['    Std ',vname,': ',num2str(mean(volStdv),4)]);
    end
    
    
end

