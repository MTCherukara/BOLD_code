function PriorPDFs

close all;
setFigureDefaults;

% plot parameters
np = 1000;

% R2p
mean_R2p = 4;
XR = linspace(0,8,np);
Ru = normpdf(XR,mean_R2p,prc(1e-2));
Ri = normpdf(XR,mean_R2p,prc(1e0));
Ra = normpdf(XR,2.85,0.66);
Rr = normpdf(XR,2.88,0.38);

% Ru = Ru./max(Ru);
% Ri = Ri./max(Ri);
% Ra = Ra./max(Ra);
% Rr = Rr./max(Rr);

figure; hold on; box on;
plot(XR,Ru,'b-');
plot(XR,Ri,'r-');
plot(XR,Ra,'b--');
plot(XR,Rr,'r--');
xlabel('R_2'' (s^-^1)');
ylabel('Prior  P(R_2'')');
legend('Uninformative Prior','Informative Prior',...
       'Uninformative Result','Informative Result','Location','NorthEast');


% DBV
mean_DBV = 0.03;
XD = linspace(0,0.2,np);
Du = normpdf(XD,mean_DBV,prc(1e0));
Di = normpdf(XD,mean_DBV,prc(1e3));
Da = normpdf(XD,0.0429,0.0322);
Dr = normpdf(XD,0.0394,0.0154);

% Du = Du./max(Du);
% Di = Di./max(Di);
% Da = Da./max(Da);
% Dr = Dr./max(Dr);

figure; hold on; box on;
plot(XD,Du,'b-');
plot(XD,Di,'r-');
plot(XD,Da,'b--');
plot(XD,Dr,'r--');
xlabel('_ DBV (%)^ ');
ylabel('Prior  P(DBV)');
legend('Uninformative Prior','Informative Prior',...
       'Uninformative Result','Informative Result','Location','NorthEast');

return;

function stdev = prc(precision)
    stdev = 1/sqrt(precision);
return;