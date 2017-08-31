% simrunRange.m
%
% A variant of simrun.m designed to loop around particular variables and
% save them out...

clear;

save_data = 1;  % set this to 1 to save storedPhase data out, or 0 not to

% NN = 5;
NN = round(10.^(linspace(1,log10(20000),25)));
% NN = [5,10,15,20,25,30,40,50,60,80,100,125,150,200,300,400,500,750,1000,1500,2500,5000,10000];

for ii = 24;
    
    disp(['Running simulation with ',num2str(NN(ii)),' iterations']);
    tic;
    
    p=gentemplate;          % create basic set of parameters
    p.N = NN(ii);

    p.R = 1e-4;     % radius, in m
    p.D = 0;     % diffusion, in m^2/s
    p.Y = 0.6;      % oxygenation fraction (1-OEF) 
    p.vesselFraction = 0.05;    % DBV
    p.Hct = p.Hct.*ones(1,length(p.R));

    p.deltaChi = p.deltaChi0.*p.Hct.*(1-p.Y); % calculate susceptibility difference

    p.solidWalls = 0;
    [Phase_u,p] = MTC_vesselsim(p);

    % save out data
    dataname = 'newStoredPhase/VSdata_LogRange_';
    D = dir([dataname,'*']);
    
    save(strcat(dataname,num2str(length(D)+1),'.mat'),'Phase_u','p');
    toc;

end