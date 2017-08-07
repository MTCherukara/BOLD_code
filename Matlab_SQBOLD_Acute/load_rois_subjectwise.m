% Load ROIs
p03 = load('p03/sess-0hrs/analysis/p03.mat');
p04 = load('p04/sess-0hrs/analysis/p04.mat');
p05 = load('p05/sess-0hrs/analysis/p05.mat');
p06 = load('p06/sess-0hrs/analysis/p06.mat');
p07 = load('p07/sess-0hrs/analysis/p07.mat');
p08 = load('p08/sess-0hrs/analysis/p08.mat');
p09 = load('p09/sess-0hrs/analysis/p09.mat');

%% R2'
%  core
r2p_core(1,1) = median(p03.r2p_core(p03.r2p_core ~= 0));
r2p_core(2,1) = median(p04.r2p_core(p04.r2p_core ~= 0));
r2p_core(3,1) = median(p05.r2p_core(p05.r2p_core ~= 0));
r2p_core(4,1) = median(p06.r2p_core(p06.r2p_core ~= 0));
r2p_core(5,1) = median(p07.r2p_core(p07.r2p_core ~= 0));
r2p_core(6,1) = median(p08.r2p_core(p08.r2p_core ~= 0));
r2p_core(7,1) = median(p09.r2p_core(p09.r2p_core ~= 0));

%  growth
r2p_growth(1,1) = median(p03.r2p_growth(p03.r2p_growth ~= 0));
r2p_growth(2,1) = median(p04.r2p_growth(p04.r2p_growth ~= 0));
r2p_growth(3,1) = median(p05.r2p_growth(p05.r2p_growth ~= 0));
r2p_growth(4,1) = median(p06.r2p_growth(p06.r2p_growth ~= 0));
r2p_growth(5,1) = median(p07.r2p_growth(p07.r2p_growth ~= 0));
r2p_growth(6,1) = median(p08.r2p_growth(p08.r2p_growth ~= 0));
r2p_growth(7,1) = median(p09.r2p_growth(p09.r2p_growth ~= 0));

%  contra
r2p_contra(1,1) = median(p03.r2p_contra(p03.r2p_contra ~= 0));
r2p_contra(2,1) = median(p04.r2p_contra(p04.r2p_contra ~= 0));
r2p_contra(3,1) = median(p05.r2p_contra(p05.r2p_contra ~= 0));
r2p_contra(4,1) = median(p06.r2p_contra(p06.r2p_contra ~= 0));
r2p_contra(5,1) = median(p07.r2p_contra(p07.r2p_contra ~= 0));
r2p_contra(6,1) = median(p08.r2p_contra(p08.r2p_contra ~= 0));
r2p_contra(7,1) = median(p09.r2p_contra(p09.r2p_contra ~= 0));


%% DBV
%  core
dbv_core(1,1) = median(p03.dbv_core(p03.dbv_core ~= 0));
dbv_core(2,1) = median(p04.dbv_core(p04.dbv_core ~= 0));
dbv_core(3,1) = median(p05.dbv_core(p05.dbv_core ~= 0));
dbv_core(4,1) = median(p06.dbv_core(p06.dbv_core ~= 0));
dbv_core(5,1) = median(p07.dbv_core(p07.dbv_core ~= 0));
dbv_core(6,1) = median(p08.dbv_core(p08.dbv_core ~= 0));
dbv_core(7,1) = median(p09.dbv_core(p09.dbv_core ~= 0));

%  growth
dbv_growth(1,1) = median(p03.dbv_growth(p03.dbv_growth ~= 0));
dbv_growth(2,1) = median(p04.dbv_growth(p04.dbv_growth ~= 0));
dbv_growth(3,1) = median(p05.dbv_growth(p05.dbv_growth ~= 0));
dbv_growth(4,1) = median(p06.dbv_growth(p06.dbv_growth ~= 0));
dbv_growth(5,1) = median(p07.dbv_growth(p07.dbv_growth ~= 0));
dbv_growth(6,1) = median(p08.dbv_growth(p08.dbv_growth ~= 0));
dbv_growth(7,1) = median(p09.dbv_growth(p09.dbv_growth ~= 0));

