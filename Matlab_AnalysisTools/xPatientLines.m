% xPatientLines.m
%
% Plot some lines from the Patient Data, with data entered "manually"
%
% MT Cherukara
% 8 August 2019

clear;
% close all;
setFigureDefaults;

corr = 0;

%% DATA
       
if corr == 0
    
    tltx = 'Uncorrected OEF Estimates';
    
    %          Core      Growth    Contra
    matR2p = [  2.9560    4.8800    3.3530
                6.8540    6.1140    3.3590
                3.7560    4.1190    3.1190
                4.1650    6.6520    3.4390
                5.1550    5.1460    3.4410
                8.5070    4.2770    3.5150 ];

    %          Core      Growth    Contra
    matDBV = [  7.0700    6.6970    9.6910
               14.1010   10.8780    9.8080
               13.4780    9.7490    8.3550
                6.3570   11.6960   11.0900
               10.6150    9.8770    8.3410
               13.9830   17.2650   14.8100 ];

    %          Core      Growth    Contra
    matOEF = [ 45.6100   33.3400   21.3500
               16.7600   23.3100   20.4500
               26.8700   22.5300   21.1200
               26.3600   34.0700   20.1600
               26.1300   27.0800   23.0400
               30.2000   23.2000   20.6400 
               34.0700   34.1400   25.6000 ];

       
else
    
    tltx = 'Corrected OEF Estimates';

    %          Core      Growth    Contra
    matR2p = [  4.3380    7.5240    5.2470
                9.7720    9.5100    5.1180
                6.6260    6.0270    4.7150
                5.4090    9.3630    5.3350
                7.5480    7.2760    4.7610
                8.6810    7.5140    5.3850 ];

    %          Core      Growth    Contra
    matDBV = [  2.0590    6.0090    8.1330
                9.6300    8.8610    6.9170
                9.4960    7.6950    6.8430
                4.4130    9.9550    9.6720
                8.1060    8.2020    7.8320
                9.8740   11.2300   10.9370 ];

    %          Core      Growth    Contra
    matOEF = [ 65.2500   54.2200   31.8900
               31.8800   35.0200   30.2400
               21.7300   33.1800   29.3300
               60.9200   43.9400   27.9600
               37.9400   39.5200   29.4000
               46.3900   29.8900   25.6000 
               46.6100   47.7200   35.0200 ];

end


%% Line Graph comparing OEF values
mnames = {'Core','Growth','Contralateral'};
nm = 3;

% matOEF = 100*matOEF./repmat(matOEF(:,3),1,3);

% Plot
figure; hold on;
plot(1:nm,matOEF(1:6,:),'o-','MarkerSize',10);
grid on; box on;

xticks(1:nm);
xticklabels(mnames);
xlim([0.6,nm+0.4]);
ylabel('OEF (%)');
ylim([10,80]);
title(tltx);


% ANOVA
grps = {[1,2],[2,3],[1,3]};
[~,~,stat_OEF] = anova2(matOEF([1,4,5,6,7],:),1,'off');
c_O = multcompare(stat_OEF,'display','off');
p_O = MC_pvalues(c_O,grps);


% % Significance
HO = sigstar(grps,p_O,1);
set(HO,'Color','k')
set(HO(:,2),'FontSize',18);


axis square;
legend('Patient 1','Patient 2','Patient 3','Patient 4','Patient 5','Patient 6','Location','EastOutside')


%% The same line graph, but normalized to the Contralateral value

% valsOEF = 100*matOEF./repmat(matOEF(3,:),3,1);
% 
% % Plot
% figure; hold on;
% plot(1:nm,valsOEF,'o-','MarkerSize',10);
% grid on; box on;
% 
% xticks(1:nm);
% xticklabels(mnames);
% xlim([0.6,nm+0.4]);
% ylabel('Relative OEF (%)');
% ylim([95,165]);
% axis square;
