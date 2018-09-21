% MTC_GridSearch_Bayes.m
%
% Perform Bayesian inference on ASE qBOLD data from qASE.m using a 2D grid
% search. Requires qASE_model.m, which should all be in the same folder.
% Also requires a .mat file of simulated ASE qBOLD data produced by qASE.m
%
% 
%       Copyright (C) University of Oxford, 2016-2018
%
% 
% Created by MT Cherukara, 17 May 2016
%
% CHANGELOG:
%
% 2018-07-16 (MTC). Parallelized using parfor, on a 6-core i5, this achieves a
%       greater than four-fold speed-up. On a dual-core i5 (MacBook Pro), this
%       is roughly a 50% speed-up. Functionality for 1D and ND grid search has
%       been lost, but this can be added in later.
%
% 2018-03-29 (MTC). Added the means for displaying the locations of the maximum
%       values produced by a 2D grid search.
%
% 2018-02-12 (MTC). Went back to 'param_update' since it is actually much
%       faster. Removed the 3D grid search code because it was taking up space
%       (it will be in the repository somewhere).
%
% 2018-02-05 (MTC). Removed the need for the 'param_update' function. Fixed a
%       bug in the 1D grid search method.
%
% 2018-01-12 (MTC). Changed the way the posterior is calculated to actually
%       calculate log-likelihood, using the function MTC_loglike.m. This
%       technically shouldn't alter the shape of any of the posterior
%       distributions (in terms of their linearity) but should mean that our
%       selected value of SNR is 'applied' to the results correctly.
%
% 2017-10-06 (MTC). Added the option to make a 3D grid search, and made the
%       1D and 2D versions slightly more general (and less cumbersome) by
%       vectorising here and there.
%
% 2017-08-07 (MTC). Added R2'/DBV inference, and made the whole thing better
%       organised. The 1D grid search isn't working right, but it isn't
%       particularly important at this stage.
%
% 2017-04-04 (MTC). Various changes.

clear;
% close all;

% setFigureDefaults;  % since we're doing plotting later

% Options
plot_fig = 1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%    Initialization          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nj = 1;
maxes = zeros(2,nj);
for jj = 1:nj

    tic;
    
    load('ASE_Data/Data_180921_40_3_SNR_100.mat');

%     % Load the Data:
%     load(['ASE_Data/Data_180726_40_4_SNR_100_',num2str(jj),'.mat']);
%     disp(['Analysing Dataset ',num2str(jj), ' of ',num2str(nj)]);
% 
%     % Choose which tau values we want
%     taus = -28:4:64;
%     taus = [-28:4:-20,0,28:4:64];
% 
%     % pull out the right values
%     samps = find(ismember(T_sample,taus./1e3));
%     T_sample  = T_sample(samps);
%     TE_sample = TE_sample(samps);
%     S_sample  = S_sample(samps);


    % Choose parameters, their range, and the number of points each way:
    pnames = { 'R2p'    ; 'zeta'     };
    interv = [ 2.5, 6.5 ; 0.01, 0.07 ];
    np     = [ 1000     ; 1000       ];
    
%     pnames = { 'OEF'    ; 'zeta'     };
%     interv = [ 0.2, 0.6 ; 0.01, 0.07 ];
%     np     = [ 1000     ; 1000       ];
%     interv = [ 0, 0.1 ; 0.01, 0.05 ];
%     np     = [  1000     ; 1000        ];


    % Specifically for testing critical tau. 
    params.tc_man = 0;
    params.tc_val = 0.024;
    
    % Model selection
    params.asymp = 0;  % should the asymptotic tissue model be used?

    % extract relevant parameters
    sigma = mean(params.sig);   % real std of noise
    ns = length(S_sample); % number of data points
    params.R2p = params.dw.*params.zeta;

    % fill in TE if necessary
    if ~exist('TE_sample','var')
        TE_sample = params.TE;
    end


    % are we inferring on R2'?
    if any(strcmp(pnames,'R2p'))
        params.calcDW = 0; % this changes what happens in MTC_qASE_model.m
    else
        params.calcDW = 1;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%    1D Line Search          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Inference
    if length(pnames) == 1
        disp('1D Grid Search currently unsupported');


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%    2D Grid Search          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif length(pnames) == 2
        % Bayesian Inference on two parameters, using grid search

        % pull out parameter names
        pn1 = pnames{1};
        pn2 = pnames{2};

        np1 = np(1);
        np2 = np(2);

        % find true values of parameters
        trv(1) = eval(['params.',pn1]); % true value of parameter 1
        trv(2) = eval(['params.',pn2]); % true value of parameter 2

        % generate parameter distributions
        pv1 = linspace(interv(1,1),interv(1,2),np1);
        pv2 = linspace(interv(2,1),interv(2,2),np2);

        pos = zeros(np(1),np(2));

        parfor i1 = 1:np1
            % loop through parameter 1

            % create a parameters object
            looppars = updateParams(pv1(i1),params,pn1);
            posvec = zeros(1,np2);

            pv22 = pv2; % to avoid using pv2 as a broadcast variable

            for i2 = 1:np2
                % loop through parameter 2

                % create a parameters object
                inpars = updateParams(pv22(i2),looppars,pn2);

                % run the model to evaluate the signal with current params            
                S_mod = qASE_model(T_sample,TE_sample,inpars);

                % normalize
                S_mod = S_mod./max(S_mod);

                % calculate posterior based on known noise value
                posvec(i2) = calcLogLikelihood(S_sample,S_mod,sigma);

            end % for i2 = 1:np2

            pos(i1,:) = posvec;

        end % parfor i1 = 1:np1

    end % length(pars) == 1 ... elseif 

    toc;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%    Display Results         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Display

    if plot_fig
        % create docked figure
        figure; hold on; box on;

        % Plot 2D grid search results
        surf(pv2,pv1,exp(pos));
        view(2); shading flat;
        c=colorbar;
        colormap(flipud(magma));
        plot3([trv(2),trv(2)],[  0, 1000],[1e40,1e40],'k-');
        plot3([  0, 1000],[trv(1),trv(1)],[1e40,1e40],'k-');

        % outline
        plot3([pv2(  1),pv2(  1)],[pv1(  1),pv1(end)],[1,1],'k-','LineWidth',0.75);
        plot3([pv2(end),pv2(end)],[pv1(  1),pv1(end)],[1,1],'k-','LineWidth',0.75);
        plot3([pv2(  1),pv2(end)],[pv1(  1),pv1(  1)],[1,1],'k-','LineWidth',0.75);
        plot3([pv2(  1),pv2(end)],[pv1(end),pv1(end)],[1,1],'k-','LineWidth',0.75);

        xlabel(pn2);
        ylabel(pn1);
        ylabel(c,'Posterior Probability Density');
        axis([min(pv2),max(pv2),min(pv1),max(pv1)]);
        set(gca,'YDir','normal');
        set(c,'FontSize',16);
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%    Maxima Analysis         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Find maxima
    % Calculate distribution's maximum position in 2D
    [V2G,V1G] = meshgrid(pv2,pv1);
    [~,mi] = max(pos(:));

    % Save out maximum location
    maxes(1,jj) = V1G(mi);
    maxes(2,jj) = V2G(mi);

    % % Display maximum information
    % disp('  ');
    % disp([  'R2p = ',num2str(params.R2p),...
    %     ', DBV = ',num2str(100*params.zeta)]);
    % disp(['  Maximum ',pnames{1},': ',num2str(V1G(mi),4)]);
    % disp(['  Maximum ',pnames{2},': ',num2str(100*V2G(mi),4)]);

end

% save('GridMaxima_1.mat','taus','maxes','params');

