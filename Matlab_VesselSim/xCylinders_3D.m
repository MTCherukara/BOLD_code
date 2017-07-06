% xCylinders_3D.m

% The same idea as xCylinders.m, but in 3 dimensions
%
% trying to work out a solution to the Yablonskiy condition for static 
% dephasing (from Yablonskiy and Haacke, 1994):
%
%       1/(z*dw) << (r/2)^2/6D
%

clear; close all;

% generate space, a square of side 1, and fill it with randomly positioned
% and oriented cylinders, each cylinder must have the following: xpos,
% ypos, zpos, theta, phi.

% theta is rotation on x-y plane, phi is angle w.r.t z axis

% parameters
M = 10; % maximum number of cylinders
Z = 0.05; % total volume that should be occupied by cylinders
R = 0.02; % radius of cylinders

% generate cylinders, each one has [XPOS, YPOS, ZPOS, THETA, PHI];
pos = rand(M,5);
pos(:,4:5) = pos(:,4:5)*pi; % so that they are both angles forming a half-sphere

p1(:,1) = pos(:,1) + 5*cos(pos(:,4)); % all lines have length 10
p1(:,2) = pos(:,2) + 5*sin(pos(:,4));
p1(:,3) = pos(:,3) + 5*sin(pos(:,5));

p2(:,1) = pos(:,1) - 5*cos(pos(:,4));
p2(:,2) = pos(:,2) - 5*sin(pos(:,4));
p2(:,3) = pos(:,3) - 5*sin(pos(:,5));


% make a meshed grid of points
np = 25;
pts = linspace(0,1,np);
d = zeros(np,np,np,M);

for ii = 1:M
    
    P2 = p2(ii,:);
    P1 = p1(ii,:);
    
    df = norm(P2-P1);
    
    for iz = 1:np
        for iy = 1:np
            for ix = 1:np
                
                P0 = [pts(ix),pts(iy),pts(iz)];
                d(ix,iy,iz,ii) = norm(cross((P2-P1),(P1-P0)))./df;
                
            end
        end
    end
    
end

[md,ci] = min(d,[],4);

% grid of dots
[xg,yg,zg] = meshgrid(pts,pts,pts);
zz = zeros(np);
 
% calculate average distance
rhat = mean(md(:));
disp(['Average Distance to Line: ',num2str(rhat)]);

% visualise
figure('WindowStyle','Docked');
hold on; box on;
plot3([p2(:,1),p1(:,1)]',[p2(:,2),p1(:,2)]',[p2(:,3),p1(:,3)]','k-');
scatter3(xg(:),yg(:),zg(:),25,ci(:),'filled');
axis([0 1 0 1 0 1]);

% % visualise closest points
% figure('WindowStyle','Docked');
% hold on; box on;
% surf(linspace(0,1,np),linspace(0,1,np),ci,'EdgeColor','none');
% view(2);
% 
% % visualise distance from vessel
% figure('WindowStyle','Docked');
% hold on; box on;
% surf(linspace(0,1,np),linspace(0,1,np),md,'EdgeColor','none');
% view(2);

