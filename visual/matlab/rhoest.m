function rho=rhoest(x)
% Autocorrelation coefficient estimation for equidistant data
% rho=Sum_i(x_i*x_{i-1}) / Sum_i(x_i*x_i)
%
% Carsten Lemmen <carsten.lemmen@gkss.de>
% Last change 2008-02-19
%
cl_register_function();

n=length(x);
sum1=0.0
sum2=0.0

for i=2:n
  sum1=sum1+x(i)*x(i-1);
  sum2=sum2+x(i)*x(i);
end
rho=sum1/sum2;
return
