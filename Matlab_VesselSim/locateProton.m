function inside = locateProton(posit,radii,Q1,Q2)
    % Usage: 
    %
    %       inside = locateProton(posit,radii,Q1,Q2)
    %
    % Determine quickly whether a proton at POSIT is inside a blood vessel
    % of known RADIUS, with the distribution of blood vessels defined by Q1
    % and Q2:
    %
    %   Q1 = vesselOrigins + vesselNormals.*0.5;
    %   Q2 = vesselOrigins - vesselNormals.*0.5;
    %
    % with the 0.5 multipliers added to avoid having to do any
    % normalization after calculating a cross-product. vesselOrigins and
    % vesselNormals should have been created using setupUniverse (within
    % simplevesselsim.m).
    %
    % locateProton returns 1 if the proton is within a vessel, and 0 if it
    % is not. 
    %
    % 22 Feb - modify to accept a range of different vessel radii (MTC)
    %
    % MT Cherukara
    % 16 February 2017
 
    posits = repmat(posit,size(Q1,1),1); % added this so it works on MATLAB 2015
    QDPQ = abs(cross(Q2-Q1,posits-Q1));
    
    [mind,mini] = min(max(QDPQ,[],2));
        
    if mind < radii(mini)
        inside = 1;
    else
        inside = 0;
    end
    
return;