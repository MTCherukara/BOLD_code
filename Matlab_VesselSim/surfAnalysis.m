% surfAnalysis

clear; close all;

% filename, change values of OEF and DBV here:
fn1 = 'storedPhase/VSdata_Diffusion_D_1e-9_R_20_Y_60_Z_03.mat';

% go through simAnalyse, creating output data, then load them back up again
TE = 20:2:30;

for ii = 1:length(TE)
    simAnalyse(fn1,'seq','ASE','tau',1,'TE',TE(ii),'save',0,'incIV',0,'display',1);
end

% now load the data back in again into a single matrix
%       VS_Signal_18-May-2017_1_ASE
% this is how the names are formatted

for ii = 5%:length(TE)
    fn2 = ['signalResults/VS_Signal_',date,'_',num2str(ii),'_ASE.mat'];
    load(fn2);
end