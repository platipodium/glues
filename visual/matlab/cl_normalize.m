function xn=cl_normalize(x)

isfin=isfinite(x);

xf=(x(isfin)-mean(x(isfin)))./std(x(isfin));
xn=x;
xn(isfin)=xf;

return
end