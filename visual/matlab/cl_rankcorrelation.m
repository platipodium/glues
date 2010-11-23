function [r,p,rlo,rup] = cl_rankcorrelation(x,y)
%LC_RANKCORRELATION Rank correlation coefficients.
%   R=CL_RANKCORRELATION(X) calculates a matrix R of rank correlation coefficients for
%   an array X, in which each row is an observation and each column is a
%   variable.
%

[xs,xr]=sort(x);
[ys,yr]=sort(y);


[r,p,rlo,rup]=corrcoef(xr,yr);
return;
end