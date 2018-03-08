% function [r2p, dbv, oef, dhb] = ase_qbold_3d(nii_name,start_tau,delta_tau,end_tau,nii_out)
% nii_name: Z-averaged ASE dataset
% start_tau [ms] value of tau for first volume
% delta_tau [ms] tau step size
% set end_tau [ms] ... value of tau for last volume
% nii_out ... output nifti's and save figs? 1=Yes,0=No 

clear;

subj = 7;

start_tau = -28;
delta_tau = 4;
end_tau = 64;
nii_out = 1;

niidir = ['/Users/mattcher/Documents/DPhil/Data/validation_sqbold/vs',num2str(subj),'/'];

nii_name = strcat(niidir,'sub0',num2str(subj),'_ASE_FLAIR_av_mc.nii.gz');
msk_name = strcat(niidir,'mask_flair.nii.gz');

%% Load dataset
[V,~,scales] = read_avw(nii_name);
[x, y, z, v] = size(V);

% Load Mask
msk = read_avw(msk_name);
V = V.*repmat(msk,[1,1,1,v]);

%% Fit R2'
% Constants
Hct = 0.40; % hct ratio in small vessels - changed to 0.4 for consistency
dChi0 = 0.264*10^-6; % ppm, sus difference between fully oxy & deoxy rbc's
gamma = 2.675*10^4; % rads/(secs.Gauss) gyromagnetic ratio
B0 = 3*10^4; %Gauss, Field strength
phi = 1.34; % mlO2/gHb
k = 0.03; % conversion factor Hct (% rbc's in blood) to Hb (iron-containing molecules in the rbc's used to transport o2)


% X
% Convert tau to seconds
tau = (start_tau:delta_tau:end_tau).*1e-3;


% Check that tau matches the number of volumes 

if (length(tau) ~= v)
    disp('List of Tau values doesn''t match the number of volumes') 
    %disp(tau)
%     sprintf('Number of volumes = %1.0f', v)
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

range_r2p = [0 7];
range_dbv = [0 0.12];
range_oef = [0 1.0];
range_dhb = [0 10];

% Calculate Physiological Parameters
s0_id = find(tau == 0);
r2p = -p(:,:,:,1); 
c = p(:,:,:,2);
dbv = c - ln_Sase(:,:,:,s0_id);
oef = r2p./(dbv.*gamma.*(4./3).*pi.*dChi0.*Hct.*B0);
dhb = r2p./(dbv.*gamma.*(4./3).*pi.*dChi0.*B0.*k);

% Display parameter maps
% imgH_r2p = brain_montage(r2p, range_r2p, 0, 'R_2''','R2''','JetBlack', '[s^{-1}]',[1 z]);
% if nii_out, print('r2p.eps','-depsc2','-r300'), end
% imgH_dbv = brain_montage(dbv, range_dbv, 0, 'DBV','DBV','JetBlack', '[%]',[1 z]);
% if nii_out, print('dbv.eps','-depsc2','-r300'), end
% imgH_oef = brain_montage(oef, range_oef, 0, 'OEF','OEF','JetBlack', '[%]',[1 z]);
% if nii_out, print('oef.eps','-depsc2','-r300'), end
% imgH_dhb = brain_montage(dhb, range_dhb, 0, 'dHb','dHb','JetBlack', '[g.dl^{-1}]',[1 z]);
% if nii_out, print('dhb.eps','-depsc2','-r300'), end

%% Output parameter niftis
if nii_out
    
    save_avw(r2p, 'mean_R2p', 'f', scales)
    save_avw(dbv, 'mean_DBV', 'f', scales)
    save_avw(oef, 'mean_OEF', 'f', scales)
    save_avw(dhb, 'mean_dHb', 'f', scales)

%     saveas(imgH_r2p, 'r2p.fig')
%     saveas(imgH_dbv, 'dbv.fig')
%     saveas(imgH_oef, 'oef.fig')
%     saveas(imgH_dhb, 'dhb.fig')
   
end

end