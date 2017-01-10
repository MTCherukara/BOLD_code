clear variables;

p=gentemplate;          % create basic set of parameters
p.vesselDensity=0.05;   % set vessel density (is this the same as p.vesselFraction ?)

% p.deltaChi=0.264e-6.*0.4.*(1-0.6);  % = deltaChi0 * Hct * OEF


%R=[(1:10)'; (20:10:100)'; (200:100:1000)'];
%R=[(500:100:1000)'];
%R=[(5:10)'; (20:10:100)'; (200:100:1000)'];

R = 2.5;      % radius, in um
p.D = 0;  % diffusion, in m^2/s
Y = 0.7;     % oxygenation fraction (1-OEF)

for j = 1:length(Y)
    
    p.Y = Y(j);
	p.R = R.*1e-6;     % extract vessel radius (convert to m)
    p.deltaChi = p.deltaChi0.*p.Hct.*(1-p.Y); % calculate susceptibility difference
    
    disp(['Running Y = ',num2str(p.Y)])
    
	for k = 1%:10  % loop through 10 iterations
		[storedPhase_1(:,:,k),p] = simplevesselsim(p); 
%         [storedPhase_N(:,:,k),p] = MTC_vesselsim(p); 
		fprintf('.');          
    end
    
    % average out over iterations
%     storedPhase = mean(storedPhase,3);
    
    % save out results of phases
% 	save(['storedPhaseVD05pc_diff2_Y_',num2str(100*p.Y),'.mat'],'storedPhase','p');
% 	clear storedPhase;
	disp(['Y=',num2str(p.Y),' completed']);
    plotresults(p,storedPhase_1);
    ylim([0.7,1]);
%     hold on
%     plotresults(p,storedPhase_N);
%     title(['GESSE Sequence, D = ',num2str(1e9*p.D)])
%     legend(['Fixed Value Y = ',num2str(Y)],['Distribution Y = N(',num2str(Y),',1)'],'Location','SouthWest')
%     title(['D = ',num2str(1e9*p.D),'\mum^2/ms, Y = N(',num2str(p.Y),',0.1)']);
    
end