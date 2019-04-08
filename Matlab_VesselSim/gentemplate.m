function p=gentemplate

    p.R     = 20e-6;    % m     - Vessel radius
    p.D     = 1e-9;     % m^2/s - Rate of diffusion
    p.B0    = 3;        % T     - Static magnetic field
    p.TE    = 84e-3;    % s     - Echo time
    p.dt    = 200e-6;   % s     - Time between steps (0.2ms) - leads to having 10 points per T
    p.Hct   = 0.40;     % -     - Fractional haematocrit
    p.Y     = 0.6;      % -     - (1-OEF)
    p.N     = 10000;    % -     - Number of particles
    
    p.gamma = 2*pi*42.58e6;
    p.universeScale = 45; %results in ~100 vessels
    p.vesselFraction = 0.03;
    p.deltaTE = 1e-3;   % s     - step size (1ms) this should give more data
    p.deltaChi0 = 0.264e-6;
    p.solidWalls = 0;

return;