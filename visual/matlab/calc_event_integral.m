function [reduction]=calc_event_integral()

cl_register_function();

owd=pwd;
cd '../../'
eventmodel;
cd 'visual/matlab';

eventregind=ones(685,1);
eventregtime=load('../../eventregtime.tsv','-ascii');

tmax=10500;
tmin=0;
siminit=11500;

nr=685;
nt=floor((tmax-tmin*1.0)/timestep+1);
regionfluc=zeros(nt,nr);
time=siminit-([0:nt-1]*timestep+tmin);

for it=1:nt
    % fprintf('%f\n',time); continue;
    
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
    
save('regionfluc','-v6','regionfluc','time');
fprintf('Total fluctuation integral %f\n',sum(sum(regionfluc))/nt/nr);

return
end
