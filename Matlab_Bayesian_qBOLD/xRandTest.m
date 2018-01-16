% xRandTest.m

clear;

X = rand(10000,1000);
Y = rand(10000,1000);

tic;
for ii = 1:1000
    L0 = norm(X(ii,:)-Y(ii,:));
end
toc;

tic;
for ii = 1:1000
    L1 = sum((Y(ii,:)-X(ii,:)).^2);
end
toc;




