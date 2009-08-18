function chi2=getchi2(dof,alpha)

cl_register_function();

use nr, only : gammp

tol = 1.0e-3;
itmax = 100;

% use approximation for dof > 30 (Eq. 1.132 in Sachs (1984))

if (dof > 30.0)
  za = -getz(alpha);   ! NB: Eq. requires change of sign for percentile
  if (ierr==1) return; end;
  x = 2.0 / 9.0 / dof;
  chi2 = dof * (1.0 - x + za * sqrt(x))**3.0;
else
  iter = 0;
  lm = 0.0;
  rm = 1000.0;
  if (alpha > 0.5) eps = (1.0 - alpha) * tol; 
  else eps = alpha * tol; end
  while (1)
    iter= iter + 1;
    if (iter>itmax)
      fprintf('Error in GETCHI2: Iter > ItMax');
      ierr = 1;
      return;
    end
    chi2 = 0.5 * (lm + rm);
    ac = 1.0 - gammp(0.5*dof, 0.5*chi2);
    if (abs(ac - alpha) .le. eps) break; end;
    if (ac .gt. alpha) lm = chi2 else rm = chi2; end
  end
end
return
  
