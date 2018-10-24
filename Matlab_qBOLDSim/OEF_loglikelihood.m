function LL = OEF_loglikelihood(OEF)
% Calculate the log likelihood that a looked-up set of data has a given value of
% OEF. For use within the FMINBND (or similar) script only. Requires
% qASE_model.m. Derived from DBV_loglikelihood.m
%
% MT Cherukara
% 2018-10-24

% declare global variables
global S_true param1 tau1;

% create local, editable, version of param1
loc_param = param1;

loc_param.OEF = OEF;   % update DBV

% evaluate the model
S_model = qASE_model(tau1,loc_param.TE,loc_param);

% normalize
SEind = find(tau1 > -1e-9,1);

S_model = S_model./S_model(SEind);

% evaluate log likelihood (sum of square differences), since we're trying
% maximise the log-likelihood, we want a function which is the negation of it to
% minimize
LL = log(sum((S_true-S_model).^2));