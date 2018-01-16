% xLinesIntegration

% for testing the integral that finds the average distance between two
% lines

clear; close all;

P1 = [0,0,0];   % a line that runs straight along x
P2 = [1,0,0];

Q1 = [0,0,1];   % a line that runs diagonally on the plane z=1
Q2 = [1,0,1];

% the average distance between P and Q should be 1

P21 = P2-P1;
QQ1 = Q1.*(P1-(Q1/2));
QQ2 = Q2.*(P1-(Q2/2));

integrn = cross(P21,QQ2) - cross(P21,QQ1);

A = norm(integrn)/(norm(P2-P1)*norm(Q2-Q1));