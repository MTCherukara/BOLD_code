function [t,sig] = plotSignal(storedPhase,p,r)
    % plots an MR signal based on the stored phase information in Phase,
    % with parameters specified in p and r. For use within simAnalyse.
    % Based on plotresults.m (NP Blockley, 2016).
    %
    % Created by MT Cherukara, February 2017
    
    % define time range
    ts = (p.deltaTE/2:p.deltaTE/2:p.TE*2)';
    
    % use r struct to decide which sequences we want to plot, then loop
    % through them all:
    seqs   = [r.plotFID, r.plotGESSE, r.plotASE];
    snames = {'GRE'    ; 'GES'      ; 'ASE'};
    
    for sq = 1:length(seqs)
        
        if seqs(sq) == 1 % only do those sequences that we asked for

            % choose the right sequence and evaluate it
            [t,ph] = eval(strcat('phase',snames{sq},'(storedPhase,ts,p)'));

            % calculate extravascular signal
            sigEV = abs(sum(exp(-1i.*ph),2)./p.N);

            % account for t2 decay
            if r.incT2
                
                if sq == 1 % do this for FID
                    sigEV = sigEV.*exp(-t./(p.T2EV*1000)); 
                else % do this for other sequences that have fixed TE
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
        
        end
    end
        
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%     Phase calculating functions         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [tt,Phase] = phaseGRE(storedPhase,tarray,p)
    % calculate the phase from an FID sequence (by summing it up)
    
    Phase = cumsum(storedPhase,1);
    tt = tarray;
    
return;

function [tt,Phase] = phaseGES(storedPhase,tarray,p)
    % calculate the phase from a GESSE sequence
    
    ss = size(storedPhase);
    
    Tind = find(round(tarray.*1000) == round(p.TE.*500),1,'first');
    mask = repmat([ones(Tind,1); -ones(ss(1)-Tind,1)],1,ss(2));
    Phase = cumsum(storedPhase.*mask,1);
    
    tt = tarray-p.TE;

return;

function [tt,Phase] = phaseASE(storedPhase,tarray,p)
    % calculate the phase from an ASE sequence
    
    Tind = find(round(tarray.*1000) == round(p.TE.*1000),1,'first');
    
    for k = 1:Tind+1
        Phase(k,:) = sum(storedPhase(1:k-1,:),1)-sum(storedPhase(k:Tind,:),1);
    end
    tt = (p.TE:-p.deltaTE:-p.TE)';
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%     Intravascular phase functions         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function signal = ivsigFID(tarray,R2,R2s,p)
    signal = exp(-tarray.*R2s); % simple T2* decay
return;

function signal = ivsigGES(tarray,R2,R2s,p)
    % based on Simon et al., 2016
    S1 = exp(-R2s.*tarray);
    S2 = exp(-R2.*(2.*tarray-p.TE) - R2s.*(p.TE-tarray));
    S3 = exp(-R2.*p.TE - R2s.*(tarray-p.TE));
    
    signal = S1.*(t<(p.TE/2)) + S2.*((t>=(p.TE/2)).*(t<p.TE)) + S3.*(t>=p.TE);
return;

function signal = ivsigASE(tarray,R2,R2s,p)
    % T2* decay, with refocusing pulse
    signal = exp(-p.TE.*R2) .* exp(-abs(tarray).*(R2s-R2));
return;