clear variables;

p=gentemplate;          % create basic set of parameters
p.N = 1000;
 
p.R = 1e-6;     % radius, in m
p.D = 0;        % diffusion, in m^2/s
p.Y = 0.6;      % oxygenation fraction (1-OEF) 
p.vesselFraction = 0.05;    % DBV

X = [1e-6,1e-5,1e-4];

% pre-allocate phase storage arrays
ph_steps = round((p.TE*2)/p.dt)./round(p.deltaTE./p.dt);
Phase_u = zeros(ph_steps,p.N,length(X));
Phase_n = zeros(ph_steps,p.N,length(X));

for j = 1:length(X)
    
    p.Y = X(j);
    p.deltaChi = p.deltaChi0.*p.Hct.*(1-p.Y); % calculate susceptibility difference
    
    disp(['Running X = ',num2str(X(j))])
    
    [Phase_u(:,:,j),p] = simplevesselsim(p);
    [sASE_u, tASE]  = plotASE(p,Phase_u(:,:,j),'display',false);
    
    [Phase_n(:,:,j),p] = MTC_vesselsim(p);
    [sASE_n, ~]     = plotASE(p,Phase_n(:,:,j),'display',false);
    
    disp(['  X = ',num2str(X(j)),' completed']);   
    
    % calculate normalized difference between the two signals
    sdiff(:,j) = (sASE_u - sASE_n)./sASE_u;
    
%     [sGESSE(:,j),tGESSE] = plotGESSE(p,storedPhase); % include T2 of 80 ms (grey matter)
%     [sASE(:,j),  tASE]   = plotASE(p,storedPhase);
%     plotASE(p,storedPhase);
%     axis([-60, 60, 0.65,1]);
%     set(gca,'FontSize',12);
    
end

% display difference
figure(16);
plot(tASE*1000,sdiff,'o-'); hold on;
plot([-60,60],[0,0],'k:');
axis([-60, 60, -0.03, 0.03]);
xlabel('Spin Echo offset \tau (ms)');
ylabel('Normalized Difference');
set(gca,'FontSize',12);