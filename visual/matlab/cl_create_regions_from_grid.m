function cl_create_regions_from_grid(varargin)
% cl_create_regions(varargin
%   keywords latlim, lonlim, res
%   depends on read_gluesclimate
%   requires cl_register_functino, clp_arguments, clp_valuestring

cl_register_function;

%  {'latlim',[15 50]},...
%  {'lonlim',[90 130]},...
arguments = {...
  {'latlim',[48 60]},...
  {'lonlim',[-10 2]},...
  {'res',0.5},...
};

[args,rargs]=clp_arguments(varargin,arguments);
for i=1:args.length   
  eval([ args.name{i} ' = ' clp_valuestring(args.value{i}) ';']); 
end

[time,lon,lat,climate]=cl_nc_read_arve();
ilon=find(lon>=lonlim(1) & lon<=lonlim(2));
ilat=find(lat>=latlim(1) & lat<=latlim(2));
nlon=length(ilon);
nlat=length(ilat);

npp=climate.npp(ilon,ilat);
gdd0=climate.gdd0(ilon,ilat);
npp(npp<0)=NaN;

if any(ilon==1) & any(ilon==length(lon))
  error('Please implement this round-trip');
end



figure(1); clf reset;
m_proj('miller','lon',lonlim,'lat',latlim);
m_coast;
m_grid;


iland=find(isfinite(npp));
regiongrid=npp+NaN;
latgrid=repmat(lat(ilat)',[nlon 1]);
longrid=repmat(lon(ilon),[1, nlat]);
cc=1:length(iland);
regiongrid(iland)=cc;

lon=lon(ilon); lat=lat(ilat);
m_pcolor(lon,lat,double(regiongrid)');

clat=latgrid(iland);
clon=longrid(iland);
ilat=(clat-min(min(latgrid)))*2+1;
ilon=(clon-min(min(longrid)))*2+1;

nn=cc+NaN;
in=find(clat<latlim(2));
nn(in)=diag(regiongrid(ilon(in),ilat(in)+1));
ss=cc+NaN;
in=find(clat>latlim(1));
ss(in)=diag(regiongrid(ilon(in),ilat(in)-1));
ee=cc+NaN;
in=find(clon<lonlim(2));
ee(in)=diag(regiongrid(ilon(in)+1,ilat(in)));
ww=cc+NaN;
in=find(clon>lonlim(1));
ww(in)=diag(regiongrid(ilon(in)-1,ilat(in)));
ne=cc+NaN;
in=find(clon<lonlim(2) & clat<latlim(2));
ne(in)=diag(regiongrid(ilon(in)+1,ilat(in)+1));
se=cc+NaN;
in=find(clon<lonlim(2) & clat>latlim(1));
se(in)=diag(regiongrid(ilon(in)+1,ilat(in)-1));
sw=cc+NaN;
in=find(clon>lonlim(1) & clat>latlim(1));
sw(in)=diag(regiongrid(ilon(in)-1,ilat(in)-1));
nw=cc+NaN;
in=find(clon>lonlim(1) & clat<latlim(2));
nw(in)=diag(regiongrid(ilon(in)-1,ilat(in)+1));


   
neigh=zeros(length(cc),100)+NaN;
%neigh(:,1:8)=[ww,nw,nn,ne,ee,se,ss,sw];
neigh(:,1:4)=[nn',ee',ss',ww'];
nneigh=sum(isfinite(neigh),2);

ilat=round(180-2*clat);
ilon=round(360+2*clon);
n=length(ilat);

area=calc_gridcell_area(clat);
border=area*0+1;


%% Convert everything to zero-based
cc=cc-1;
neigh=neigh-1;


infix=sprintf('%.1f_grid_china',res);

tsvfile=sprintf('regions_%s.tsv',infix);
fid=fopen(tsvfile,'wt');
for i=1:n 
    fprintf(fid,'%05d %5d %7d %4d %4d %3d',cc(i),1,round(area(i)),...
    ilon(i),ilat(i),nneigh(i));
    ifn=find(isfinite(neigh(i,:)));
    for ineigh=1:nneigh(i)
        %fprintf(fid,'\t%d:%d:%d',neigh(i,ifn(ineigh)),border(i),1);
        fprintf(fid,'\t%d:%d',neigh(i,ifn(ineigh)),border(i));
    end
    fprintf(fid,'\n');
end
fclose(fid);


%% Save regionpath structure
pathfile=sprintf('regionpath_%s.mat',infix);
nreg=n;
regionlat=clat;
regionlon=clon;
regionneighbours=nneigh;
regionneighbourhood=neigh;
regioncenter=[clon clat];
regionpath=zeros(n,5,3);
regionpath(:,:,1)=repmat(clon,1,5)+repmat([-1 -1 1 1 -1]*res*0.5,n,1);
regionpath(:,:,2)=repmat(clat,1,5)+repmat([-1 1 1 -1 -1]*res*0.5,n,1);
regionpath(:,:,3)=[neigh(:,1:4) neigh(:,1) ];
save(pathfile,'nreg','regionpath','regionneighbourhood',...
    'regionneighbours','regioncenter','regionlat','regionlon');


%% Save climate parameter files
v=cl_get_version;
nppfile=sprintf('regionnpp_%s.tsv',infix);
fid=fopen(nppfile,'wt');
fprintf(fid,'# ASCII data info: columns\n');
fprintf(fid,'# 1. region id 2. number of climates,\n');
fprintf(fid,'# 3..n npp\n');
fprintf(fid,'# Version info: %s\n',struct2stringlines(v));
fprintf(fid,'%04d %03d %4d\n',[cc',cc'*0+1,npp(iland)]);
fclose(fid);



%% Save climate parameter files
GDDMAX=5000;
gdd=gdd0;
gdd(gdd>GDDMAX)=GDDMAX;
gdd=gdd/GDDMAX*360;
gdd(gdd<0)=NaN;

gddfile=sprintf('regiongdd_%s.tsv',infix);
fid=fopen(gddfile,'wt');
fprintf(fid,'# ASCII data info: columns\n');
fprintf(fid,'# 1. region id 2. number of climates,\n');
fprintf(fid,'# 3..n gdd\n');
fprintf(fid,'# Version info: %s\n',struct2stringlines(v));
fprintf(fid,'%04d %03d %4d\n',[cc',cc'*0+1,round(gdd(iland))]);
fclose(fid);

% Control plots
m_pcolor(lon,lat,double(regiongrid)'); hold on; m_grid; m_coast; hold off;
cl_print('name',sprintf('regions_%s',infix),'ext','pdf');
m_pcolor(lon,lat,double(npp)'); colorbar; hold on; m_grid; m_coast; hold off;
cl_print('name',sprintf('regionnpp_%s',infix),'ext','pdf');
m_pcolor(lon,lat,double(gdd)'); colorbar; hold on; m_grid; m_coast; hold off;
cl_print('name',sprintf('regiongdd_%s',infix),'ext','pdf');


return;

simgrid=regiongrid;

m_pcolor(lon,lat,double(simgrid)');
colormap((jet));

diff=cc'*0;
for i=1:max(nneigh)
  iv=find(isfinite(neigh(:,i))); 
  diff(iv)=diff(iv)+(npp(iland(neigh(iv,i)))-npp(iland(iv))).^2 ;
end

diff=sqrt(diff)./nneigh;

[sdiff,isort]=sort(diff);
for j=1:100
  i=cc(isort(j));
  isf=find(isfinite(neigh(i,:)) & neigh(i,:)>0);
  jn=neigh(i,isf);
  cc(jn)=i;
  icells=find(cc==i);
  jneigh=unique(neigh(jn,:));
  jneigh=jneigh(find(jneigh~=i & isfinite(jneigh)));
  for k=[jn]
    neigh(find(neigh==k))=i;
  end
  for k=icells
    neigh(k,:)=NaN;
    neigh(k,1:length(jneigh))=jneigh;
  end
  nneigh(icells)=sum(isfinite(neigh(i,:)));
  npp(icells)=mean(npp(icells));
  hold off;
  simgrid(iland)=cc;
  m_pcolor(lon,lat,double(simgrid)');
  
end

