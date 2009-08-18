
function dof=getdof(iwin, n50)
% Effective number of degrees of freedom for the selected window
% and n50 overlappaing segments (Harris, 1978)

cl_register_function();

c50=[0.500, 0.344, 0.167, 0.250, 0.096];
rn = real(n50);
c2 = 2.0 * c50(iwin) * c50(iwin);
denom = 1.0 + c2 - c2/rn;
neff = rn / denom;
dof = 2.0 * neff;
return;
