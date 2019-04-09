% xSigmoids.m
%
% Playing around with some sigmoid functions

clear;
setFigureDefaults;

% define a domain between 0 and 1
x = linspace(0,1);

% tanh
y = 0.5*tanh(4*(x-0.5))+0.5;

% plot it
figure(1);
plot(x,y);
axis([0,1,0,1]);
