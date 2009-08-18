function lae=lae(npp,tli,nppstar)

cl_register_function();

if nargin<2
  error('Please provide at least two input arguments');
elseif nargin<3 nppstar=450; 
end
  
x=npp./nppstar;
lae=tli.*4.*x./(x.*x.*x+3);

return

