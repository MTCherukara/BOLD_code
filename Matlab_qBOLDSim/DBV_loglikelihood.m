function LL = DBV_loglikelihood(DBV)
% Calculate the log likelihood that a looked-up set of data has a value of
% deoxygenated blood volume DBV. For use within the FMINBND (or similar) script
% only. Will have to have a lot of hard-coded stuff that it looks up. Requires
% qASE_model.m
%
% MT Cherukara
% 2018-10-02

% declare global variables
global S_true param1 tau1;

% create local, editable, version of param1
loc_param = param1;

loc_param.zeta = DBV;   % update DBV
loc_param.asymp  = 1;   % use only the asymptotic model, for the sake of time

% evaluate the model
S_model = qASE_model(tau1,loc_param.TE,loc_param);

% normalize
S_model = S_model./max(S_model);

% evaluate log likelihood (sum of square differences), since we're trying
% maximise the log-likelihood, we want a function which is the negation of it to
% minimize
LL = log(sum((S_true-S_model).^2));