function LS = optimTan(xx)
    % Optimization objective function for tan correction to estimated OEF
    % values. For use within FMINSEARCH (or similar) only. Should be called by
    % xOptimizeTan.m
    %
    % MT Cherukara
    % 29 July 2019
    
    % Declare global parameters that should be defined by xOptimizeTan.m
    global estOEF truOEF
    
    % pull out xx values
    p1 = xx(1);
    p2 = xx(2);
    p3 = xx(3);
    p4 = 0;%xx(4);
    
    % tan equation
    modOEF = p1.*tan(p2.*(estOEF+p4)) + p3;
    
    % sum of squares difference
    LS = sum((modOEF - truOEF).^2);
    
    