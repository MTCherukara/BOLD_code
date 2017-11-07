% Bar Charts

clear;

%         T2native T2w     T2fit     
overlap = [22.690, 35.030, 39.688; ...
           30.951, 39.225, 40.989; ...
           52.201, 54.085, 45.044; ...
           54.418, 63.095, 42.388  ];
       
%      T2native  T2w      T2fit     
rms = [ 3.21260, 4.34243, 4.27566; ...
        5.85888, 5.29036, 4.03662; ...
        2.07075, 3.71644, 2.05237; ...
        2.65591, 2.65978, 2.75005  ]; 

%       FLAIR  1pVB  fit ECF T2w ECF  4pVB   4pECF
DBV = [ 5.40,  6.92, 12.90,  18.18,   5.30,  6.30; ...
        6.60,  9.32, 29.80,  45.00,   8.20,  8.70; ...
        5.45,  6.21,  5.46,   9.94,   4.52,  4.19; ...
        5.50,  7.07, 15.30,  24.30,   3.87,  4.20 ];
    

%       FLAIR  1pVB  fit ECF T2w ECF  4pVB   4pECF
R2P = [ 2.57,  4.30,  2.34,   1.99,   2.52,  2.59; ...
        2.61,  6.03,  1.98,   0.97,   2.09,  2.08; ...
        2.29,  3.47,  2.66,   2.56,   2.61,  2.48; ...
        3.31,  4.69,  2.19,   1.59,   2.11,  2.20 ];
    
%       FLAIR  1pVB   1pECF  4pVB   4pECF
OEF = [ 24.8,  31.2,  13.6,  29.4,  23.7; ...
        21.3,  34.6,  10.3,  17.3,  17.9; ...
        23.7,  24.4,  23.3,  23.6,  23.6; ...
        28.2,  32.0,  13.1,  26.2,  25.7 ];
    
% plot
figure('WindowStyle','Docked');
% yyaxis right;
hold on; box on;
bar(DBV(:,1:4));
xlabel('Subjects');
xticks([1 2 3 4]);
set(gca,'FontSize',16);

% ylabel('RMS Difference to R1 (mm)');
% ylabel('Overlapping Voxels (%)');
ylabel('Mean Grey Matter DBV (%)');
% ylabel('Mean Grey Matter OEF');
% ylabel('Mean Grey Matter R_2''');

ylim([0 25]);

% legend('Native R2-segmentation','Up-sampled R2-segmentation','R2 bixeponential fit','Location','NorthEast');
% legend('FLAIR','No FLAIR','No FLAIR ECF Corrected','No FLAIR Multi-TE','No FLAIR Multi-TE ECF');
% legend('FLAIR (ECF Nulled)','V^E^C^F Unconstrained','V^E^C^F Biexponential Fit','V^E^C^F R_2 Segmentation');
