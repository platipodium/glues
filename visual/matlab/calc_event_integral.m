function [reduction]=calc_event_integral()

cl_register_function();

owd=pwd;
cd '../../'
eventmodel;
cd 'visual/matlab';

eventregtime=load('../../eventregtime.tsv','-ascii');

eventregind=ones(size(eventregtime,1),1);

tmax=timeend;
tmin=siminit;


nr=685;
nt=floor(abs(tmax-tmin*1.0)/timestep+1);
regionfluc=zeros(nt,nr);

%
time=1950-(([0:nt-1]*timestep)+tmin);

for flucampl=0.0:0.1:1.0
for it=1:nt
    
    for i=1:nr
    
      told = time(it)-eventregtime(i,eventregind(i));
	  tnew = eventregtime(i,eventregind(i)+1)-time(it);
    
	  if (told < tnew) eventregind(i)=eventregind(i)+1; end
	
	  omt=(time(it)-eventregtime(i,eventregind(i)))/flucperiod;
	  fluc=1-flucampl*exp(-omt*omt);				    
      
      %fprintf('%d\t%.0f %.0f %.0f\t%d %.0f %f %f\n',i,time,told,tnew,eventregind(i),eventregtime(i,eventregind(i)),omt,fluc);

      regionfluc(it,i)=fluc;
    end
end
    
%save('regionfluc','-v6','regionfluc','time');
fprintf('Total fluctuation integral at flucampl %.1f %f\n',flucampl,sum(sum(regionfluc))/nt/nr);
end

return
end
