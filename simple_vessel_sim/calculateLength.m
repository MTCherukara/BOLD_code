function l = calculateLength(Normals,Origins,p)
    % calculate lengths of vessels in sphere
    a = sum(Normals.^2,2);
    b = 2*sum(Origins.*Normals,2);
    c = sum(Origins.^2,2)-p.universeSize.^2;
    
    delta = b.*b-4*a.*c;
    
    u1 = (-b-sqrt(delta))./2./a;
    u2 = (-b+sqrt(delta))./2./a;
    p1 = Origins+repmat(u1,1,3).*Normals;
    p2 = Origins+repmat(u2,1,3).*Normals;
    l  = sqrt(sum((p2-p1).^2,2));
return;
