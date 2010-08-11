function [retdata,basename]=clp_ncep_timeseries(varargin)


arguments = {...
%  {'latlim',[-inf inf]},...
%  {'lonlim',[-inf inf]},...
  {'latlim',[35 37]},...
  {'lonlim',[64 66]},...
  {'timelim',[1948,2007]},...
  {'lim',[-inf,inf]},...
  {'variable','prate'},...
  {'scale','absolute'},...
  {'figoffset',0},...
  {'nosum',0},...
  {'nocolor',0},...
  {'retdata',NaN},...
  {'nearest',0}
};

cl_register_function;

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); end

files=dir(fullfile('data',['ncep_' variable '*.mat']));
if isempty(files)
  warning('No NCEP files in data directory. Try cl_get_ncep!');
  return
end
nfiles=length(files);
for i=1:nfiles names(i)={files(i).name}; end

years=timelim(1):timelim(2);
nyear=length(years);
offset=0;
monthlen=[31,28,31,30,31,30,31,31,30,31,30,31];
monthoff(1)=0;
for m=2:12 monthoff(m)=sum(monthlen(1:m-1)); end

for iyear=1:nyear
  year=years(iyear);
  ifile=strmatch(['ncep_' variable '_' num2str(year)],names);
  if isempty(ifile) warning('No data for this year'); 
    continue
  end
  
  d=load(fullfile('data',names{ifile}));
  ilat=find(d.lat>=latlim(1) & d.lat<=latlim(2));
  ilon=find(d.lon>=lonlim(1) & d.lon<=lonlim(2));
  nday=size(d.p,1);
  d.p=d.p*86400.0; %(convert to mm per day)
  if (nday>365) leap(iyear)=1; else leap(iyear)=0; end
  prec(1+offset:nday+offset,:,:)=d.p(:,ilat,ilon);
  for m=1:12
    im=1+monthoff(m):monthlen(m)+monthoff(m);
    if (m==2 & leap(iyear)) im=[im,60];
    elseif (m>2 & leap(iyear)) im=im+1;
    end
    [im(1),im(end)]
    mprec(m+(iyear-1)*12,:,:)=sum(d.p(im,ilat,ilon),1);
  end
  aprec(iyear,:,:)=sum(d.p(:,ilat,ilon),1);
  
  offset=offset+nday;
end

save('test.mat','prec','mprec','aprec','-v6','leap','years');

%%
load('test.mat');

figure(1);
clf reset;

maprec=squeeze(mean(mean(aprec,3),2));
mmprec=squeeze(mean(mean(mprec,3),2));
%mdprec=squeeze(mean(mean(prec,3),2));


mtime=years(1)-0.5+[0:length(mmprec)-1]/12.0;

hold on
plot(mtime,mmprec,'b','linewidth',2);
plot(years,maprec/12,'r','linewidth',4);
hold off

title('Monthly rainfall NCEP 36N 63W');

print('-dpng','ncep_rain');


%% Print to file
fdir=fullfile(d.plot,'variable',varname);
if ~exist('fdir','dir') system(['mkdir -p ' fdir]); end  
bname=['ncep_timeseries_' varname];
plot_multi_format(gcf,fullfile(fdir,bname));

if nargout>1 basename=fullfile(fdir,bname); end
if nargout>0 retdata=data; end

end















