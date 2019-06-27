% xTestSimulations.m
%
% Script that really quickly tests some stuff in the simulations


NN = size(spp,2);

% TE and tau stuff
tt  = (p.deltaTE:p.deltaTE:p.TE*2)';
% tau = (p.TE-(p.deltaTE*2):-p.deltaTE*2:-p.TE+(p.deltaTE*2))';
tau = (-16:1:64)./1000;

TE=repmat(p.TE,size(tau));
TEind = p.TE/p.deltaTE;

SEind = round((p.TE-tau)./(2.*p.deltaTE),0);

% Pre-allocate
Phase = zeros(length(tau),size(spp,2));

% Pre-sum
cumPhase = cumsum(spp,1);

% Calculate ASE phase accumulation
for k = 1:length(tau)
    
    Phase(k,:) = cumPhase(SEind(k),:) - ( cumPhase(TEind,:)  - cumPhase(SEind(k),:) );
    
end

% Calculate ASE signal
sigEV = abs(sum(exp(-1i.*Phase),2)./NN);
shapeEV = -log(sigEV)./p.vesselFraction;
sigEV2 = exp(-p.vesselFraction.*shapeEV);

plot(1000*tau,sigEV2,'-');