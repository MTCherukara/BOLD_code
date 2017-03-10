function coords = MTC_circle(x,y,r)
    % define coordinates for plotting a circle of radius r centred at (x,y)
    %
    % MT Cherukara
    % 14 February 2017
    
    ang = linspace(0,2*pi);
    xp = r.*cos(ang);
    yp = r.*sin(ang);
    coords = [xp+x;yp+y];