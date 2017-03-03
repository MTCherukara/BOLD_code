function [t,sig] = plotSignal(storedPhase,p,r)
    % plots an MR signal based on the stored phase information in Phase,
    % with parameters specified in p and r. For use within simAnalyse.
    % Based on plotresults.m (NP Blockley, 2016).
    %
    % Created by MT Cherukara, February 2017
    
    % define time range
    ts = (p.deltaTE:p.deltaTE:(p.numSteps*p.deltaTE/p.ptsPerdt))';
    
    % use r struct to decide which sequences we want to plot, then loop
    % through them all:
    seqs   = [r.plotFID, r.plotGESSE, r.plotASE];
    snames = {'GRE'    ; 'GESSE'    ; 'ASE'};
    
    for sq = 1:length(seqs)
        
        if seqs(sq) == 1 % only do those sequences that we asked for

            % choose the right sequence and evaluate it
            [t,ph] = eval(strcat('phase',snames{sq},'(storedPhase,ts,p,r)'));

            % calculate extravascular signal
            sigEV = abs(sum(exp(-1i.*ph),2)./p.N);

            % account for t2 decay
            if r.incT2
                
                if sq == 1 || sq == 2 % do this for GRE and GESSE
                    sigEV = sigEV.*exp(-t./p.T2EV);
                else % do this for other sequences (e.g. ASE)
                    sigEV = sigEV.*exp(-p.TE./p.T2EV);
                end
            end

            % add in intravascular signal
            if r.incIV
                
                % constants from Simon et al. 2016
                R2  = repmat((16.4.*p.Hct+ 4.5)+(165.2.*p.Hct+55.7).*(1-p.Y).^2,length(t),1);
                R2s = repmat((14.9.*p.Hct+14.7)+(302.1.*p.Hct+41.8).*(1-p.Y).^2,length(t),1);
                
                % call a bunch of separate functions for calculating
                % intravascular signal for each sequence
                sigIV = eval(strcat('ivsig',snames{sq},'(t,R2,R2s,p)'));
                
            else
                sigIV = sigEV;
            end

            sig = ((1-p.vesselFraction).*sigEV) + (p.vesselFraction.*sigIV);

            % display the result
            if r.display
                figure(r.fnum);
                hold on;
                plot(1000*t,sig,'o-','LineWidth',2);
                xlabel('Time (ms)');
                ylabel([snames{sq},' Signal']);
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
            
            % need to add something that saves the figure out too
            
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
    
    Tind = find(round(tarray.*1000) == round(p.TE.*1000),1,'first');
    
    for k = 1:Tind-1
        Phase(k,:) = sum(storedPhase(1:k,:),1)-sum(storedPhase(k+1:Tind,:),1);
    end
    
    % these are the point we want, given the tau value chosen by the user
    if r.defineTau == 1
        tt = r.tau';
    else
        tt = (-p.TE/2:p.tau:p.TE/2)';
        tt = tt(2:end-1);
    end
    
    % these are all the time-points that are available
    t0 = (-p.TE/2:p.deltaTE:p.TE/2)';
    t0 = t0(2:end-1);
    
    % find the indices of points in t0 that are also in tt
    [~,~,it] = intersect(tt,t0);
    
    % select the right elements in Phase
    Phase = Phase(it,:);
    
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