% xBloodCompartments.m
%
% Plot ASE signals from the different models of the intravascular (blood)
% compartment
%
% MT Cherukara
% 28 May 2019

clear;
% close all;

setFigureDefaults;

% Parameters
tau = linspace(-0.028,0.064,1000); % for visualising
TE  = 0.072;

OEF = 0.4;
DBV = 0.03;
Hct = 0.4;

gam = 2.67513e8;
B0  = 3;
dChi = 0.264e-6; 

dw  = (4/3)*pi*gam*B0*dChi*Hct*OEF;


%% Old school model
R2bp = (10.2 - ( 1.5*Hct)) + ( ((136.9*Hct) - 13.9)*(OEF.^2) );

SO = exp(-R2bp*abs(tau));


%% Motional narrowing (Berman)

td  = 0.0045067;
dChi = ((0.27*OEF)+0.14)*1e-6;
G0   = (4/45)*Hct*(1-Hct)*((dChi*B0)^2);
kk   = 0.5*(gam^2)*G0*(td^2);
TEF  = (TE - tau)./2;

% SB = exp(-kk.*( (TE./td) + sqrt(0.25 + (TE./td)) + 1.5 - ...
%                     (2.*sqrt( 0.25 + ( ((TE + tau).^2) ./ td ) ) ) - ...
%                     (2.*sqrt( 0.25 + ( ((TE - tau).^2) ./ td ) ) ) ) );
%                 
SB = exp(-kk.* ( (TE./td) + sqrt(0.25 + (TE./td)) + 1.5 - ... 
                 ( 2.*sqrt(0.25 + (TE - TEF)./td) ) - ...
                 ( 2.*sqrt(0.25 + (TEF./td) ) ) ) );
             
% SB = exp(-kk.* ( (abs(tau)./td) - sqrt(0.25 + (abs(tau)./td)) + 0.5 ) );
                
                
%% Powder model (Sukstanskii)

dw0 = 1.5*dw;
eta = sqrt((2.*dw0.*abs(tau))./pi);

SI = exp(1i.*dw0.*abs(tau)./3) .* ( (fresnelc(eta) - 1i.*fresnels(eta)) ./eta);
    
SP = real(SI);


%% Plot them

figure;
plot(1000*tau,(SO));
hold on; box on; axis square; grid on;
plot(1000*tau,(SB));
plot(1000*tau,(SP));
xlim([-32,68]);
xlabel('Spin echo displacement \tau (ms)');
ylabel('Signal');
legend('Linear Model','Motional Narrowing','Powder Model','Location','SouthWest');
