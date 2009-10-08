function [ilon,ilat]=regidx2geoidx(regidx,cols)
  
cl_register_function();

if ~exist('cols','var') cols=720; end;

  ilat=362-ceil(regidx/cols);  % -2
  ilon=mod(regidx,cols)+1; % +2

return

