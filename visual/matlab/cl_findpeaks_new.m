function [pvalue,pindex]=cl_findpeaks_new(values)

cl_register_function;

if ~exist('values','var')
  values=[1 -4 -3 0 -2 3 4 -5 6 7 1 2 -2 3 -5 -1]/3;
end

n=length(values);


% find values which are bigger than either of their neighbours
if size(values,2)==1 values=values'; end

rside=[0 values(2:end)-values(1:end-1)];
lside=[values(1:end-1)-values(2:end) 0];

pindex=find(rside>0 & lside>0);
pvalue=values(pindex);

return
end
