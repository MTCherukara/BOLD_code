% xVesselDistances
%
% calculate the average distances between a bunch of vessels generated in
% the same manner as the simplevesselsim.m
%
% MT Cherukara. 6/7/17


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%     MAIN                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Dhat,R] = xVesselDistances(p)
    
    % p to be passed to setupUniverse
    p.universeSize = p.universeScale*p.R;
%     p.universeSize = 0.0045;
%     p.R = 1e-4;
%     p.vesselFraction = 0.03;
    
    % generate the universe, as normal
    [vesselOrigins, vesselNormals, ~, numVessels, ~] = setupUniverse(p);
    
    % use this script to work out the end points of each vessel
    [~,p1,p2] = calcLength(vesselNormals,vesselOrigins,p.universeSize);
   
    % this array will store the distance values
    D  = zeros(numVessels,1);
    

    % loop through all vessels, then through all-but-one vessels 
    for ii = 1:numVessels
        P1 = p1(ii,:);
        P2 = p2(ii,:);
        
        others = 1:numVessels;
        others(ii) = [];
        
        Ds = zeros(numVessels-1,1);
        
        for jj = 1:numVessels-1
            Q1 = p1(others(jj),:);
            Q2 = p2(others(jj),:);
            
            Ds(jj) = calcDistance(P1,P2,Q1,Q2);
            
        end
        D(ii) = min(Ds); % pick out the smallest distance
    end
    
    Dhat = mean(D);
    R = p.R;
    
%     disp(['Vessel Radius: ',num2str(R*1e6),' um']);
%     disp(['Number of Vessels: ',num2str(numVessels)]);
%     disp(['Average Distance: ',num2str(Dhat*1e6),' um']);
            
return;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%     setupUniverse                   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [vesselOrigins, vesselNormals, R, numVessels, vesselVolFrac] = setupUniverse(p)

    volUniverse = (4/3)*pi*p.universeSize^3;  % p.universeSize = p.universeScale*min(p.R);
    M = 100000; %max number of vessels
    
    % generate some (normalized) random directions (lines from the centre
    % of the universe to the edge), then pick a random point along each
    % line and use that as the origin for each vessel (half of the vessels
    % will begin at the edge of the universe, rather than at the end).
    randomNormals = randn(M,3);
    randomNormals = randomNormals./repmat(sqrt(sum(randomNormals.^2,2)),1,3);
    r = repmat(p.universeSize.*rand(M,1).^(1/3),1,3); % this can be efficiencied, 
    
    r(2:2:end,:) = repmat(p.universeSize,M/2,3); %half of vessel origins on the surface
    vesselOrigins = r.*randomNormals;

    % generate random (normalized) directions for each vessel
    vesselNormals = randn(M,3);
    vesselNormals = vesselNormals./repmat(sqrt(sum(vesselNormals.^2,2)),1,3);
    
    % calculate lengths of vessels in sphere
    l = calcLength(vesselNormals,vesselOrigins,p.universeSize);
        
    % assign all vessels to have the same radius
    R(1:M,:)        = repmat(p.R,M,1);

    % calculate total cumulative volume of all vessels (this does not
    % take into account the fact that vessels can be overlapping, but
    % that's probably fine) (also, there's a fudge factor of 1.5 to
    % ensure that at the middle of the universe the vessel fraction is
    % about right)
    volSum = 1.5*(cumsum(l.*pi.*R.^2));

    % find the vessel at which we reach the desired volume, and
    % remember that point, checking the chosen vesselFraction
    cutOff = find(volSum<(volUniverse.*sum(p.vesselFraction)),1,'last');
        
    if cutOff==M
    	disp('Error: Increase max vessels!');
    end
    
    R               = R(1:cutOff);
    vesselOrigins   = vesselOrigins(1:cutOff,:);
    vesselNormals   = vesselNormals(1:cutOff,:);
	vesselVolFrac   = volSum(cutOff)/volUniverse;
    numVessels      = cutOff;
    
return;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%     calcLength                      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [l,p1,p2] = calcLength(Normals,Origins,universeSize)
    % calculate lengths of vessels in sphere
    a = sum(Normals.^2,2);
    b = 2*sum(Origins.*Normals,2);
    c = sum(Origins.^2,2)-universeSize.^2;
    
    delta = b.*b-4*a.*c;
    
    u1 = (-b-sqrt(delta))./2./a;
    u2 = (-b+sqrt(delta))./2./a;
    p1 = Origins+repmat(u1,1,3).*Normals;
    p2 = Origins+repmat(u2,1,3).*Normals;
    l  = sqrt(sum((p2-p1).^2,2));
return;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%     calcDistance                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function d = calcDistance(P1,P2,Q1,Q2)
    % calculate the average distance between lines defined as P1-P2 and
    % Q1-Q2
    
    P21 = P2-P1;
    
    LP = norm(P21);     % lengths
    LQ = norm(Q2-Q1);
    
    QQ1 = Q1.*(P1-(Q1/2));  % = integral (P1-Q) dQ
    QQ2 = Q2.*(P1-(Q2/2));
    
    d =  norm(cross(P21,(QQ2-QQ1))) ./ (LP*LQ);
    
return;