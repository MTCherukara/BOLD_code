% function GibbsCorrection(filename,outname)

% Does Gibbs artefact correction using the Reisert unring method (Kellner et
% al., 2016), using their source code MEX file.

clear;

% choose subject
subnum = '12';

% basics
filename = 'ASE_80_FLAIR.nii.gz';
datadir = ['/Users/mattcher/Documents/DPhil/Data/subject_',subnum,'/'];

% unring parameters - 3x1 array with [minW maxW nsh]
%                     minW  left border of window used for TV computation (default 1)
%                     maxW  right border of window used for TV computation (default 3)
%                     nsh discretization of subpixel spaceing (default 20)
URparams = [1 3 20];

% load in the whole set of SE data
[volInput4D, dims, scales] = read_avw(strcat(datadir,filename));

volInput4D = double(volInput4D);

% pre-allocate new 4D volume
volOutput4D = zeros(dims');

% loop through each volume
for ii = 1:dims(4)
    
    % extract volume
    volInput3D = squeeze(volInput4D(:,:,:,ii));
    
    % unring it
    volFiltered3D = ringRm(volInput3D,URparams);
    
    % put it back together
    volOutput4D(:,:,:,ii) = volFiltered3D;
    
end

% make a new output name, based on the input name
if ~exist('outname','var')
    NN = strsplit(filename,'.nii');
    outname = strcat(NN{1},'_unrung.nii.gz');
end

% save out file
save_avw(volOutput4D,strcat(datadir,outname),'f', scales);