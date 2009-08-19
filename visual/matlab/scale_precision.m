function sdata=scale_precision(data,prec)

cl_register_function();

%data=[-327.587,0.0001,3.00005,3.56,120];

if ~exist('data','var')
    error('Please provide data as first input argument');
end

if ~exist('prec','var')
    prec=2;
end
if prec<1
    error('Precision must be at least 1');
end

absmin=min((abs(data)));
absmax=max((abs(data)));

omax=ceil(log10(absmax));
omin=floor(log10(absmin));

sdata=round(data/10^omax*10^prec)*10^(omax-prec);

return
