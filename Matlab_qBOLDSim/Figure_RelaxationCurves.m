% Figure_RelaxationCurves.m
%
% Plot figures (for Thesis Literature Review) illustrating T1 and T2 of an
% arbitrary system

clear;
close all;

setFigureDefaults;

T1 = [1.0, 1.5, 4.0];
T2 = [50, 100, 500]./1000;


%% Plot T1 curves
figure; hold on; box on;

for ii = 1:length(T1)
    
    t = linspace(0,10);
    Mz = (1 - exp(-t./T1(ii)));
    plot(t,Mz);
    
end

xlabel('Time (s)');
ylabel('M_z');
legend('T_1 = 1.0 s','T_1 = 1.5 s','T_1 = 4.0 s','Location','SouthEast');


%% Plot T2 curves
figure; hold on; box on;

for ii = 1:length(T2)
    
    t = linspace(0,1);
    Mx = exp(-t./T2(ii));
    plot(t,Mx);
    
end

xlabel('Time (s)');
ylabel('M_x_y');
legend('T_2 = 50 ms','T_2 = 100 ms','T_2 = 500 ms','Location','NorthEast');
