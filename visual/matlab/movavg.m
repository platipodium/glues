function movavg=movavg(times,values,window)

cl_register_function();

ji=1;
nt=length(times);
for it = 1:nt
  ind=find(times>times(it)-window/2.0 & times<times(it)+window/2.0);
  if ind
    mavg(ji)=mean(values(ind));
    ji=ji+1;
  end
end
%movavg=values-mavg;
movavg=mavg';
return
