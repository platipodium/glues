function [regidx]=geoidx2regidx(ilon,ilat,cols)
  
cl_register_function();

if ~exist('cols','var') cols=720; end;

  regidx= (362-ilat)*cols+ilon;
  
return
