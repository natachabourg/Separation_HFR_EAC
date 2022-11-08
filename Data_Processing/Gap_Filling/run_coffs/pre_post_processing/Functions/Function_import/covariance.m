function [ cov ] = covariance( X,Y )
% MARMAIN - 2013/06/08
%   compute covariance between X and Y


mx = nanmean(X(:));
my = nanmean(Y(:));

X=X(:)-mx;
Y=Y(:)-my;

cov=nansum(X.*Y)/numel(X(isnan(X)==0));


end

