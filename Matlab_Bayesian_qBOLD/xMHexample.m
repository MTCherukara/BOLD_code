% xMHexample.m
%
% an animated example of the metropolis hastings algorithm
%
% Created 7 March 2017

clear; close all;

% target
t_mu = 0;
t_sd = 0.2;

% generate true likelihood
x = linspace(-1,1);
y = normpdf(x,t_mu,t_sd);
y = y./max(y); % normalize it 

% plot true likelihood
figure(1);
subplot(2,1,1);
plot(x,y,'-','LineWidth',2);
hold on;
axis([-1, 1, 0, 1.1])

% proposal
p_mu = 0.5;
p_sd = 0.1;

% alogirthm
njump = 5000;

track = [];
kX = p_mu;

% movie-making
% F1(njump) = struct('cdata',[],'colormap',[]);
tic;
for ii = 1:njump
    
    track = [track,kX];
    
    % choose candidate point from normal distribution centred around kX,
    % with standard deviation p_sd
    kY = kX + p_sd.*randn;
    
    % evaluate our function at point kX and point kY
    pi_X = normpdf(kX,t_mu,t_sd);
    pi_Y = normpdf(kY,t_mu,t_sd);
    
    if min(pi_Y./pi_X,1) > rand
        kX = kY;
    end
    
    % show points
%     figure(1);
%     subplot(2,1,1);
%     plot(kX,0.1,'ro');
%     
%     subplot(2,1,2);
%     plot(track,1:ii,'k-');
%     axis([-1, 1, 0, njump])
%     drawnow;
%     
%     F1(ii) = getframe(gcf);
    
    % update proposal distribution size after enough time has passed
    if ii > 100
        p_sd = std(track(floor(ii/2):ii));
    end
end
toc;
% % show tracking
% figure(4);
% plot(track,1:njump,'k-');

% show result
figure(3)
hist(track,25);
xlim([-1,1]);