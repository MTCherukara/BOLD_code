% function AverageGESEPI
% Load a NIFTI file of GESEPI data and average out the slices

% have the user choose a file
[frname, frdir] = uigetfile('*','Select raw GESEPI data file...');

% load the file
[volraw,dims,scales,bpp] = read_avw([frdir,frname]);

% count slices
nsc = dims(3);
assert(mod(nsc,4)==0,'Number of slices must be a multiple of 4!');

nsl = nsc/4;

% pre-allocate new array
gesepi_out = zeros(dims(1),dims(2),nsl);

% loop through slices 
for ii = 1:nsl
    
    slab = volraw(:,:,(ii*4)-3:ii*4);
    gesepi_out(:,:,ii) = mean(slab,3);
    
end

% correct the 'scales' thing
scales(3) = 7.5;

% make a new filename
foname = strsplit(frname,'.nii');
foname = foname{1};

% save out the result
save_avw(gesepi_out,[frdir,foname,'_average'],'s',scales);

