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
% 2017-02-23 (MTC). A bunch of changes separating out the functionality of
%       this script into others, namely MTC_plotSignal and MTC_simAnalyse. 
%       The function simplevesselsim.m does the bulk of the actual work,
%       this script is just there to set up stuff, call that function, and 
%       save out the results.

clear;

save_data = 0;  % set this to 1 to save storedPhase data out, or 0 not to

p=gentemplate;          % create basic set of parameters
p.N = 1000;
 
p.R = 1e-4;     % radius, in m
p.D = 1e-9;     % diffusion, in m^2/s
p.Y = 0.6;      % oxygenation fraction (1-OEF) 
p.vesselFraction = 0.03;    % DBV


X = p.Y*ones(1,1);

% pre-allocate phase storage arrays
ph_steps = round((p.TE*2)/p.dt)./round(p.deltaTE./p.dt);
Phase_u = zeros(ph_steps,p.N,length(X));

for j = 1:length(X)
    
%     p.Y = [0.95,0.7,0.6];
    p.deltaChi = p.deltaChi0.*p.Hct.*(1-p.Y); % calculate susceptibility difference
    
    disp(['Running j = ',num2str(j)]);
    
    tic;
    p.solidWalls = 0;
    [Phase_u(:,:,j),p] = MTC_vesselsim(p);
    % we don't even need to do this plotSignal stuff at all at this stage
%     [sASE_u(:,j), tASE]  = MTC_plotSignal(p,Phase_u(:,:,j),'sequence','ASE','display',false);
    toc;
    
    % Don't try this two-in-one nonsense, because the p structure then
    % won't contain all the information we want
%     tic;
% 
%     p.Y = 0.8;      % oxygenation fraction (1-OEF) 
%     p.vesselFraction = 0.05;    % DBV
%     p.deltaChi = p.deltaChi0.*p.Hct.*(1-p.Y); % calculate susceptibility difference
% 
%     [Phase_n(:,:,j),p] = simplevesselsim(p);
%     p.deltaChi = p.deltaChi0.*p.Hct.*(1-p.Y); % calculate susceptibility difference
% 
%     toc;
    
    disp(['  j = ',num2str(j),' completed']);   
    
end

% save out data
if save_data
    if p.D == 0
        diffterm = '_Static_';
    else
        diffterm = '_Diffusion_';
    end
    dataname = ['newStoredPhase/VSdata_',date,diffterm];
    D = dir([dataname,'*']);
    
    % check whether we've created two sets of storedPhase, and save all
    if ~exist('Phase_n','var')
        save(strcat(dataname,num2str(length(D)+1),'.mat'),'Phase_u','p');
    else
        save(strcat(dataname,num2str(length(D)+1),'.mat'),'Phase_n','Phase_u','p');
    end
end