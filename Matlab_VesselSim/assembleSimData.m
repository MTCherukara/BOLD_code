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

% Where the data is stored (Mac)
simdir = '/Users/mattcher/Documents/DPhil/Data/vesselsim_data/';

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
np = 10;           % number of different parameter values to generate

% Physiological Parameters
OEFvals = linspace(0.1875,0.6,np);
DBVvals = linspace(0.01,0.07,np);

% Preallocate final array
S0 = zeros(np,np,nt);


% Loop over OEF
for i1 = 1:np
    
    OEF = OEFvals(i1);
    
    % Oxygenation of each vessel, assuming arteries are 100% saturated
    Y = repmat(1-OEF,1,nr);
    
    % Loop over DBV
    for i2 = 1:length(DBVvals)
        
        DBV = DBVvals(i2);
        
        % Absolute vessel fractions. The factor of 0.793 accounts for the relative
        % distributions of veins and capillaries 
        vFractions = 0.793 .* DBV .* VF;

        % Pre-allocate results arrays
        sigASE   = zeros(nt,nr);
        sigASEev = zeros(nt,nr);
        sigASEiv = zeros(nt,nr);

        % Loop through each radius in R
        for i3 = 1:nr

            % Load the appropriate data file
            load([simdir 'single_vessel_radius_D1-0_sharan/simvessim_res' num2str(RR(i3)) '.mat']);

            % Calculate the signal
            [sigASE(:,i3), tau, sigASEev(:,i3), sigASEiv(:,i3)] = generate_signal(p,spp,'display',false,'Vf',vFractions(i3),'Y',Y(i3),'seq','ASE','includeIV',true,'T2EV',Inf,'T2b0',Inf,'TE',TE,'tau',tau);
        end

        % Total up the signal contributions
        sigASEtot = (1-sum(vFractions)).*prod(sigASEev,2)+sum(bsxfun(@times,vFractions,sigASEiv),2);

        % % Normalize to points around the spin echo
        % se = find(tau==0);
        % sigASEtotn = sigASEtot./mean(sigASEtot(se-1:se+1));

        % Normalize to the spin echo
        sigASEtotn = sigASEtot./max(sigASEtot);
        
        S0(i1,i2,:) = sigASEtotn;
        
    end % for i1 = 1:np
    
end % for i2 = 1:np


toc;


%% Save Data
if save_data
    save('vesselSimData.mat','S0','tau','TE','OEFvals','DBVvals');
end


%% Plot figure
if plot_figure

    figure; hold on; box on;
    
    % Plot 2D grid
    surf(DBVvals,OEFvals,log(S0(:,:,3)));
    view(2); shading flat;
    c=colorbar;
    
    axis([min(DBVvals),max(DBVvals),min(OEFvals),max(OEFvals)]);
    xlabel('DBV');
    ylabel('OEF');
    
end

