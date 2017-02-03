clear variables;

p=gentemplate;          % create basic set of parameters
p.N = 1000;
 
p.R = 1e-6;     % radius, in m
p.D = 1e-9;        % diffusion, in m^2/s
p.Y = 0.6;      % oxygenation fraction (1-OEF) 
p.vesselFraction = 0.05;    % DBV

X = 0.7*ones(1,10);

% pre-allocate phase storage arrays
ph_steps = round((p.TE*2)/p.dt)./round(p.deltaTE./p.dt);
Phase_u = zeros(ph_steps,p.N,length(X));
Phase_n = zeros(ph_steps,p.N,length(X));
sASE_u  = zeros(round(500*p.TE)+1,length(X));
sASE_n  = zeros(round(500*p.TE)+1,length(X));

for j = 1:length(X)
    
    p.Y = X(j);
    p.deltaChi = p.deltaChi0.*p.Hct.*(1-p.Y); % calculate susceptibility difference
    
    disp(['Running j = ',num2str(j)]);
    
    [Phase_u(:,:,j),p] = simplevesselsim(p);
    [sASE_u(:,j), tASE]  = plotASE(p,Phase_u(:,:,j),'display',false);
    
    [Phase_n(:,:,j),p] = MTC_vesselsim(p);
    [sASE_n(:,j), ~]     = plotASE(p,Phase_n(:,:,j),'display',false);
    
    disp(['  j = ',num2str(j),' completed']);   
    
    % calculate normalized difference between the two signals
%     sdiff(:,j) = (sASE_u - sASE_n)./sASE_u;
    
%     [sGESSE(:,j),tGESSE] = plotGESSE(p,storedPhase); % include T2 of 80 ms (grey matter)
%     [sASE(:,j),  tASE]   = plotASE(p,storedPhase);
%     plotASE(p,storedPhase);
%     axis([-60, 60, 0.65,1]);
%     set(gca,'FontSize',12);
    
end

%% display difference
% figure(17);
% plot(tASE*1000,sASE_n,'o-'); hold on;
% plot([-60,60],[0,0],'k:');
% axis([-60, 60, -0.03, 0.03]);
% xlabel('Spin Echo offset \tau (ms)');
% ylabel('Normalized Difference');
% set(gca,'FontSize',12);

%% compare normalized differences with errorbars
meanu = mean(sASE_u,2); % calculate the mean
meann = mean(sASE_n,2);
meann = meann./meanu;   % normalise it - normal-dist first
meanu = meanu./meanu;   

stdu = std(sASE_u,[],2);    % calculate standard deviation
stdn = std(sASE_n,[],2);
stdu = stdu./meanu;         % normalise it
stdn = stdn./meanu;

% plot
figure(19)
errorbar(1000*tASE,meanu,stdu,'-','LineWidth',1.5); hold on;
errorbar(1000*tASE+1,meann,stdn,'--','LineWidth',1.5); % add an offset, so we can see them better
axis([-62 62 0.95 1.05])
legend('Y = 0.7','Y = N(0.7,0.1)','Location','North');
ylabel('Signal Normalised to Uniform Distribution');
xlabel('Spin Echo offset \tau (ms)');
set(gca,'FontSize',12);
title('Y = 0.7, R = 1\mum, D = 0');

%% measure ASE signal again, but with T2
for j = 1:10
    [sASE_u(:,j), tASE]  = plotASE(p,Phase_u(:,:,j),'display',false,'T2EV',0.11);
    [sASE_n(:,j), tASE]  = plotASE(p,Phase_n(:,:,j),'display',false,'T2EV',0.11);
end