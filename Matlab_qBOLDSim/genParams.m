function params = genParams(varargin)
% Generate a parameter structure PARAMS with the standard set of values to be 
% used in MTC_qASE.m, and derived qBOLD model scripts. Allows the user to
% specify the following parameters as name-value pair arguments:
%
%       OEF, DBV, dHb, vCSF, TE, SNR, SR, Voff, Model, incIV, incT2
%
% Other parameters can be changed manually after the PARAMS structure has been
% created
%
% MT Cherukara
% 2018-10-11
%
% CHANGELOG:


% Read user-input parameters
q = inputParser;
addParameter(q, 'TE'    , 0.072 , @isnumeric);      % Echo time
addParameter(q, 'OEF'   , 0.40  , @isnumeric);      % Oxygen extraction fraction
addParameter(q, 'DBV'   , 0.03  , @isnumeric);      % Deoxygenated blood volume
addParameter(q, 'dHb'   , 53.3  , @isnumeric);      % Deoxyhaemoglobin conc.
addParameter(q, 'vCSF'  , 0.00  , @isnumeric);      % CSF volume
addParameter(q, 'SNR'   , inf   , @isnumeric);      % Signal to noise ratio
addParameter(q, 'SR'    , 1.00  , @isnumeric);      % R2' scaling factor
addParameter(q, 'Voff'  , 0.00  , @isnumeric);      % Short-tau DBV offset
addParameter(q, 'Model' , 'Full' );                 % Simulated qBOLD model
addParameter(q, 'incIV' , true  , @islogical);      % Include Blood compartment
addParameter(q, 'incT2' , true  , @islogical);      % Include T2 weightings


parse(q,varargin{:});
r = q.Results;


% Physical constants
params.dChi = 0.264e-6;     % parts     - susceptibility difference
params.gam  = 2.67513e8;    % rad/s/T   - gyromagnetic ratio
params.B0   = 3.0;          % T         - static magnetic field

% Sequence parameters
params.TE   = r.TE;         % s         - echo time
params.TR   = 3.000;        % s         - repetition time
params.TI   = 0.000;        % s         - FLAIR inversion time

% Relaxometry parameters
params.T1t  = 1.200;        % s         - tissue T1
params.T1b  = 1.580;        % s         - blood T1
params.T1e  = 3.870;        % s         - CSF T1

params.R2t  = 11.5;         % 1/s       - rate constant, tissue
params.R2e  = 4;            % 1/s       - rate constant, extracellular

% Physiological parameters
params.OEF  = r.OEF;        % no units  - oxygen extraction fraction
params.zeta = r.DBV;        % no units  - deoxygenated blood volume
params.dHb  = r.dHb;        % g/L       - deoxyhaemoglobin concentration
params.Hct  = 0.400;        % no units  - fractional hematocrit
params.kap  = 0.003;        % ?         - conversion between Hct and [Hb]
params.S0   = 100;          % a. units  - signal
params.SR   = r.SR;         % no units  - scaling factor for R2'

% CSF Compartment-specific parameters
params.lam0 = r.vCSF;       % no units  - ISF/CSF signal contribution
params.dF   = 5;            % Hz        - frequency shift

% Simulation Parameters
params.model  = r.Model;    % STRING    - model type: 'Full','Asymp','Phenom'
params.SNR    = r.SNR;      % no units  - simulated signal to noise ratio
params.contr  = 'OEF';      % STRING    - contrast source: 'OEF','R2p','dHb',...
params.tc_man = 0;          % BOOL      - should Tc be defined manually?
params.tc_val = 0.0;        % s         - manual Tc (if tc_man = 1)
params.incT1  = 0;          % BOOL      - should T1 differences be considered?
params.incIV  = r.incIV;    % BOOL      - should the blood compartment be added?
params.incT2  = r.incT2;    % BOOL      - should blood compartment be included?
params.Voff   = r.Voff;     % no units  - offset in short-tau measurements of DBV (Beta)

% Derived parameters
params.dw = (4/3)*pi*params.gam*params.B0*params.dChi*params.Hct*params.OEF;