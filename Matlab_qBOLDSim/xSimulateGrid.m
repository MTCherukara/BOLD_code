% xSimulateGrid.m

% Generate a grid of normalized simulated ASE data with a range of OEF and DBV
% values, which will then be used for FABBER inference (or for grid search
% inference, one entry at a time).

% Based on MTC_qASE.m

% MT Cherukara
% 5 December 2018

clear;

%% Set parameters

TE = 0.084;
tau = (-16:8:64)/1000;
SEind = 3; % in this case

% 30x30 data
% OEFvals = 0.10:0.025:0.825;
% DBVvals = 0.009:0.003:0.096;

% 50x50 narrower range
OEFvals = 0.21:0.01:0.70;
DBVvals = 0.003:0.003:0.15;

% % 4x4 data
% OEFvals = 0.2:0.2:0.8;
% DBVvals = 0.03:0.02:0.09;

% create a parameters structure
params = genParams;

% set specific parameter for our simulation
params.model  = 'Full';     % STRING    - model type: 'Full','Asymp','Phenom','Kiselev'
params.contr  = 'OEF';      % STRING    - contrast source: 'OEF','R2p','dHb',...
params.incT1  = 1;          % BOOL      - should T1 differences be considered?
params.incT2  = 1;          % BOOL      - should T2 differences be considered?
params.incIV  = 1;          % BOOL      - should blood compartment be included?
params.TE     = TE;         % s         - Echo time

% noise 
SNR = 5;

%% Loop over values, computing the model

% pre-allocate results array - dimensions: OEF, DBV, BLANK, TIME
nt = length(tau);
no = length(OEFvals);
nv = length(DBVvals);
ase_data  = zeros(no,nv,1,nt);
ase_model = zeros(no,nv,1,nt);
OEF_grid  = zeros(no,nv,1);
DBV_grid  = zeros(no,nv,1);

for i1 = 1:no
    
    for i2 = 1:nv
        
        % create a local version of params
        inparam = params;
        inparam.OEF  = OEFvals(i1);
        inparam.zeta = DBVvals(i2);
        
        % compute model
        S_model = qASE_model(tau,TE,inparam);
        
        % add Gaussian noise
        sigma = mean(S_model)./SNR;
        S_data = S_model + sigma.*randn(1,nt);
        
        % normalize data to the spin echo
        S_data = S_data./S_data(SEind);
        
        % fill array - dimensions: OEF, DBV, BLANK, TIME
        ase_data(i1,i2,1,:)  = S_data;
        ase_model(i1,i2,1,:) = S_model;
        OEF_grid(i1,i2,1)  = OEFvals(i1);
        DBV_grid(i1,i2,1)  = DBVvals(i2);
        
    end % DBV loop
    
end % OEF loop


%% Save out data
dname = strcat('ASE_Grid_2C_',num2str(no),'x',num2str(nv),'_SNR_',num2str(SNR));
save([dname,'.mat'],'ase_data','ase_model','tau','TE','params','OEFvals','DBVvals');
save_avw(100.*ase_data,[dname,'.nii.gz'],'d',[1,1,1,3]);
% save_avw(OEF_grid,[dname,'_OEF.nii.gz'],'d',[1,1,1,3]);
% save_avw(DBV_grid,[dname,'_DBV.nii.gz'],'d',[1,1,1,3]);

