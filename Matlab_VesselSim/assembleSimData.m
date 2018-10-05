% assembleSimData.m
%
% Puts together a matrix of simulated qBOLD ASE data using phase data generated
% by the simple vessel simulator. Based on figure_sharan.m (created NP Blockley
% 30 July 2018).

% NEED TO RE-WRITE THIS SO THAT IT IS SMARTER / MORE EFFICIENT
%       - USE PARFOR!

% NEED TO INCORPORATE T2 SIGNAL PROPERLY

clear;
tic; 

%% Initialization

% Where the data is stored
simdir = '../../Data/vesselsim_data/';

% Options
save_data = 1;
plot_figure = 1;

% Fixed Parameters
TE  = 0.072;
tau = (-28:4:64)./1000;

% Vessel Distribution (Sharan)
RR = [ 2.8  , 7.5  , 15.0 , 22.5 , 45.0 , 90.0  ];
VF = [ 0.412, 0.113, 0.117, 0.116, 0.121, 0.121 ];

% Array sizes
nr = length(RR);    % number of different vessel radii
nt = length(tau);   % number of tau values
np = 100;           % number of different parameter values to generate

% Physiological Parameters
OEFvals = linspace(0.1875,0.6,np);
DBVvals = linspace(0.01,0.07,np);

% Preallocate arrays
S_ev  = zeros(nt,np,np,nr);     % extravascular (tissue) signal
S_iv  = zeros(nt,np,np,nr);     % intravascular (blood) signal


%% Generate signals for each radius

% Loop over Radii
for i1 = 1:nr
    
    vrad = RR(i1);
    volf = VF(i1);
    
    disp(['Assembling dataset ',num2str(i1),' of ',num2str(nr),' (r = ',num2str(vrad),'um)']);
    
    load([simdir 'single_vessel_radius_D1-0_sharan/simvessim_res' num2str(vrad) '.mat']);
    
    % Loop over OEF
    parfor i2 = 1:np
        
        OEF = OEFvals(i2);
        Y = 1-OEF;
        
        Vvals = DBVvals;    % to avoid using DBVvals as a broadcast variable
        
        % Compute T2 of blood
        R2b = 4.5 + 16.4*p.Hct + (165.2*p.Hct + 55.7)*OEF^2;

        % Pre-allocate some arrays to fill within the inner loop
        Sin_EV  = zeros(nt,np);
        Sin_IV  = zeros(nt,np);
        
        % Loop over DBV
        for i3 = 1:np
            
            DBV = Vvals(i3);
            
            % Vessel fraction. The factor 0.793 should account for the relative
            % contribution of capillaries to total DBV
            vFrac = 0.793.*DBV.*volf;
            
            % Calculate signal
            [~, ~, Sin_EV(:,i3), Sin_IV(:,i3)] = generate_signal(p,spp,...
                'display',false,'Vf',vFrac,'Y',Y,'seq','ASE','includeIV',true,...
                'T2EV',0.087,'T2b0',1/R2b,'TE',TE,'tau',tau);
            
        end % DBV loop
        
        % Fill the main arrays
        S_ev(:,:,i2,i1) = Sin_EV;
        S_iv(:,:,i2,i1) = Sin_IV;
        
    end % OEF loop
   
end % Radius loop


%% Total up the signal contributions

% Create matrix of effective Total DBV values
DBVmat = repmat(0.793.*DBVvals,nt,1,np);

% Total up the extravascular signals
sig_EV = (1-DBVmat).*prod(S_ev,4);

% Create a matrix of effective Radius-specific DBV values
RVmat = repmat(DBVmat,1,1,1,nr) .* shiftdim(repmat(RR',1,nt,np,np),1);

% Total up the intravascular signals
sig_IV = sum(RVmat.*S_iv,4);

% Total signal, and shuffle the dimensions so that they're consistent with the
% other data
S0 = shiftdim(sig_EV + sig_IV,1);

% Normalize to the spin echo - we know that Tau=0 is at index 8
S0 = S0./repmat(S0(:,:,8),1,1,24);

toc;


%% Save Data
if save_data
    save('vesselSimData.mat','S0','S_ev','S_iv','tau','TE','OEFvals','DBVvals');
end


%% Plot figure
if plot_figure
    
    setFigureDefaults;

    figure; hold on; box on;
    
    % Plot 2D grid
    surf(DBVvals,OEFvals,log(S0(:,:,3)));
    view(2); shading flat;
    c=colorbar;
    
    axis([min(DBVvals),max(DBVvals),min(OEFvals),max(OEFvals)]);
    xlabel('DBV (%)');
    ylabel('OEF (%)');
    
    xticks(0.01:0.01:0.07);
    xticklabels({'1','2','3','4','5','6','7'});
    yticks(0.2:0.1:0.6);
    yticklabels({'20','30','40','50','60'});
    
end

