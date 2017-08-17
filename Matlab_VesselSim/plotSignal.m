function [t,sig] = plotSignal(storedPhase,p,r)
    % plots an MR signal based on the stored phase information in Phase,
    % with parameters specified in p and r. For use within simAnalyse.
    % Based on plotresults.m (NP Blockley, 2016).
    %
    % 
    %       Copyright (C) University of Oxford, 2017
    %
    % 
    % Created by MT Cherukara, February 2017
    %
    % CHANGELOG:
    %
    % 2017-07-17 (MTC). Changed the way intravascular signal is calculated
    %       so that multiple values of R, Y, and Hct (i.e. multiple vessel
    %       types) are allowed. This still needs some work, as it assumes
    %       each vessel type is weighted equally.
    %
    % 2017-07-03 (MTC). Made it possible to plot signal on a log scale
    %
    % 2017-05-18 (MTC). Made it possible for the user to specify an
    %       arbitrary set of tau values in ASE, while slightly improving
    %       the way in which ASE signal is calculated, and ensuring that
    %       the (tau=0) point is always included in output data.
    
    
    % define time range
    ts = (p.deltaTE:p.deltaTE:(p.numSteps*p.deltaTE/p.ptsPerdt))';
    
    % use r struct to decide which sequences we want to plot, then loop
    % through them all:
    seqs   = [r.plotFID, r.plotGESSE, r.plotASE];
    snames = {'GRE'    ; 'GESSE'    ; 'ASE'};
    lspc   = {'-'      ; '-'        ; '-o' };
    
    for sq = 1:length(seqs)
        
        if seqs(sq) == 1 % only do those sequences that we asked for

            % choose the right sequence and evaluate it
            [t,ph] = eval(strcat('phase',snames{sq},'(storedPhase,ts,p,r)'));

            % calculate extravascular signal
            sigEV = abs(mean(exp(-1i.*ph),2));
            stdEV = std(exp(-1i.*ph),[],2);

            % account for t2 decay
            if r.incT2
                
                if sq == 1 || sq == 2 % do this for GRE and GESSE
                    sigEV = sigEV.*exp(-t./p.T2EV);
                    stdEV = stdEV.*exp(-t./p.T2EV); % scale the error in the same way
                else % do this for other sequences (e.g. ASE)
                    sigEV = sigEV.*exp(-p.TE./p.T2EV);
                    stdEV = stdEV.*exp(-p.TE./p.T2EV);
                end
            end

            % add in intravascular signal
            if r.incIV
                
                % loop through multiple vessel sizes
                if length(p.R) == 1
                    % constants from Simon et al. 2016
                    R2  = repmat((16.4.*p.Hct+ 4.5)+(165.2.*p.Hct+55.7).*(1-p.Y).^2,length(t),1);
                    R2s = repmat((14.9.*p.Hct+14.7)+(302.1.*p.Hct+41.8).*(1-p.Y).^2,length(t),1);
                
                    % call a bunch of separate functions for calculating
                    % intravascular signal for each sequence
                    sigIV = eval(strcat('ivsig',snames{sq},'(t,R2,R2s,p)'));
                else
                    
                    sigIV = 0;
                    
                    % loop through different vessel sizes
                    for vv = 1:length(p.R)
                        
                        vHct = p.Hct(vv);
                        vY   = p.Y(vv);
                        
                        R2  = repmat((16.4.*vHct+ 4.5)+(165.2.*vHct+55.7).*(1-vY).^2,length(t),1);
                        R2s = repmat((14.9.*vHct+14.7)+(302.1.*vHct+41.8).*(1-vY).^2,length(t),1);
                
                        % call a bunch of separate functions for calculating
                        % intravascular signal for each sequence
                        sigIV = sigIV + eval(strcat('ivsig',snames{sq},'(t,R2,R2s,p)'));
                    end
                    
                end % if length(p.R) == 1
                
                
            else
                sigIV = sigEV;
            end
            
            vZeta = sum(p.vesselFraction);

            sig = ((1-vZeta).*sigEV) + (vZeta.*sigIV);
            
            % normalization
            if r.normalise
                sig = sig./max(sig);
            end

            % display the result
            if r.display
                
                % first, do some smart title related stuff
                if sq ~= 1 && length(r.TE) == 1
                    r.ftit = [r.ftit,' TE = ',num2str(1000*r.TE(1)),'ms'];
                end
                
                figure(r.fnum);
                hold on;
                
                if r.plotErrors
                    errorbar(1000*t,sig,stdEV,lspc{sq},'LineWidth',2);
                else
                    if r.plotLog
                        plot(1000*t,log(sig),lspc{sq},'LineWidth',2);
                        ylabel(['log(',snames{sq},' Signal)']);
                    else
                        plot(1000*t,sig,lspc{sq},'LineWidth',2);
                        ylabel([snames{sq},' Signal']);
                    end
                end
                
                xlabel('Time (ms)');
                title(r.ftit);
                set(gca,'FontSize',14);
                box on;
            end

            % save the result
            if r.save
                % automatic numbering protocol
                dataname = ['signalResults/VS_Signal_',date,'_'];
                D = dir([dataname,'*']);
                save(strcat(dataname,num2str(length(D)+1),'_',snames{sq}),'t','sig','p','r');
            end
       
            % random extra stuff, plot analytical ASE solution
            if r.plotAnalytic && (sq == 3)
                [ta,sa] = analyticASE(t,p,r);
                figure(r.fnum);
                hold on;
                plot(1000*ta,sa,'--','LineWidth',2);
            end
        
        end
    end
        
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%     Phase calculating functions         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [tt,Phase] = phaseGRE(storedPhase,tarray,~,~)
    % calculate the phase from an FID sequence (by summing it up)
    
    Phase = cumsum(storedPhase,1);
    tt = tarray;
    
