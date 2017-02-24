function [t,sig] = plotSignal(storedPhase,p,r)
    % plots an MR signal based on the stored phase information in Phase,
    % with parameters specified in p and r. For use within simAnalyse.
    % Based on plotresults.m (NP Blockley, 2016).
    %
    % Created by MT Cherukara, February 2017
    
    % define time range
    ts = (p.deltaTE:p.deltaTE:p.TE*2)';
    
    % use r struct to decide which sequences we want to plot, then loop
    % through them all:
    seqs   = [r.plotFID, r.plotGRE, r.plotGESSE, r.plotASE];
    snames = {'FID'    ; 'GRE'    ; 'GES'      ; 'ASE'};
    
    for sq = 1:length(seqs)
        
        % choose the right sequence and evaluate it
        [t,ph] = eval(strcat('phase',snames{sq},'(storedPhase,ts)'));
        
        % calculate extravascular signal
        sigEV = abs(sum(exp(-1i.*ph),2)./p.N);
        
        % account for t2 decay
        if r.incT2
            sigEV = sigEV.*exp(-p.TE./p.T2EV);
        end
        
        % add in intravascular signal
        if r.incIV
            disp('No IV signal today...');
            sigIV = sigEV;
        else
            sigIV = sigEV;
        end
        
        sig = ((1-p.vesselFraction).*sigEV) + (p.vesselFraction.*sigIV);
        
        % display the result
        if r.display
            figure(10+sq)
            hold on;
            plot(t.*1000,sig,'o-','LineWidth',2);
            xlabel('Time (ms)');
            ylabel('Signal');
            set(gca,'FontSize',14);
            box on;
        end
        
        % save the result
        if r.save
            disp('Saving result not currently working...')
        end
        
        
    end
        
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%     Phase calculating functions         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [tt,Phase] = phaseFID(storedPhase,tarray)
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
    tt = (p.TE:-p.deltaTE*2:-p.TE)';

