function [ilat,ilon]=cl_i2lli(index,cols)
  
cl_register_function();

if ~exist('cols','var') cols=720; end;

%index=(ilat-1)*cols+ilon;

ilat=ceil(index/cols);
ilon=index-(ilat-1)*cols;

return

