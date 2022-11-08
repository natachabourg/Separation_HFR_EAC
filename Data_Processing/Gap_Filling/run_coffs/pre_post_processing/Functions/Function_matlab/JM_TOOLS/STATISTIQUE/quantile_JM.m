function [ value ] = quantile_JM( X,Qua )
% MARMAIN - 2013/01/23
%
% Compute the Qua quantile of the serie X
% Values of X are sorted in ascend order
% 
% INPUTS:   X: distribution (with or without NaN
%           Qua: quantile
%
% OUTPUT:   value: value of the quantile Qua of serie X

tmp=sort(X(:),'ascend');
tmp(isnan(tmp)==1)=[];
value=tmp(floor(length(tmp)*Qua));

if 0
figure; plot(tmp)
end

end

