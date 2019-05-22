% xMakeDataStatic.m
%
% Loads some vessel simulator data, and takes only the first column of the phase
% thingy, in order to make a dataset without the effect of diffusion.
%
% MT Cherukara
% 20 May 2019

clear;

% choose data folder
simdir = '../../Data/vesselsim_data/single_vessel_radius_D1-0_sharan/';

% which radii
% radii = 3:1:100;        % Lauwers etc.
radii = [2.8, 5, 7.5, 10, 15, 22.5, 30, 45, 60, 90];    % sharan

for ii = 1:length(radii)
    
    % define the radius
    rr = radii(ii);
    
    % load
    load(strcat(simdir,'simvessim_res',num2str(rr),'.mat'));
    
    % pull out size
    np = size(spp,1);
    
    % pull out the first column
    phase1 = spp(1,:);
    
    % repeat
    spp = repmat(phase1,np,1);
    
    % save out
    save(strcat(simdir,'static_simvessim_res',num2str(rr),'.mat'),'p','R','spp','t');
    
    % remove the old stuff
    clear p R spp t
    
    
end
