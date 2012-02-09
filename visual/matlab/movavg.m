function [arg1 arg2]=movavg(times,values,window,keepnan)
% [values]=movavg(times,values,window,keepnan)
% [times values]=movavg(times,values,window,keepnan)

cl_register_function();

if length(times)<1 arg1=[]; arg2=arg1; return; end

if ~exist('keepnan','var') keepnan=0; end

ji=1;
nt=length(times);
times=unique(times);
nut=length(times);
if nut<nt 
  if  nargout<2
    warning('Output values will be reduced due to non-unique time values');
  end
end

for it = 1:nut
  ind=find(times>times(it)-window/2.0 & times<times(it)+window/2.0);
  if ind
    mavg(ji)=mean(values(ind));
    ji=ji+1;
  elseif keepnan
    mavg(ji)=NaN;
    ji=ji+1;
  end
end
%movavg=values-mavg;
if nargout>1
  arg2=mavg';
  arg1=times;
else
  arg1=mavg';
end

return
