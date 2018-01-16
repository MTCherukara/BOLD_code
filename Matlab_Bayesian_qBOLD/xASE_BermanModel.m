% xASE_BermanModel.m

% testing the Berman model against the full qBOLD model

clear;

% load data
load('ASE_Data/Data_180104_Bessel_24t.mat');

% pull out parameters
R2 = params.R2t;
Rp = params.dw.*params.zeta;
TE = params.TE;

% apply polynomial fit to data
Pfit = polyfit(T_sample,log(S_sample),2);

% scale by log(S0)
Pfit = Pfit./log(params.S0);

% Second order term Pfit(1) = -DeltaR2^2
DeltaR2_2 = -Pfit(1);

% First order term Pfit(2) = R2' - 2*TE*DeltaR2^2
DeltaR2_1 = (Pfit(2) + Rp)./(2.*TE);

% Zero-th order term Pfit(3) = - (R2*TE) - (DeltaR2^2 * TE^2)
DeltaR2_0 = -(Pfit(3) - (R2*TE))./(TE^2);