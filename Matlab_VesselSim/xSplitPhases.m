% xSpiltPhases.m

% this is used to load a VSdata file with 10000 sets of phase data and
% split it into 10 files each with 1000 sets of phase data, so that we can
% then average them and calculate some uncertainites (in a dodgy way...)

clear;

dataname = 'newStoredPhase/VSdata_VesselDist_Triple_Static';

load(dataname);

nd = size(Phase_u,2);
ns = floor(nd./1000);

Phase_n = Phase_u; % keep this temporarily aside

for ii = 1:ns
    
    ps = (1000.*(ii-1))+1;
    pe = (1000.*ii);
%     disp(['Starting point = ',num2str(ps),', End point = ',num2str(pe)]);
    
    Phase_u = Phase_n(:,ps:pe);
    save([dataname,'_',num2str(ii),'.mat'],'p','Phase_u');

end
