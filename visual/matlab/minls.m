
function minls(t, x, amin, nmu_)

cl_register_function();

a_ar1 = exp(-1);
tol = 3.0e-8;         % Brent's search, precision
ol2 = 1.0e-6;          % multiple solutions, precision
nmu_=0;
n=length(t);

integer n
  double precision t(1:n),x(1:n)
  double precision amin
  integer nmu_
  double precision dum1,dum2,dum3,dum4,a_ar11,a_ar12,a_ar13
  double precision ls,brent
  external ls,brent
!
  nmu_=0;
  dum1=brent(-2.0  , a_ar1            , 2.0  , ls, tol, a_ar11, t, x, n);
  dum2=brent( a_ar1, 0.5*(a_ar1+1.0e0), 2.0  , ls, tol, a_ar12, t, x, n)
  dum3=brent(-2.0  , 0.5*(a_ar1-1.0e0), a_ar1, ls, tol, a_ar13, t, x, n)

  if  ((abs(a_ar12-a_ar11)>tol2 & abs(a_ar12-a_ar1) > tol2) ... |
      ( abs(a_ar13-a_ar11)>tol2 & abs(a_ar13-a_ar1) > tol2)) nmu_=1; end

  dum4=dmin1(dum1,dum2,dum3);
  if (dum4==dum2) amin=a_ar12;
  else if (dum4==dum3) amin=a_ar13
    else amin=a_ar11; end
  end
  return
  
  
