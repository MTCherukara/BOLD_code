% assembleSimData.m
%
% Puts together a matrix of simulated qBOLD ASE data using phase data generated
% by the simple vessel simulator. Based on figure_sharan.m (created NP Blockley
% 30 July 2018).
%
% Separated from createSimData.m

% NEED TO SAVE OUT RESULTS OF EACH RADIUS SEPARATELY, THEN COMBINE THEM LATER,
% SO THAT IT DOESN'T TAKE UP TOO MUCH SPACE IN MEMORY, OR RELY ON RUNNING
% CONTINUOUSLY FOR TOO LONG

clear;

%% Initialization

% Where the data is stored
simdir = '../../Data/vesselsim_data/';

% Which distribution we want - 'sharan' or 'frechet'
distname = 'sharan';

% Options
plot_figure = 1;

% Fixed Parameters
TE  = 0.072;
tau = (-28:4:64)./1000;

% Vessel Distribution
if strcmp(distname,'sharan')
    RR = [ 2.8  , 7.5  , 15.0 , 22.5 , 45.0 , 90.0  ];
    VF = [ 0.412, 0.113, 0.117, 0.116, 0.121, 0.121 ];
    
elseif strcmp(distname,'frechet')
    RR = 3:100;
    VF = gevpdf(RR,0.41,5.8,10.1);
    VF = VF./sum(VF);
    
end

% Array sizes
nr = length(RR);    % number of different vessel radii
nt = length(tau);   % number of tau values
np = 100;           % number of different parameter values to generate

% Preallocate arrays
%       Dimensions: TIME, DBV, OEF, RADIUS
S0_ev  = zeros(nt,np,np,nr);     % extravascular (tissue) signal
S0_iv  = zeros(nt,np,np,nr);     % intravascular (blood) signal


%% Collect signals from all radii

% Loop over Radii
for i1 = 1:nr
    
    vrad = RR(i1);
    
    % Load data
    load([simdir,'vs_arrays/vsArray',num2str(np),'_',distname,'_R_',num2str(vrad),'.mat']);
    
    % Fill matrix
    %       Dimensions: TIME, DBV, OEF, RADIUS
    S0_ev(:,:,:,i1) = S_ev;
    S0_iv(:,:,:,i1) = S_iv;
   
end % Radius loop


%% Total up the signal contributions

% % Create matrix of effective Total DBV values
% DBVmat = repmat(0.793.*DBVvals,nt,1,np);
% 
% % Total up the extravascular signals
% sig_EV = (1-DBVmat).*prod(S0_ev,4);
% 
% % Create a matrix of effective Radius-specific DBV values
% RVmat = repmat(DBVmat,1,1,1,nr) .* shiftdim(repmat(VF',1,nt,np,np),1);
% 
% % Total up the intravascular signals
% sig_IV = sum(RVmat.*S0_iv,4);
% 
% % Total signal, and shuffle the dimensions so that they're consistent with the
% % other data
% S0 = shiftdim(sig_EV + sig_IV,1);
% 
% % Normalize to the spin echo - we know that Tau=0 is at index 8
% S0 = S0./repmat(S0(:,:,8),1,1,24);

% Preallocate S0 array
%       Dimensions: DBV, OEF, TIME
S0 = zeros(np,np,nt);

% Crappy loop version - it would be better if this step was done using matrix
% operations, but it doesn't matter that much, and at least it works this way...
for i1 = 1:np
    
    for i2 = 1:np
        
        % S0_* dimensions:      TIME, DBV, OEF, RADIUS
        % sigASE* dimensions:   TIME, RADIUS
        sigASEev = squeeze(S0_ev(:,i2,i1,:));
        sigASEiv = squeeze(S0_ev(:,i2,i1,:));
        
        vFrac = 0.793.*DBVvals(i2).*VF;
        
        % Stot dimensions:  TIME
        Stot = (1-sum(vFrac)).*prod(sigASEev,2)+sum(bsxfun(@times,vFrac,sigASEiv),2);
        Stot = Stot./Stot(8);
        
        % S0 dimensions:    DBV, OEF, TIME
        S0(i2,i1,:) = Stot;
        
    end % DBV loop
    
end % OEF loop


%% Save Data
sname = strcat(simdir,'vs_arrays/vsData_',distname,'_',num2str(np),'.mat');
save(sname,'S0','S_ev','S_iv','tau','TE','OEFvals','DBVvals');
    

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

