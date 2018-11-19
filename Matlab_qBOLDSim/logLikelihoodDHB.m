function LL = logLikelihoodDHB(D)
% Calculate the log likelihood that a looked-up set of data has a given value of
% dHb content D.
%
% How is this different from logLikelihoodR2p?
%
% MT Cherukara
% 2018-11-06

% declare global variables
global S_true param1 tau1;

% create local, editable, version of param1 and of the true data
loc_param = param1;
S_local = S_true;

% calculate long tau model
S_model = exp(-(D^loc_param.beta).*tau1./loc_param.SR);

% align data
diffS = S_model(1) - S_local(1);
S_local = S_local + diffS;

% evaluate log likelihood (sum of square differences)
LL = log(sum((S_local-S_model).^2));