%  contra
dbv_contra(1,1) = median(p03.dbv_contra(p03.dbv_contra ~= 0));
dbv_contra(2,1) = median(p04.dbv_contra(p04.dbv_contra ~= 0));
dbv_contra(3,1) = median(p05.dbv_contra(p05.dbv_contra ~= 0));
dbv_contra(4,1) = median(p06.dbv_contra(p06.dbv_contra ~= 0));
dbv_contra(5,1) = median(p07.dbv_contra(p07.dbv_contra ~= 0));
dbv_contra(6,1) = median(p08.dbv_contra(p08.dbv_contra ~= 0));
dbv_contra(7,1) = median(p09.dbv_contra(p09.dbv_contra ~= 0));


%% dHb
%  core
dhb_core(1,1) = median(p03.dhb_core(find((~isnan(p03.dhb_core)).*(p03.dhb_core~=0))));
dhb_core(2,1) = median(p04.dhb_core(find((~isnan(p04.dhb_core)).*(p04.dhb_core~=0))));
dhb_core(3,1) = median(p05.dhb_core(find((~isnan(p05.dhb_core)).*(p05.dhb_core~=0))));
dhb_core(4,1) = median(p06.dhb_core(find((~isnan(p06.dhb_core)).*(p06.dhb_core~=0))));
dhb_core(5,1) = median(p07.dhb_core(find((~isnan(p07.dhb_core)).*(p07.dhb_core~=0))));
dhb_core(6,1) = median(p08.dhb_core(find((~isnan(p08.dhb_core)).*(p08.dhb_core~=0))));
dhb_core(7,1) = median(p09.dhb_core(find((~isnan(p09.dhb_core)).*(p09.dhb_core~=0))));

%  growth
dhb_growth(1,1) = median(p03.dhb_growth(find((~isnan(p03.dhb_growth)).*(p03.dhb_growth~=0))));
dhb_growth(2,1) = median(p04.dhb_growth(find((~isnan(p04.dhb_growth)).*(p04.dhb_growth~=0))));
dhb_growth(3,1) = median(p05.dhb_growth(find((~isnan(p05.dhb_growth)).*(p05.dhb_growth~=0))));
dhb_growth(4,1) = median(p06.dhb_growth(find((~isnan(p06.dhb_growth)).*(p06.dhb_growth~=0))));
dhb_growth(5,1) = median(p07.dhb_growth(find((~isnan(p07.dhb_growth)).*(p07.dhb_growth~=0))));
dhb_growth(6,1) = median(p08.dhb_growth(find((~isnan(p08.dhb_growth)).*(p08.dhb_growth~=0))));
dhb_growth(7,1) = median(p09.dhb_growth(find((~isnan(p09.dhb_growth)).*(p09.dhb_growth~=0))));

%  contra
dhb_contra(1,1) = median(p03.dhb_contra(find((~isnan(p03.dhb_contra)).*(p03.dhb_contra~=0))));
dhb_contra(2,1) = median(p04.dhb_contra(find((~isnan(p04.dhb_contra)).*(p04.dhb_contra~=0))));
dhb_contra(3,1) = median(p05.dhb_contra(find((~isnan(p05.dhb_contra)).*(p05.dhb_contra~=0))));
dhb_contra(4,1) = median(p06.dhb_contra(find((~isnan(p06.dhb_contra)).*(p06.dhb_contra~=0))));
dhb_contra(5,1) = median(p07.dhb_contra(find((~isnan(p07.dhb_contra)).*(p07.dhb_contra~=0))));
dhb_contra(6,1) = median(p08.dhb_contra(find((~isnan(p08.dhb_contra)).*(p08.dhb_contra~=0))));
dhb_contra(7,1) = median(p09.dhb_contra(find((~isnan(p09.dhb_contra)).*(p09.dhb_contra~=0))));
