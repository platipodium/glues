function read_cru()

cl_register_function();

[d,f]=get_files;

if ~isfield(d,'data')
  error('DATA directory not defined. Fix in get_files!');
end

precfile =fullfile(d.data,'climatology/cru','grid_10min_pre.dat');
if ~exist(precfile,'file');
  error('Cannot read precipitation data file');
end

tmeanfile=fullfile(d.data,'climatology/cru','grid_10min_tmp.dat');
if ~exist(tmeanfile,'file');
   error('Cannot read temperature data file');
end

%head grid_10min_pre.dat | wc
%      10     260    1870
%wc grid_10min_pre.dat
%  566268 14722968 105892116

%$ head grid_10min_tmp.dat
%  -59.083  -26.583    0.2    0.3    0.2   -1.9   -6.0   -9.8  -13.6   -9.2   -8.1   -5.3   -2.3   -1.1
%  -58.417  -26.250    0.6    0.8    0.7   -1.4   -5.4   -9.1  -12.9   -8.6   -7.5   -4.7   -1.8   -0.7

prec=load(precfile,'-ascii');
tmean=load(tmeanfile,'-ascii');

tlon=tmean(:,2); 
tlat=tmean(:,1);

plon=prec(:,2);
plat=prec(:,1);

pn=length(plon);
tn=length(tlon);
n=min([pn,tn]);

pstart=1;
tstart=1;
len=n-1;
igood=[];
i=0;

while (len>0)
ierr=find(plon(pstart:pstart+len)~=tlon(tstart:tstart+len) | plat(pstart:pstart+len)~=tlat(tstart:tstart+len));
if length(ierr)<1 break; end
igood=[igood, pstart:pstart+ierr(1)-2];
if (plon(pstart+ierr(1))==tlon(tstart+ierr(1)-1) & plat(pstart+ierr(1))==tlat(tstart+ierr(1)-1)) pstart=pstart+ierr(1); tstart=tstart+ierr(1)-1; 
elseif (plon(pstart+ierr(1)-1)==tlon(tstart+ierr(1)) & plat(pstart+ierr(1)-1)==tlat(tstart+ierr(1))) tstart=tstart+ierr(1); pstart=pstart+ierr(1)-1;
else pstart=pstart+ierr(1)-1; tstart=tstart+ierr(1)-1;
end
i=i+1;
len=n-min([pstart,tstart]);
fprintf('%d %d %d %d %d\n',i,pstart,tstart,ierr(1),len);
end

prec=prec(igood,3:14);
tmean=tmean(igood,3:end);


if str2num(version('-release'))<14 
    save('cru','prec','tmean','lon','lat');
else
    save('-v6','cru','prec','tmean','lon','lat');
end
   
return;
