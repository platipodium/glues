function minmax=cl_range(data,dim);
% minmax=CL_RANGE(data,[dim]) computes minmax values of data in first non-unit
% size dimension, or along given dimension.

% Carsten Lemmen <carsten.lemmen@hzg.de>

% Default argument for dim: first dimension with len>1
if nargin<2
  dsize=size(d);
  idim=find(dsize>1);
  if isempty(idim) idim=1; else idim=idim(1); end
end

dmin=min(data,[],dim);
dmax=max(data,[],dim);

if nargout>0
  minmax=[dmin dmax];
end

return;
end