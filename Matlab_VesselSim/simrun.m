clear variables;

p=gentemplate;          % create basic set of parameters
p.N = 1000;
 
p.R = 1e-4;     % radius, in m
p.D = 1e-8;        % diffusion, in m^2/s
% p.Y = 0.6;      % oxygenation fraction (1-OEF) 
p.vesselFraction = 0.05;    % DBV

X = 0.7*ones(1,10);

% pre-allocate phase storage arrays
ph_steps = round((p.TE*2)/p.dt)./round(p.deltaTE./p.dt);
Phase_u = zeros(ph_steps,p.N,length(X));
Phase_n = zeros(ph_steps,p.N,length(X));
sASE_u  = zeros(round(500*p.TE)+1,length(X));
sASE_n  = zeros(round(500*p.TE)+1,length(X));

for j = 1:length(X)
    
    p.Y = X(j);
    p.deltaChi = p.deltaChi0.*p.Hct.*(1-p.Y); % calculate susceptibility difference
    
    disp(['Running j = ',num2str(j)]);
    
    p.solidWalls = 0;
    [Phase_u(:,:,j),p] = simplevesselsim(p);
    [sASE_u(:,j), tASE]  = MTC_plotSignal(p,Phase_u(:,:,j),'sequence','ASE','display',false);
    
    p.solidWalls = 1;
    [Phase_n(:,:,j),p] = simplevesselsim(p);
    [sASE_n(:,j), tASE]  = MTC_plotSignal(p,Phase_n(:,:,j),'sequence','ASE','display',false);
    
    disp(['  j = ',num2str(j),' completed']);   
    
end

% save out data
if p.D == 0
    diffterm = '_Static_';
else
    diffterm = '_Diffusion_';
end
dataname = ['storedPhase\VesselSim_data_',date,'_Walls'];
D = dir([dataname,'*']);
save(strcat(dataname,num2str(length(D)+1),'.mat'),'Phase_n','Phase_u','sASE_n','sASE_u','tASE','X','p');
