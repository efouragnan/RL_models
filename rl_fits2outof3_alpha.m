function [V,pe,pa,pb,pc,beta,lrate,alpha,err,bic]=rl_fits2outof3_alpha(X)

% X matrix as N x 5 (N = trials)
% 1st column: Choices for option A
% 2nd column: Choices for option B
% 3nd column: Choices for option C
% 4th column: Reward/Feedback Received 
% 5th column: Non-presented option (A, B or C) 
% 6th column: Start of new block

% References:
% 1) Determining a role for ventromedial prefrontal cortex in encoding action-based value signals during reward-related decision making
%    Jan Glascher, Alan N. Hampton and John P. OÕDoherty
% 2) The role of the ventromedial prefrontal cortex in abstract state-based inference during decision making in humans
%    Alan N. Hampton, Peter Bossaerts, and John P. OÕDoherty
% 3) Neural computations underlying action-based decision making in the human brain
%    Klaus Wunderlich, Antonio Rangel, and John P. O'Doherty

[alpha,beta,lrate,err] = quickfit_lr2outof3_alpha(X);

% Some initializations
n = size(X,1);
V = zeros(n,3); 
V(1,1)=0.33; V(1,2)=0.33; V(1,3)=0.33;
pe = zeros(n,1);
pa = zeros(n,1);
pb = zeros(n,1);
pc = zeros(n,1);

% rebuild Values and PE's
for i=1:n
    
    if X(i,6),
        pe(i)=0;
        V(i,1)=0.33; V(i,2)=0.33; V(i,3)=0.33;
        pa(i,1)=0; pb(i,1)=0; pc(i,1)=0;
    end
    
    if X(i,5)==3
		pa(i) = 1 / (1 + exp(-(beta*(V(i,1)-V(i,2) - alpha))));
		pb(i) = 1 - pa(i); if i==1, pc(i)=pc(i); else pc(i)=pc(i-1); end
	elseif X(i,5)==2
		pa(i) = 1 / (1 + exp(-(beta*(V(i,1)-V(i,3) - alpha))));
		pc(i) = 1 - pa(i); if i==1, pb(i)=pb(i); else pb(i)=pb(i-1); end
	else
		pb(i) = 1 / (1 + exp(-(beta*(V(i,2)-V(i,3) - alpha))));
		pc(i) = 1 - pb(i); if i==1, pa(i)=pa(i); else pa(i)=pa(i-1); end
    end
    
    
    if X(i,1)
        pe(i) = X(i,4) - V(i,1);
        V(i+1,1) = V(i,1) + lrate*pe(i);
        V(i+1,2) = V(i,2); V(i+1,3) = V(i,3);
    elseif X(i,2)
        pe(i) = X(i,4) - V(i,2);
        V(i+1,2) = V(i,2) + lrate*pe(i);
        V(i+1,1) = V(i,1); V(i+1,3) = V(i,3);
    else
        pe(i) = X(i,4) - V(i,3);
        V(i+1,3) = V(i,3) + lrate*pe(i);
        V(i+1,1) = V(i,1); V(i+1,2) = V(i,2);
    end
    
    
end

V = V(1:n,:);

% BIC = -2*logL + M*log(N)/N - M: fitted parameters, N: trials
m = 3; % alpha, beta, lrate
bic = 2*err + m*log(n)/n;
