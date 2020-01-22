function [alpha,beta,lrate,err]=quickfit_lr2outof3_sidebias(data)

global Data
Data = data;

q(1,1) = 0;    % sidebias
q(2,1) = 2;    % beta
q(3,1) = 0.5;  % learning rate


quick = fmincon(@(q) fitfunrl2outof3_sidebias(q), q, [],[],[],[],[-10; 0; 0],[10; 20; 1],[],optimset('Display','off','TolX',.0001,'Algorithm','interior-point'));
%quick = fmincon(@(q) fitfunrl2outof3(q), q, [],[],[],[],[-10; 0; 0],[10; 20; 1],[],optimset('Display','off','TolX',.0001));

% quick
alpha = quick(1,1);
beta  = quick(2,1);
lrate = quick(3,1);
err = fitfunrl2outof3_sidebias(quick);
