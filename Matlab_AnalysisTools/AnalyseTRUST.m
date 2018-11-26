% TRUST data analysis script. Created by Caitlin O'Brien, 2017
%
% Adapted 26-11-2018 (MTC).

TE = linspace(0, 200, 6); % TE steps in acquisition
averages = 2; % number of repeat measurements performed

% IF USING DICOMS
TI = 1200; %if included in filename
disp('Extracting images from nii.gz file and putting in im_data_TRUST array im_data_TRUST(TI, TE, tag/control, dim, dim)')
for av = 1:averages
for te = 1:length(TE)
    %for ti = 1:length(TI); %if using different TI data
        for type = [0,1] % 0 = tag, 1= control
            
            if type == 0
                filen = ['ep2d_local_TRUST_co_TE', num2str(TE(te)), '_tag_', num2str(av), '_average.nii.gz'];
                dummy = load_nii(filen);
                im_data_TRUST( te,1,:,:, av) = dummy.img; % FUNCTION TO LOAD NII FILES, SOURCED ONLINE, UNCHANGED
                % ^ change this according to TI
            elseif type ==1
                
                filen = ['ep2d_local_TRUST_co_TE', num2str(TE(te)), '_control_', num2str(av), '_average.nii.gz'];
                dummy = load_nii(filen);
                im_data_TRUST( te,2,:,:, av) = dummy.img; % FUNCTION TO LOAD NII FILES, SOURCED ONLINE, UNCHANGED
                %^ change this according to TI
            end
            
            
        end
        
%    end
end
end
disp('Done')
%disp(['Size of im_data_TRUST = ', num2str(size(im_data_TRUST))]);

% CONTROL - TAG (+combine averages)
for te = 1:length(TE)
    TRUST_av(te, :,:,:) = mean(squeeze(im_data_TRUST( te, :,:,:,:)), 4);
    subtract_TRUST_av(te, :,:) = squeeze(TRUST_av(te, 1,:,:) - TRUST_av(te, 2, :,:));
    
    %now do individual averages
    for num = 1:averages
        subtract_TRUST(te,:,:, num) = squeeze(im_data_TRUST( te, 1,:,:, num) - im_data_TRUST( te, 2,:,:, num));
    end
end

% Look at data to find ROI
imsqueeze(abs(subtract_TRUST(1,:,:,1))) % homemade function to make plotting easier

% ROI
ROI_y = 36:37;
ROI_x = 7:8;
    
% Subtract image pairs
for te = 1:length(TE)
    
    ROI_SS = (subtract_TRUST_av(te, ROI_y, ROI_x));
    intensity_TRUST_av(te) = abs(mean(mean(ROI_SS)));
    
    for av = 1:averages
        
        ROI_SS = (subtract_TRUST(te, ROI_y, ROI_x, av));
        intensity_TRUST(te, av) = mean(mean(ROI_SS));
        
    end
end

    
    
% Plot average curve
addpath('/Users/caitlino/Desktop/DPHIL_YEAR_1/MATLAB')
C = linspecer(4);
figure
plot(TE, intensity_TRUST_av, 'x-','color', C(1,:), 'linewidth', 4);
%hold all
%plot(TE, intensity_GLOBAL_BGS_av,'x-', 'color', C(3,:), 'linewidth', 4);
%plot(TE, intensity_RHS_BGS_av,'x-', 'color', C(2,:), 'linewidth', 4);
%plot(TE, intensity_MCA_BGS_av,'x-', 'color', C(4,:), 'linewidth', 4);
%legend( 'TRUST', 'GLOBAL','RHS', 'MCA');
set(gca,'FontSize', 17, 'FontWeight','bold')
xlabel('eTE (ms)')
ylabel('Magnetization (a.u.)')
title(['Curves for ', subject, ' measurement ', num2str(a)]);
box off


% plot invidiual averages
for n = 1:2;
    figure
    plot(TE, abs(intensity_TRUST(:,n)), 'x-','color', C(1,:), 'linewidth', 4);
    %hold all
    %plot(TE, abs(intensity_RHS_BGS(:,n)),'x-', 'color', C(2,:), 'linewidth', 4);
    %plot(TE, abs(intensity_MCA_BGS(:,n)),'x-', 'color', C(3,:), 'linewidth', 4);
    %legend( 'TRUST', 'RHS', 'MCA');
    set(gca,'FontSize', 17, 'FontWeight','bold')
    xlabel('eTE (ms)')
    ylabel('Magnetization (a.u.)')
    title(['Curves for ', subject, ' measurement ', num2str(a), ' average ', num2str(n)]);
    box off
end

% Normalize
    
intensity_TRUST_norm = intensity_TRUST_av./max(intensity_TRUST_av);
    
    
figure
plot(TE, intensity_TRUST_norm, 'x-','color', C(1,:), 'linewidth', 4);
%hold all
%plot(TE, intensity_GLOBAL_BGS_norm, 'x-','color', C(4,:), 'linewidth', 4);
%plot(TE, intensity_RHS_BGS_norm,'x-', 'color', C(2,:), 'linewidth', 4);
%plot(TE, intensity_MCA_BGS_norm,'x-', 'color', C(3,:), 'linewidth', 4);
%legend( 'TRUST','GLOBAL', 'RHS', 'MCA');
set(gca,'FontSize', 17, 'FontWeight','bold')
xlabel('eTE (ms)')
ylabel('Magnetization (a.u.)')
title(['Normalized Curves for ', subject, ' measurement ', num2str(a)]);
box off
    
% MATLAB fit function to get T2 from curve
   
coeff_TRUST = fit(TE', intensity_TRUST_norm', 'exp1');
T2_TRUST1 = -1/coeff_TRUST.b;

% Calculate residuals and SNR to be used later for percentage error calc in MonteCarlo sim
[SNR_TRUST, resid_TRUST] = SNR_from_residuals(intensity_TRUST_norm, TE);
  

