function fep=fep(npp,nppf)

cl_register_function();

  if nargin==1 nppf=900; end
  
  x=npp./nppf
  fep=2.*x./(x.*x+1)

return
