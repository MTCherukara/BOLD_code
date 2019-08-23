% xPatientLines.m
%
% Plot some lines from the Patient Data, with data entered "manually"
%
% MT Cherukara
% 8 August 2019

clear;
% close all;
setFigureDefaults;

corr = 1;

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
           
    %          Core      Growth    Contra
    folOEF = [ 51.5800   39.3400   23.9400
               19.1600   30.2600   26.6500
               20.3400   25.9300   29.5100
               15.6900   31.0200   28.6200
               22.2700   20.5200   25.3500
               36.1300   20.6100   24.8600 ];
    
    %          Core      Growth    Contra
    
    %          Core      Growth    Contra

       
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
           
    %          Core      Growth    Contra
    folOEF = [ 50.2700   63.1200   33.0500
               27.2300   35.8500   35.7900
               45.1500   37.9400   42.2600
               29.2900   43.3200   35.7200
               33.6100   29.7100   31.7700
               61.3100   38.3500   32.4700 ];
    
    %          Core      Growth    Contra
    
    %          Core      Growth    Contra
    
    
end


%% Line Graph comparing OEF values

% mnames = {'Core','Growth','Contralateral'};
% nm = 3;
% 
% % matOEF = 100*matOEF./repmat(matOEF(:,3),1,3);
% 
% % Plot
% figure; hold on;
% plot(1:nm,matOEF(1:6,:),'o-','MarkerSize',10);
% grid on; box on;
% 
% xticks(1:nm);
% xticklabels(mnames);
% xlim([0.6,nm+0.4]);
% ylabel('OEF (%)');
% ylim([10,80]);
% title(tltx);
% 
% 
% % ANOVA
% grps = {[1,2],[2,3],[1,3]};
% [~,~,stat_OEF] = anova2(matOEF([1,4,5,6,7],:),1,'off');
% c_O = multcompare(stat_OEF,'display','off');
% p_O = MC_pvalues(c_O,grps);
% 
% 
% % % Significance
% HO = sigstar(grps,p_O,1);
% set(HO,'Color','k')
% set(HO(:,2),'FontSize',18);
% 
% 
% axis square;
% legend('Patient 1','Patient 2','Patient 3','Patient 4','Patient 5','Patient 6','Location','EastOutside')


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

%% Compare Follow-up OEF data

matOEF = matOEF(1:6,:);

stepOEF(:,:,1) = matOEF;
stepOEF(:,:,2) = folOEF;

% % Normalize to Contralateral
% % stepOEF = stepOEF./repmat(stepOEF(:,3,:),1,3,1);
% 
% % Plot core
% figure; hold on;
% plot(1:2,squeeze(stepOEF(:,1,:)),'o-','MarkerSize',10);
% grid on; box on;
% 
% xticks(1:2);
% xticklabels({'Presentation','Follow-up'});
% xlim([0.7,2.3]);
% ylabel('Relative OEF');
% % ylim([0.5,2.5]);
% ylim([0,70]);
% title(['Core ',tltx]);
% 
% axis square;
% legend('Patient 1','Patient 2','Patient 3','Patient 4','Patient 5','Patient 6','Location','EastOutside')
% 
% 
% % Plot growth
% figure; hold on;
% plot(1:2,squeeze(stepOEF(:,3,:)),'o-','MarkerSize',10);
% grid on; box on;
% 
% xticks(1:2);
% xticklabels({'Presentation','Follow-up'});
% xlim([0.7,2.3]);
% ylabel('Relative OEF');
% % ylim([0.5,2.5]);
% ylim([0,70]);
% title(['Growth ',tltx]);
% 
% axis square;
% legend('Patient 1','Patient 2','Patient 3','Patient 4','Patient 5','Patient 6','Location','EastOutside')


%% Bar Chart

sbs = [1,2,4,5,6];

matOEF = matOEF(sbs,:);
folOEF = folOEF(sbs,:);

% normalize to contralateral
matOEF = matOEF./repmat(matOEF(:,3),1,3);
folOEF = folOEF./repmat(folOEF(:,3),1,3);

boxOEF = [matOEF(:,1), folOEF(:,1), matOEF(:,2), folOEF(:,2)];

% average
avs = [mean(matOEF); mean(folOEF)]';
err = [std(matOEF); std(folOEF)]';

% Plot
figure; hold on;
% boxplot(boxOEF);
bar(avs(1:2,:));
box on;
xticks(1:2);
xlim([0.5,2.5]);
% xticklabels({'Core (P)','Core (F)','Growth (P)','Growth (F)'});
xticklabels({'Core','Growth'});
ylabel('Relative OEF');
% ylim([0,55]);
legend('Presentation','Follow-up')
axis square;

% grps = {[1,2],[3,4]};
% [~,~,stat_OEF] = anova2(boxOEF,1,'off');
% c_O = multcompare(stat_OEF,'display','off');
% p_O = MC_pvalues(c_O,grps);