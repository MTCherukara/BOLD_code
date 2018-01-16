% xMTC_qBOLD_model.m

% analytical look at the quantitative BOLD model in ASE, based on He and
% Yablonskiy 2007 (originally based on Yablonskiy & Haacke, 1994)

clear; close all;

save_data = 0;
plot_results = 1;

% range of OEF and DBV values to use
Y_vals = 0.2:0.05:0.8;
Z_vals = 0.005:0.005:0.05;

% constant parameters
R2t = 1/0.110; % basically physical
TE  = 0.074; % 74 ms
Sr2 = exp(-R2t.*TE);

nt = 100; % number of tau values

taus = linspace(-32,32,nt);

S_full = zeros(length(Y_vals),length(Z_vals),nt);
S_asym = zeros(length(Y_vals),length(Z_vals),nt);

for YY = 1:length(Y_vals)
    
    disp(['Generating data for OEF value ',num2str(YY),' of ',num2str(length(Y_vals)),'...']);
    
    OEF = Y_vals(YY);
    
    dw  = 355*OEF; % apparently

    
    for ZZ = 1:length(Z_vals)
        
        DBV = Z_vals(ZZ);
        

        for jj = 1:nt
            tau = 0.001*taus(jj); % select a tau value

            Tf = (TE - tau)/2; % flip time

            % full analytical model
            fun = @(u) ((2+u).*sqrt(1-u)./(u.^2)).*(1-besselj(0,1.5.*dw.*abs(tau).*u));
            grl = integral(fun,0,1);

            Szt = exp(-DBV.*grl./3);

            S_full(YY,ZZ,jj) = Sr2.*Szt;

            % asymptotic model

            % long tau before echo
            if tau < (-1.5/dw) 
                Sas = exp(DBV+(DBV.*dw.*tau));

            % long tau after echo
            elseif tau > (1.5/dw) 
                Sas = exp(DBV-(DBV.*dw.*tau));

            % short tau around echo
            else
                Sas = exp(-0.3.*DBV.*(dw.*tau).^2);
            end % if

            S_asym(YY,ZZ,jj) = Sr2.*Sas;

        end % for jj = 1:length(taus);
        
    end % for ZZ = 1:length(Z_vals)
        
end % for YY = 1:length(Y_vals)


%% Plot a figure for ASE acquisition
% figure('WindowStyle','Docked');
% hold on; box on;
% 
% p.a = plot(taus,log(Stau),'-','LineWidth',2);
% p.b = plot(taus,log(Sast),':','LineWidth',2);
% 
% legend([p.a,p.b],'Complete Model','Asymptotic Model','Location','SouthWest');
% xlabel('TE offset \tau (ms)');
% ylabel('Log signal');
% set(gca,'FontSize',16);

%% Save Out the Traces of Both Models
if save_data
    fnam = strcat('ASE_Data/ModelCompare_OEF_',num2str(OEF),'_DBV_',num2str(DBV),'_');
    flist = dir(strcat(fnam,'*'));
    fn = length(flist) + 1;

    disp('  '); disp('  ');
    disp('Saving Out The Data...');
    save(strcat(fnam,num2str(fn),'.mat'),'taus','Stau','Sast');
end


%% Plot some results
if plot_results
    
    figure('WindowStyle','Docked');
    hold on; box on;
    
    for yy = 1:length(Z_vals)
        mdiff = abs(S_asym(5,yy,:)-S_full(5,yy,:))./S_full(5,yy,:);
        plot(taus,squeeze(mdiff),'-','LineWidth',2);
    end
end