function err = fitfunrl2outof3_alpha(q)
%FITFUNRL Used by QUICKFITRL.

global Data
TINY = 1e-100;

ca = Data(:,1);	 % binary vector with item 1 choices
cb = Data(:,2);	 % binary vector with item 2 choices
cc = Data(:,3);  % binary vector with item 3 choices
rt = Data(:,4);  % binary vector with rewarded choices
np = Data(:,5);  % vector with index of non-presented item
bk = Data(:,6);  % binary vector with start of new block

n = length(ca);
na = sum(ca);
nb = sum(cb);
nc = sum(cc);

% Some initializations
V = zeros(n,3); 
V(1,1)=0.33; V(1,2)=0.33; V(1,3)=0.33;
pe = zeros(n,1);
pa = zeros(n,1);
pb = zeros(n,1);
pc = zeros(n,1);

alpha = q(1);
beta  = q(2);
lrate = q(3);

for i=1:n

    if bk(i),
        pe(i)=0;
        V(i,1)=0.33; V(i,2)=0.33; V(i,3)=0.33;
        pa(i,1)=0; pb(i,1)=0; pc(i,1)=0;
    end
    
	if np(i)==3
		pa(i) = 1 / (1 + exp(-(beta*(V(i,1)-V(i,2) - alpha))));
		pb(i) = 1 - pa(i); if i==1, pc(i)=pc(i); else pc(i)=pc(i-1); end
	elseif np(i)==2
		pa(i) = 1 / (1 + exp(-(beta*(V(i,1)-V(i,3) - alpha))));
		pc(i) = 1 - pa(i); if i==1, pb(i)=pb(i); else pb(i)=pb(i-1); end
	else
		pb(i) = 1 / (1 + exp(-(beta*(V(i,2)-V(i,3) - alpha))));
		pc(i) = 1 - pb(i); if i==1, pa(i)=pa(i); else pa(i)=pa(i-1); end
	end

    if ca(i)
        pe(i) = rt(i) - V(i,1);
        V(i+1,1) = V(i,1) + lrate*pe(i);
        V(i+1,2) = V(i,2); V(i+1,3) = V(i,3);
    elseif cb(i)
        pe(i) = rt(i) - V(i,2);
        V(i+1,2) = V(i,2) + lrate*pe(i);
        V(i+1,1) = V(i,1); V(i+1,3) = V(i,3);
    else
        pe(i) = rt(i) - V(i,3);
        V(i+1,3) = V(i,3) + lrate*pe(i);
        V(i+1,1) = V(i,1); V(i+1,2) = V(i,2);
    end
    
end

pa = pa - (pa > .999999)*TINY + (pa < .0000001)*TINY; 
pb = pb - (pb > .999999)*TINY + (pb < .0000001)*TINY;
pc = pc - (pc > .999999)*TINY + (pc < .0000001)*TINY;

err = -(sum(ca.*log(pa))/na + sum(cb.*log(pb))/nb + sum(cc.*log(pc))/nc);
