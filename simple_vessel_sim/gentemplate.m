function p=gentemplate;

    p.R = 20e-6; %m
    p.universeScale = 45; %results in ~100 vessels
    p.D = 1e-9; %m^2/s
    p.vesselFraction = 0.05;
    p.B0 = 3; %T
    p.gamma = 2*pi*42.58e6;
    p.TE = 60e-3;
    p.deltaTE = 2e-3; 
    p.dt = 200e-6;
    p.Hct = 0.4;
    p.Y = 0.6;
    p.deltaChi0 = 0.264e-6;
    p.N = 10000;

return;