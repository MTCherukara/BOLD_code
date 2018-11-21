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
simdir = '../../Data/vesselsim_data/';

% Which distribution we want - 'sharan' or 'frechet'
distname = 'lauwers';

% Options
plot_figure = 1;

% Fixed Parameters
TEv  = 0.072;
tau = (-28:4:64)./1000;    % For TE = 72ms or 108ms
% tau = (-12:4:32)./1000;      % For TE = 36ms

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
    load([simdir,'vs_arrays/vsArray',num2str(np),'_',distname,...
                 '_TE_',num2str(1000*TEv),'_R_',num2str(vrad),'.mat']);
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
S0 = zeros(np,np,nt);

% Crappy loop version - it would be better if this step was done using matrix
% operations, but it doesn't matter that much, and at least it works this way...
for i1 = 1:np
    
    for i2 = 1:np
        
        % S0_* dimensions:      TIME, DBV, OEF, RADIUS
        % sigASE* dimensions:   TIME, RADIUS
        sigASEev = squeeze(S0_ev(:,i2,i1,:));
        sigASEiv = squeeze(S0_iv(:,i2,i1,:));
        
        vFrac = 0.793.*DBVvals(i2).*VF;
        
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
sname = strcat(simdir,'vs_arrays/TE',num2str(1000*TEv),'_vsData_',distname,'_',num2str(np),'.mat');
TE = TEv;
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

