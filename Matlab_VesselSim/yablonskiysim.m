function sig=yablonskiysim(p)

deltaX0=0.264e-6;
HCT=0.4;
Y=0.6;
B0=3;
v=0.05;

deltaW=(p.gamma).*4./3.*pi.*p.deltaChi0.*p.Hct.*(1-p.Y).*p.B0;
tc=1./deltaW;

tau=(-56e-3:4e-3:56e-3)';

%r2p in long tau regime
r2plc=p.vesselFraction.*deltaW; %for cylinders

%long tau signal
slpc=exp(-r2plc.*tau+p.vesselFraction); %for cylinders +ve
slnc=exp(r2plc.*tau+p.vesselFraction); %for cylinders -ve

%short tau signal
ssc=exp(-0.3.*p.vesselFraction.*(deltaW.*tau).^2); %for cylinders

for k=1:length(tau)

eqn=@(u)(2+u).*sqrt(1-u).*(1-besselj(0,1.5.*abs(tau(k)).*deltaW.*u))./u.^2;
fc(k,:)=quad(eqn,0,1)./3;

%disp(num2str(tau(k)*1000));

end

%complete signal at all tau
sig=exp(-p.vesselFraction.*fc); %for random cylinders

plot(tau.*1000,sig,'k-');

%keyboard;
