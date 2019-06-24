% Run_Simulation.m
% 
% Wrapper script to run NP Blockley's simple vessel simulator, which models a 
% brain voxel and the MRI signal resulting from it by generating a universe 
% filled with randomly positioned and oriented cylinders (representing blood
% vessels) with chosen radii and susceptibility, occupying a chosen fraction of
% the total space, and then positions a single 'proton' in the centre of this 
% universe, and allows it to walk randomly throughout, at a rate governed by the
% diffusion constant D, the proton accrues phase based on the magnetic fields
% created by the vessels, which is recorded in specified steps.
%
% The saved output is a matrix of phase values with dimensions of N repeats
% by S steps. A structure p is also saved out containing all the relevant
% variable information. 
%
% Requires vesselSim.m
%
% Created by NP Blockley, March 2016
%
%
%       Copyright (C) University of Oxford, 2016-2019
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

radii = [38:44,46:50,22.5,60,90,51:59,61:89,91:100];

for rr = 1:length(radii)
   
    rad0 = radii(rr);
    
    disp(['Simulating Radius ',num2str(rad0),'um']);
    
    tic;

    save_data = 1;  % set this to 1 to save storedPhase data out, or 0 not to

    % DBV Values for reference
    % 0.0100    0.0167    0.0233    0.0300    0.0367    0.0433    0.0500    0.0567    0.0633    0.0700

    % Fixed Parameters
    p.D     = 1e-9;     % m^2/s - Rate of diffusion
    p.B0    = 3;        % T     - Static magnetic field
    p.TE    = 120e-3;    % s     - Echo time
    p.dt    = 200e-6;   % s     - Time between steps (0.2ms) - leads to having 10 points per T
    p.Hct   = 0.40;     % -     - Fractional haematocrit
    p.N     = 10000;    % -     - Number of particles
    p.gamma = 2*pi*42.58e6;     % Gyromagnetic ratio
    p.deltaTE = 0.001;  % s     - step size (1ms) this should give more data
    p.deltaChi0 = 0.264e-6;     % Susceptibility difference
    p.universeScale = 45;      % Defines size of universe
    p.solidWalls = 0;

    % Sharan Radii
    %       2.8    7.5   15.0   22.5   45.0   90.0

    % Varied Parameters
    p.R = rad0.*1e-6;               % m     - Vessel radius
    p.Y = 0.6;                  % -     - (1-OEF)
    p.V = 0.03;                 % -     - Volume
    p.vesselFraction = p.V;

    % Derived parameters

    [spp,p] = vesselSim(p);

    toc;
    % save out data
    if save_data
        datdir = 'D:\Matthew\1_DPhil\Data\vesselsim_data\simulated_data\';
        dataname = [datdir,'FullData_R_'  ,num2str(p.R(1)*1e6)];

        save(strcat(dataname,'.mat'),'spp','p');
    end
    
end % for rr = 1:length(radii)
