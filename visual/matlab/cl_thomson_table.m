function cl_thomson_table
% Creates a table of the Thomson (1990) criterion to choose an appropriate p-value
% of confidence for a given length n of a time series
% p=1-1/n
% 
% Needs statistics toolbox

cl_register_function;

n=1:1:100;
n=horzcat(n,105:5:1000);
n=horzcat(n,1020:20:10000);
n=horzcat(n,10100:100:1E5);
n=horzcat(n,100500:500:1E6);
n=horzcat(n,1002000:2000:1E7);
n=horzcat(n,10010000:10000:1E8);
n=horzcat(n,1000050000:50000:1E9);
n=horzcat(n,10000200000:200000:1E10);
n=n';

p=1-1./n;
sigmalevel=norminv(p);

fid=fopen('thomson_table.tsv','wt');
fprintf(fid,'%d %12.10f %12.10f\n',[n p sigmalevel]');
fclose(fid);

return
end

