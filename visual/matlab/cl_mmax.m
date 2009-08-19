function mmax=cl_mmax(vector)

cl_register_function;

valid=find(isfinite(vector));
mmax=max(vector(valid));


return
end