clear variables;

p=gentemplate;          % create basic set of parameters
p.vesselDensity=0.05;   % set vessel density (is this the same as p.vesselFraction ?)
p.N = 1000;

p.R = 2.5e-6;   % radius, in m
p.D = 0;        % diffusion, in m^2/s
p.Y = 0.6;      % oxygenation fraction (1-OEF) 

X = [1e-6,1e-5,1e-4];

for j = 1:length(X)
    
    p.R = X(j);
    p.deltaChi = p.deltaChi0.*p.Hct.*(1-p.Y); % calculate susceptibility difference
    
    disp(['Running X = ',num2str(X(j))])
    
	for k = 1%:10  % loop through 10 iterations
		[storedPhase(:,:,k),p] = simplevesselsim(p); 
%         [storedPhase(:,:,k),p] = MTC_vesselsim(p); 
		fprintf('.');          
    end
    
    % average out over iterations
%     storedPhase = mean(storedPhase_1,3);
    
    % save out results of phases
% 	save(['storedPhaseVD05pc_diff2_Y_',num2str(100*p.Y),'.mat'],'storedPhase','p');
% 	clear storedPhase;
	disp(['TE=',num2str(1000*p.TE),'ms completed']);
%     [sGESSE(:,j),tGESSE] = plotGESSE(p,storedPhase); % include T2 of 80 ms (grey matter)
    [sASE(:,j),  tASE]   = plotASE(p,storedPhase);
	ylim([0.65,1]);
    set(gca,'FontSize',12);
    
%     hold on
%     plotresults(p,storedPhase_N);
%     title(['GESSE Sequence, D = ',num2str(1e9*p.D)])
%     legend(['Fixed Value Y = ',num2str(Y)],['Distribution Y = N(',num2str(Y),',1)'],'Location','SouthWest')
%     title(['D = ',num2str(1e9*p.D),'\mum^2/ms, Y = N(',num2str(p.Y),',0.1)']);
    
end