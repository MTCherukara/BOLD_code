% xPlotConvergence

% make a video of ASE curves for increasing Monte Carlo iterations (N)

clear; close all;

NN = [10, 14, 19, 26, 35, 49, 67, 92, 100, 126, 150, 173, 200, 237,...
      300, 326, 400, 447, 500, 614, 750, 843, 1000, 1156, 1587, 2179,...
      2500, 2991, 4105, 5000, 5635, 7734, 10000, 14571];
  
ni = length(NN);
F(ni) = struct('cdata',[],'colormap',[]);

% load the data
load('signalResults/VSsignal_Convergence2');

for ii = 1:ni
    
    figure(1);
    plot(1000*t,allsig(:,ii),'o-','LineWidth',2);
    ylabel('ASE Signal');
    xlabel('Spin Echo Offset \tau (ms)');
    title(['Iterations N = ',num2str(NN(ii))])
    set(gca,'FontSize',16);
    axis([-40, 40, 0.6, 1]);
    drawnow;
    F(ii) = getframe(gcf);
    
end
