% assembleSimData.m
%
% Puts together a matrix of simulated qBOLD ASE data using phase data generated
% by the simple vessel simulator. Based on figure_sharan.m (created NP Blockley
% 30 July 2018).
%
% Separated from createSimData.m

clear;

%% Initialization

% Where the data is stored
% simdir = '../../Data/vesselsim_data/';                  % Mac
simdir = 'D:\Matthew\1_DPhil\Data\vesselsim_data\';     % Windows


% Which distribution we want - 'sharan' or 'frechet'
distname = 'lauwers';

% Options
plot_figure = 0;

% Do we want to use pre-defined random OEF-DBV pairs? If so, pick 1-5
paramPairs = 3;

% Fixed Parameters
TE  = 0.112;
% tau = (-16:8:64)./1000;    % For TE = 72ms or 108ms or 84 ms
% tau = (-24:12:96)./1000;      % For TE = 36ms
% tau = (-8:4:32)./1000;
tau = (-100:2:100)./1000;     


% Vessel Distribution
switch lower(distname)
    case 'sharan'
        RR = [ 2.8  , 7.5  , 15.0 , 22.5 , 45.0 , 90.0  ];
        VF = [ 0.412, 0.113, 0.117, 0.116, 0.121, 0.121 ];
        
    case 'frechet'
        RR = 3:100;
        VF = gevpdf(RR,0.41,5.8,10.1);
        VF = VF./sum(VF);
        
    case 'lauwers'
        RR = 3:50;
        DT = 1./sqrt(2*RR);
        VF = normpdf(DT,0.38,0.07);
        VF = VF./sum(VF);
        
    case 'single'
        dirname = 'D1-0Vf3pc_dist';
        RR = [5, 6];
        VF = 0.5*ones(length(RR),1);
        
    otherwise
        disp('Invalid distribution');
end

% Array size
nr = length(RR);    % number of different vessel radii
nt = length(tau);   % number of tau values
    
if paramPairs == 0   
    nd = 10;            % number of DBV values  
    no = 100;            % number of OEF values 
else
    nd = 100;
    no = 10;
end

% Preallocate arrays
%       Dimensions: TIME, DBV, OEF, RADIUS
S0_ev  = zeros(nt,nd,no,nr);     % extravascular (tissue) signal
S0_iv  = zeros(nt,nd,no,nr);     % intravascular (blood) signal


%% Collect signals from all radii

% Loop over Radii
for i1 = 1:nr
    
    vrad = RR(i1);
    
    % Load data
    if paramPairs == 0

        load([simdir,'vs_arrays/vsArray',num2str(nd),'_',distname,...
                     '_TE_',num2str(1000*TE),...
                     '_tau_',num2str(1000*max(tau)),...
                     '_R_',num2str(vrad),'.mat']);
                 
    else
        
        load([simdir,'vs_arrays/vsArray_RND_',num2str(paramPairs),...
                   '_',distname,...
                   '_TE_',num2str(1000*TE),...
                   '_tau_',num2str(1000*max(tau)),...
                   '_R_',num2str(vrad),'.mat']);
               
    end

%     load([simdir,'vs_arrays/vsArray',num2str(np),'_',distname,...
%                  '_R_',num2str(vrad),'.mat']);
    % Fill matrix
    %       Dimensions: TIME, DBV, OEF, RADIUS
    S0_ev(:,:,:,i1) = S_ev;
    S0_iv(:,:,:,i1) = S_iv;
   
end % Radius loop


%% Total up the signal contributions

% Preallocate S0 array
%       Dimensions: DBV, OEF, TIME
S0 = zeros(nd,no,nt);

% Crappy loop version - it would be better if this step was done using matrix
% operations, but it doesn't matter that much, and at least it works this way...
for i1 = 1:no
    
    for i2 = 1:nd
        
        % S0_* dimensions:      TIME, DBV, OEF, RADIUS
        % sigASE* dimensions:   TIME, RADIUS
        sigASEev = squeeze(S0_ev(:,i2,i1,:));
        sigASEiv = squeeze(S0_iv(:,i2,i1,:));
        
        vFrac = 0.793.*DBVvals(i2,i1).*VF;
        
        % Stot dimensions:  TIME
%         Stot = (1-sum(vFrac)).*prod(sigASEev,2)+sum(bsxfun(@times,vFrac,sigASEiv),2);
        Stot = (1-sum(vFrac)).*prod(sigASEev,2);        % EV only
        SEind = find(tau > -1e-9,1);
        Stot = Stot./Stot(SEind);
        
        % S0 dimensions:    DBV, OEF, TIME
        S0(i2,i1,:) = Stot;
        
    end % DBV loop
    
end % OEF loop


%% Save Data

if paramPairs == 0

    % sname = strcat(simdir,'vs_arrays/TE',num2str(1000*TE),'_vsData_',distname,'_R_',num2str(RR(1)),'.mat');
    sname = strcat(simdir,'vs_arrays/TE',num2str(1000*TE),...
                                   '_tau_',num2str(1000*max(tau)),...
                                   '_vsData_',distname,'_100.mat');
else
    sname = strcat(simdir,'vs_arrays/DataRND_',num2str(paramPairs),...
                   '_TE_',num2str(1000*TE),...
                   '_tau_',num2str(1000*max(tau)),...
                   '_',distname,'_100.mat');
end
save(sname,'S0','S_ev','S_iv','tau','TE','OEFvals','DBVvals');
    

%% Plot figure
if plot_figure
    
    setFigureDefaults;

    figure; hold on; box on;
    
    % Plot 2D grid
    surf(DBVvals,OEFvals,log(S0(:,:,1)'));
    view(2); shading flat;
    c=colorbar;
    
    axis([min(DBVvals),max(DBVvals),min(OEFvals),max(OEFvals)]);
    xlabel('DBV (%)');
    ylabel('OEF (%)');
    
%     xticks(0.01:0.01:0.07);
%     xticklabels({'1','2','3','4','5','6','7'});
%     yticks(0.2:0.1:0.6);
%     yticklabels({'20','30','40','50','60'});
    
end

