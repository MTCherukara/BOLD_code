% function [r2p, dbv, oef, dhb] = ase_qbold_3d(nii_name)
% nii_name: Z-averaged ASE dataset
% start_tau [ms] value of tau for first volume
% delta_tau [ms] tau step size
% set end_tau [ms] ... value of tau for last volume
% nii_out ... output nifti's and save figs? 1=Yes,0=No 

clear;

start_tau = -28;
delta_tau = 4;
end_tau = 64;

if ~exist('nii_name','var')
    [dfile,ddir] = uigetfile('*.nii.gz','Choose Data File');
    nii_name = strcat(ddir,dfile);
end

%% Load dataset
[V, ~, scales] = read_avw(nii_name); % V = the raw data;
[x, y, z, v] = size(V);
%disp(size(V))

%% Fit R2'
% Constants
Hct = 0.4; % hct ratio in small vessels
dChi0 = 0.264*10^-6; % ppm, sus difference between fully oxy & deoxy rbc's
gamma = 2.675*10^4; % rads/(secs.Gauss) gyromagnetic ratio
B0 = 3*10^4; %Gauss, Field strength
phi = 1.34; % mlO2/gHb
k = 0.03; % conversion factor Hct (% rbc's in blood) to Hb (iron-containing molecules in the rbc's used to transport o2)


% X
% Convert tau to seconds
tau = [start_tau:delta_tau:end_tau];
tau = tau.*10^-3;

% Check that tau matches the number of volumes 

if (length(tau) ~= v)
    disp('List of Tau values doesn''t match the number of volumes') 
    %disp(tau)
    sprintf('Number of volumes = %1.0f', v)
    
else

% Y
ln_Sase = log(V); 
ln_Sase(isnan(ln_Sase)) = 0; 
ln_Sase(isinf(ln_Sase)) = 0;

Tc = 0.015; % cutoff time for monoexponential regime [s]
tau_lineID = find(tau > Tc); % tau's to be used for R2' fitting  
w = 1./tau(1,tau_lineID)'; % weightings for lscov
p = zeros(x,y,z,2); 

for xID = 1:x
    for yID = 1:y
        for zID = 1:z
%             fprintf('xID%d ; yID%d ; zID%d \n',xID,yID,zID) 
            %% LSCOV: fit linear regime
            X = [ones(length(tau(1,tau_lineID)'),1) tau(1,tau_lineID)'];
            Y = squeeze(ln_Sase(xID,yID,zID,tau_lineID));

            p(xID,yID,zID,:) = flipud(lscov(X,Y,w));        
        end
    end
end


% Calculate Physiological Parameters
s0_id = find(tau == 0);
r2p = -p(:,:,:,1); 
c = p(:,:,:,2);
dbv = c - ln_Sase(:,:,:,s0_id);
oef = r2p./(dbv.*gamma.*(4./3).*pi.*dChi0.*Hct.*B0);
dhb = r2p./(dbv.*gamma.*(4./3).*pi.*dChi0.*B0.*k);

%% Calculate residuals by re-generating some signal data
taus = shiftdim(repmat(tau',1,64,64,10),1);
S0 = V(:,:,:,s0_id);
Snew = S0.*exp(-repmat(r2p,1,1,1,24).*taus + repmat(dbv,1,1,1,24));

res = V(:,:,:,tau_lineID) - Snew(:,:,:,tau_lineID);

snr = Snew(:,:,:,tau_lineID) ./ abs(res);

%% Output parameter niftis
    
    save_avw(r2p, 'qbold_results/mean_R2p', 'f', scales);
    save_avw(dbv, 'qbold_results/mean_DBV', 'f', scales);
    save_avw(oef, 'qbold_results/mean_OEF', 'f', scales);
    save_avw(res, 'qbold_results/residuals','f', scales);
    save_avw(snr, 'qbold_results/modelSNR', 'f', scales);
%     save_avw(dhb, 'dhb', 'f', scales);

%     saveas(imgH_r2p, 'r2p.fig')
%     saveas(imgH_dbv, 'dbv.fig')
%     saveas(imgH_oef, 'oef.fig')
%     saveas(imgH_dhb, 'dhb.fig')
   

end
% end