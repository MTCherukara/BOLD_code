function PVALS = MC_pvalues(MC_ARRAY,PAIRS)
    % MC_pvalues usage:
    %
    %       PVALS = MC_pvalues(MC_ARRAY,PAIRS)
    %
    % Returns a vector of P-values PVALS extracted from a multcompare array
    % MC_ARRAY corresponding to the pairwise comparisons of cell-array PAIRS
    %
    % For use with barcharts.m (and derived scripts) performing statistical
    % analysis on Fabber results, using ANOVA2 and MULTCOMPARE, to be plotted
    % later using SIGSTAR
    %
    % Created 17 July 2018
    % MT Cherukara
    
    
% Assume that the inputs are fine. We can build in some checks later...

np = length(PAIRS);
PVALS = zeros(np,1);

% loop through specified pairs
for pp = 1:np
    
    % find the line in MC_ARRAY which matches the current pair
    lns = all( ( MC_ARRAY(:,1:2) == PAIRS{pp} )' );
    
    % store the p-value of that line in PVALS
    PVALS(pp) = MC_ARRAY(lns,6);
    
end
    
    