return;

function [tt,Phase] = phaseGESSE(storedPhase,tarray,p,~)
    % calculate the phase from a GESSE sequence
    
    ss = size(storedPhase);
    
    Tind = find(round(tarray.*1000) == round(p.TE.*500),1,'first');
    mask = repmat([ones(Tind,1); -ones(ss(1)-Tind,1)],1,ss(2));
    Phase = cumsum(storedPhase.*mask,1);
    
    % this line screws up our calculation of the intravascular signal, and
    % isn't really necessary, we can just have the time dimension of the
    % plot start at 0, rather than have TE be at t=0.
%     tt = tarray-p.TE;
    tt = tarray;

return;

function [tt,Phase] = phaseASE(storedPhase,tarray,p,r)
    % calculate the phase from an ASE sequence
    
    np = size(storedPhase,1); % number of time-points we have available
    t0 = p.deltaTE:p.deltaTE:p.deltaTE*np; % list of time-points
    
    % shift t0 so that 0 is at TE/2
    t0 = t0 - p.TE/2;
    
    % define the tau values that we want
    if r.defineTau == 1
        % if the user has specified an array of tau values
        tt = r.tau';
        
    else % the user has specified an increment
        
        % define tau values up to and including 0, then above 0 separately,
        % thus ensuring that 0 is included
        tt = [ -fliplr(0:p.tau:p.TE/2), p.tau:p.tau:p.TE/2 ];
        tt = tt(2:end-1);
    end
    
    % find the indices of points in t0 that are also in tt
    [~,it] = ismembertol(tt,t0,1e-6); % works better than INTERSECT
    it = it(it~=0); % remove zeros which result from ISMEMBERTOL
    
    % readout time
    Tind = find(round(tarray.*1000) == round(p.TE.*1000),1,'first');
    
    % compute phase for each inversion time
    Phase = zeros(length(it),size(storedPhase,2));
    for k = 1:length(it)
        Phase(k,:) = sum(storedPhase(1:it(k),:),1) - sum(storedPhase(it(k)+1:Tind,:),1);
    end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%     Intravascular phase functions         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function signal = ivsigGRE(tarray,R2,R2s,p)
    signal = exp(-tarray.*R2s); % simple T2* decay
return;

function signal = ivsigGESSE(tarray,R2,R2s,p)
    % based on Simon et al., 2016
    S1 = exp(-R2s.*tarray);
    S2 = exp(-R2.*(2.*tarray-p.TE) - R2s.*(p.TE-tarray));
    S3 = exp(-R2.*p.TE - R2s.*(tarray-p.TE));
    
    signal = S1.*(tarray<(p.TE/2)) + S2.*((tarray>=(p.TE/2)).*(tarray<p.TE)) + S3.*(tarray>=p.TE);
return;

function signal = ivsigASE(tarray,R2,R2s,p)
    % T2* decay, with refocusing pulse
    signal = exp(-p.TE.*R2) .* exp(-abs(tarray).*(R2s-R2));
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%     Analytical ASE solutions           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [tau,signal] = analyticASE(tarray,p,r)
    % anayltical ASE, based on He and Yablonskiy, 2007
    tau = linspace(tarray(1),tarray(end),101);
    
    R2 = 1./p.T2EV;
    zt = sum(p.vesselFraction);
    dw = (4/3)*pi*p.gamma*p.B0*p.deltaChi0.*p.Hct.*(1-p.Y);
    
    R2p = dw.*zt;
    R2s = R2 + R2p;
    R2m = R2 - R2p;
    
    S1 = exp(-R2.*(p.TE-2.*tau)+zt-(2.*R2m.*tau));
    S2 = exp(-(R2.*p.TE) - ((8/9).*zt.*(dw.*tau).^2));
    S3 = exp(-R2.*(p.TE-2.*tau)+zt-(2.*R2s.*tau));

    ti1 = find(tau>(-0.75/dw),1,'first');
    ti2 = find(tau<(0.75/dw),1,'last');

    signal = [S1(1:ti1-1), S2(ti1:ti2), S3(ti2+1:end)];
    if r.incT2 == 0
        signal = signal./max(signal); % normalize
    end
    disp(['DBV estimate: ',num2str(S3(51)-S2(51)), ' (True value: ',num2str(p.vesselFraction),')']);
    
return;