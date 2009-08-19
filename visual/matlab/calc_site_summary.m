function calc_site_summary(fmin,fmax,year,ratio,dyear,extra)


if ~exist('year','var') year=5.5; end
if ~exist('dyear','var') dyear=2.0; end
if ~exist('ratio','var') ratio=33; end
if ~exist('fmin','var') fmin=200; end
if ~exist('fmax','var') fmax=1800; end

yrtext=sprintf('%.1f_%.1f',year,dyear);

if exist('extra','var') yrtext=[yrtext '_' extra]; end

matfile=['replacemany_' yrtext '_' num2str(ratio) '.mat'];

if ~exist(matfile,'file') 
    fprintf('Required file %s does not exist.',matfile);
    fprintf('Please copy or recreate with calc_replacemany.m.' );
    return; end;
load(matfile);
r=rmdata;

n=length(r.lat);
lim=90;
r.lat=max([min([r.lat;zeros(1,n)+lim]);zeros(1,n)-lim]);

%valid=find((r.Freq>=fmin | r.Freq==0) & r.Freq<=fmax & ~isnan(r.lat) ...
valid=find(r.Freq>=fmin & r.Freq<=fmax & ~isnan(r.lat)  & r.No_sort<500 ...
);
nvalid=length(valid);

invalid=find((r.Freq<fmin | r.Freq>fmax) & ~isnan(r.lat) & r.No_sort<500 ...
);
ninvalid=length(invalid);

site=r.Site(valid);
f=r.Freq(valid);
fmin=min(f);
lat=r.lat(valid);
lon=r.lon(valid);
isupp=r.isupp(valid);
islow=r.islow(valid);
istot=r.istot(valid);

description=site;

[llu,ai,bi]=unique(description);

nu=length(ai);

lon=lon(ai);
lat=lat(ai);
ll=[lon;lat]';
%[x,y]=m_ll2xy(lon,lat);

%[lon,lat]=m_xy2ll(x,y);

description=description(ai);
no=r.No_sort(valid(ai));

for i=1:nu
  isel=find(bi==i);
  upp(i)=sum(isupp(isel));
  low(i)=sum(islow(isel));
  tot(i)=sum(istot(isel));
end


v=struct2cell(get_version());
vtext=v{1};
for i=2:length(v)
  vtext=[vtext ' ' v{i}];
end


ofile=strrep(matfile,'.mat','_site_summary.tsv');
fid=fopen(ofile,'w');

fprintf(fid,'%% Version information:\n%%   %s\n',vtext);

fprintf(fid,'%% Number of significant frequencies in lower/upper/total Holocene\n');
fprintf(fid,'%% No_sort site lon lat nlow nupp ntot\n');

for i=1:nu
fprintf(fid,'%d "%s" %f %f %d %d %d\n',no(i),description{i},lon(i),lat(i),low(i),upp(i),tot(i));
end

fclose(fid);






