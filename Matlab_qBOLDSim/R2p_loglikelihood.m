function LL = R2p_loglikelihood(RR)
% Calculate the log likelihood that a looked-up set of data has a value of R2'
% (reversible transverse relaxation rate) RR. For use within the FMINBND (or
% similar) script only.
% 
% Modified from DBV_loglikelihood.m
%
% MT Cherukara
% 2018-10-22


% declare global variables
global S_true tau1;

% caluclate signal given RR
S_new = -RR.*tau1;

% evaluate log likelihood (sum of square differences), since we're trying
% maximise the log-likelihood, we want a function which is the negation of it to
% minimize
LL = log(sum((S_true-S_new).^2));