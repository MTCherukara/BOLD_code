% createSimData.m
%
% Puts together a matrix of simulated qBOLD ASE data using phase data generated
% by the simple vessel simulator. Based on figure_sharan.m (created NP Blockley
% 30 July 2018).
%
% Separated into this file, and assembleSimData.m

clear;

t0 = tic; % main timer

%% Initialization

% Where the data is stored
simdir = '../../Data/vesselsim_data/';

% Selet distribution 
distname = 'sharan';

% Fixed Parameters
TE  = 0.048;
tau = (0:4:40)./1000;    % For TE = 72ms or 108ms or 84 ms
% tau = (-12:4:32)./1000;      % For TE = 36ms or 56 ms

% Vessel Distribution
switch lower(distname)
    case 'sharan'
        dirname  = 'D1-0_sharan';
        RR = [ 2.8  , 7.5  , 15.0 , 22.5 , 45.0 , 90.0  ];
        VF = [ 0.412, 0.113, 0.117, 0.116, 0.121, 0.121 ];
        
    case 'frechet'
        dirname  = 'D1-0Vf3pc_dist';
        RR = 3:100;
        VF = gevpdf(RR,0.41,5.8,10.1);
        VF = VF./sum(VF);
        
    case 'lauwers'
        dirname = 'D1-0Vf3pc_dist';
        RR = 3:100;
        DT = 1./sqrt(2*RR);
        VF = normpdf(DT,0.38,0.07);
        VF = VF./sum(VF);
        
    otherwise
        disp('Invalid distribution');
end

% Array sizes
nr = length(RR);    % number of different vessel radii
nt = length(tau);   % number of tau values
np = 50;           % number of different parameter values to generate

% Physiological Parameters
% OEFvals = linspace(0.21,0.7,np);
% DBVvals = linspace(0.003,0.15,np);

OEFvals = linspace(0.01,1,100);
% OEFvals = 0.4;
DBVvals = 0:0.01:0.09;

% Decide on which radii to calculate
rstart = 1;
rend   = 6;

% lengths
nd = length(DBVvals);
no = length(OEFvals);


%% Generate signals for each radius

% Loop over Radii
for i1 = rstart:rend
    
    t1 = tic;   % internal timer
    
    vrad = RR(i1);
    volf = VF(i1);
    
    disp(['Assembling dataset ',num2str(i1),' of ',num2str(nr),' (R = ',num2str(vrad),'um)']);
    
    load([simdir,'single_vessel_radius_',dirname,'/simvessim_res',num2str(vrad),'.mat']);
    
    % pre-allocate radius-level array.
    %       Dimensions: TIME, DBV, OEF
    S_ev = zeros(nt,nd,no);
    S_iv = zeros(nt,nd,no);

    
    % Parallel Loop over OEF
    parfor i2 = 1:no
        
        OEF = OEFvals(i2);
        Y = 1-OEF;
        
        Vvals = DBVvals;    % to avoid using DBVvals as a broadcast variable
        
        % Compute T2 of blood
        R2b = 5.29;
        
        % Pre-allocate some arrays to fill within the inner loop,
        %       Dimensions: TIME, DBV
        Sin_EV  = zeros(nt,nd);
        Sin_IV  = zeros(nt,nd);
        
        % Loop over DBV
        for i3 = 1:nd
            
            DBV = Vvals(i3);
            
            % Vessel fraction. The factor 0.793 should account for the relative
            % contribution of capillaries to total DBV
            vFrac = 0.793.*DBV.*volf;
            
            % Calculate signal
            [Sin_EV(:,i3), Sin_IV(:,i3)] = generate_signal(p,spp,...
                'display',false,'Vf',vFrac,'Y',Y,'seq','ASE','includeIV',true,...
                'T2EV',0.087,'T2b0',1/R2b,'TE',TE,'tau',tau);
            
        end % DBV loop
        
        % Fill the main arrays (Dimensions: TIME, DBV, OEF)
        S_ev(:,:,i2) = Sin_EV;
        S_iv(:,:,i2) = Sin_IV;
        
    end % OEF loop
    
    % Save out data for each radius
    sname = strcat(simdir,'vs_arrays/vsArray',num2str(nd),'_',distname,...
                   '_TE_',num2str(1000*TE),'_R_',num2str(vrad),'.mat');
    save(sname,'S_ev','S_iv','tau','TE','OEFvals','DBVvals');
    
    % Timer
    te1 = toc(t1);
    disp(['  Time for this iteration: ',round2str(te1,1),' seconds']);
       
end % Radius loop

% Timer
te0 = toc(t0);
disp(['Total time is ',round2str(te0,0),' seconds']);

