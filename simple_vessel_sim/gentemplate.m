function p=gentemplate

    p.R     = 20e-6;    % m     - Vessel radius
    p.D     = 1e-9;     % m^2/s - Rate of diffusion
    p.B0    = 3;        % T     - Static magnetic field
    p.TE    = 60e-3;    % s     - Echo time
    p.dt    = 200e-6;   % s     - Defines number of steps somehow
    p.Hct   = 0.4;      % -     - Fractional haematocrit
    p.Y     = 0.6;      % -     - (1-OEF)
    p.N     = 1000;     % -     - Number of particles
    
    p.gamma = 2*pi*42.58e6;
    p.universeScale = 45; %results in ~100 vessels
    p.vesselFraction = 0.05;
    p.deltaTE = 2e-3; 
    p.deltaChi0 = 0.264e-6;

return;