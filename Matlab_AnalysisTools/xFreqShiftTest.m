% xFreqShiftTest.m

T1t = 1.019;
T1e = 3.817;
T1b = 1.584;
R2t = 12.5;
R2e = 2.0;
R2b = 27.97;
Rsb = 48.89;

TR = 3.000;
TI = 1.210;
TE = 0.082;

DBV = 0.03;
R2p = 2.0;
DF = 7.0;
VC = 0.001;

lt = 1 - (VC+DBV);

tau = 0.016:0.008:0.064;
M0 = zeros(14,1);

% FLAIR
St = ( 1 - ( (2 - exp(-(TR-TI)./T1t) ) .* exp(-TI./T1t))) .* (exp(-R2t.*TE)) .* (exp(DBV - (R2p.*tau)));
Sb = ( 1 - ( (2 - exp(-(TR-TI)./T1b) ) .* exp(-TI./T1b))) .* (exp(-R2b.*(TE-tau))) .* (exp(-Rsb.*tau));
Se = real(( 1 - ( (2 - exp(-(TR-TI)./T1e) ) .* exp(-TI./T1e))) .* (exp(-R2e.*TE)) .* (exp(-2.0.*1i.*pi.*DF.*tau)));

res = [210, 209, 200, 193, 192, 190, 179];
M0(1:7) = res./ ( (St*lt) + (DBV*Sb) + (VC*Se) );

% non-FLAIR
St = ( 1 - (exp(-TR./T1t)) ) .* (exp(-R2t.*TE)) .* (exp(DBV - (R2p.*tau)));
Sb = ( 1 - (exp(-TR./T1b)) ) .* (exp(-R2b.*(TE-tau))) .* (exp(-Rsb.*tau));
Se = abs(( 1 - (exp(-TR./T1e)) ) .* (exp(-R2e.*TE)) .* (exp(-2.0.*1i.*pi.*DF.*tau)));

res = [406, 395, 382, 374, 359, 333, 307];
M0(8:14) = res./ ( (St*lt) + (DBV*Sb) + (VC*Se) );

std_M0 = std(M0);

disp(['Standard Deviation in M0: ',num2str(std_M0)]);