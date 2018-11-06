function LL = logLikelihoodDHB(D)
% Calculate the log likelihood that a looked-up set of data has a given value of
% dHb content D
%
% MT Cherukara
% 2018-11-06

% declare global variables
global S_true param1 tau1;

% create local, editable, version of param1
loc_param = param1;

loc_param.contr = 'dhb';
loc_param.dHb = D; % update D

% evaluate the model
S_model = qASE_model(tau1,loc_param.TE,loc_param);


% normalize
SEind = find(tau1 > -1e-9,1);
S_model = S_model./S_model(SEind);

% evaluate log likelihood (sum of square differences)
LL = log(sum((S_true-S_model).^2));