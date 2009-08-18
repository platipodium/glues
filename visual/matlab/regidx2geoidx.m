function [ilon,ilat]=regidx2geoidx(regidx,cols)
  
cl_register_function();

if ~exist('cols','var') cols=720; end;

  ilat=ceil(regidx/cols);  % -2
  ilon=mod(regidx-1,cols)+1; % +2

return

