% xIntegrals.m
%
% Trying out some stuff to do with the analytical vs. asymptotic qBOLD
%
% MT Cherukara
% 13 March 2018

clear;

xx = linspace(0,20);
% JJ = besselj(0,xx);
JJ = xx;

figure;
hold on; box on;
plot(xx,cumsum(JJ)./);

