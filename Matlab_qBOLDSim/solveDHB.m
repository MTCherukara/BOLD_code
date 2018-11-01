function LL = solveDHB(xx)
    % A function to solve the long-tau DHB problem
    %
    % MT Cherukara
    % 2018-11-01
    
% declare global variables
global KK arrDHB arrTAU arrS0

% extract the two parameters
beta  = xx(1);
kappa = xx(2);
% kappa = 1;

% calculate model (normalized to log(S) = DBV)
S_model = (1 - KK.*((arrDHB./kappa).^beta).*arrTAU);

% compare models
ssd = (S_model-arrS0).^2;
LL = sum(ssd(:));