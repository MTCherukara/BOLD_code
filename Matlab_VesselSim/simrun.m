% simrun.m
% 
% Runs the vessel simulator, which models a brain voxel and the MRI signal
% resulting from it by generating a universe filled with randomly
% positioned and oriented cylinders (representing blood vessels) with
% chosen radii and susceptibility, occupying a chosen fraction of the total
% space, and then positions a single 'proton' in the centre of this
% universe, and allows it to walk randomly throughout, at a rate governed
% by the diffusion constant D, the proton accrues phase based on the
% magnetic fields created by the vessels, which is recorded in specified
% steps.
%
% The saved output is a matrix of phase values with dimensions of N repeats
% by S steps. A structure p is also saved out containing all the relevant
% variable information. 
%
% Created by NP Blockley, March 2016
% 
% Modifed by MT Cherukara, December 2016 and onwards
%
%
%       Copyright (C) University of Oxford, 2016-2017
%
%
% CHANGELOG:
%
% 2017-08-17 (MTC). Removed a bunch of superfluous stuff from this script,
%       so that the bulk of the work is done by MTC_vesselsim.m, and the
%       analysis is done by simAnalyse.m. 
%
% 2017-02-23 (MTC). A bunch of changes separating out the functionality of
%       this script into others, namely MTC_plotSignal and MTC_simAnalyse. 
%       The function simplevesselsim.m does the bulk of the actual work,
%       this script is just there to set up stuff, call that function, and 
%       save out the results.

clear;
tic;

save_data = 1;  % set this to 1 to save storedPhase data out, or 0 not to

% DBV Values for reference
% 0.0100    0.0167    0.0233    0.0300    0.0367    0.0433    0.0500    0.0567    0.0633    0.0700

% Fixed Parameters
p.D     = 1e-9;     % m^2/s - Rate of diffusion
p.B0    = 3;        % T     - Static magnetic field
p.TE    = 60e-3;    % s     - Echo time
p.dt    = 200e-6;   % s     - Time between steps (0.2ms) - leads to having 10 points per T
p.Hct   = 0.40;     % -     - Fractional haematocrit
p.N     = 10000;    % -     - Number of particles
p.gamma = 2*pi*42.58e6;     % Gyromagnetic ratio
p.deltaTE = 0.002;  % s     - step size (1ms) this should give more data
p.deltaChi0 = 0.264e-6;     % Susceptibility difference
p.universeScale = 50;      % Defines size of universe
p.solidWalls = 0;

% Varied Parameters
p.R     = 5.0e-6;   % m     - Vessel radius
p.Y     = 0.6;      % -     - (1-OEF)
p.vesselFraction = 0.03;        % DBV


% Derived parameters
p.Hct = p.Hct.*ones(1,length(p.R));
p.deltaChi = p.deltaChi0.*p.Hct.*(1-p.Y); % calculate susceptibility difference

[Phase,p] = MTC_vesselsim(p);

toc;
% save out data
if save_data
    dataname = ['newStoredPhase/Sdata_R_'  ,num2str(p.R*1e6),...
                                    '_OEF_',num2str(100*(1-p.Y)),...
                                    '_DBV_',num2str(100*p.vesselFraction)];
    
    save(strcat(dataname,'.mat'),'Phase','p');
end