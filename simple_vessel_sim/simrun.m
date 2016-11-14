p=gentemplate;          % create basic set of parameters
p.vesselDensity=0.05;   % set vessel density (is this the same as p.vesselFraction ?)
p.deltaChi=0.264e-6.*0.4.*(1-0.6);  % = deltaChi0 * Hct * OEF

%R=[(1:10)'; (20:10:100)'; (200:100:1000)'];
%R=[(500:100:1000)'];
%R=[(5:10)'; (20:10:100)'; (200:100:1000)'];

R=(600:100:1000)';      % define range of vessel sizes (in um)

% if 0    % what does this do?
% for j=1:length(R)
% 	p.R=R(j).*1e-6;     % extract vessel radius (convert to m)
% 	for k=1:10
% 		storedPhase(:,:,k)=simplevesselsim(p); 
% 		fprintf('.');                    
% 	end
% 	save(['./simvessel1/storedPhaseV5pc' num2str(R(j)) '.mat'],'storedPhase');
% 	clear storedPhase;
% 	disp(['R=' num2str(R(j)) ' completed']);
% end
% end

p.D=0;  % set diffusion to 0

for j=1:length(R)
	p.R=R(j).*1e-6;     % extract vessel radius (convert to m)
	for k=1:10  % loop through 10 iterations
		storedPhase(:,:,k)=simplevesselsim(p); 
		fprintf('.');          
    end
    % save out results of phases
	save(['./simvessel1/storedPhaseVD05pc' num2str(R(j)) '.mat'],'storedPhase');
	clear storedPhase;
	disp(['R=' num2str(R(j)) ' completed']);
end