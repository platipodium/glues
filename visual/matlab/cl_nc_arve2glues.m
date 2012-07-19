function cl_nc_arve2glues(varargin)
% This function takes arve grid cells (and data on it) and projects it onto
% the glues regions

arguments = {...
  {'timestep',1},...
  {'file','../../pop.nc'},...
  {'scenario',''}...
};

cl_register_function;

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length 
  eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); 
end


%% Read results file
if ~exist(file,'file') error('File does not exist'); end
ncid=netcdf.open(file,'NC_NOWRITE');

varname='region'; varid=netcdf.inqVarID(ncid,varname);
reg=netcdf.getVar(ncid,varid);
ireg=find(reg>-1);

[ndim nvar natt udimid] = netcdf.inq(ncid); 
for varid=0:nvar-1
  [varname,xtype,dimids,natts]=netcdf.inqVar(ncid,varid);
  if strcmp(varname,'lat') lat=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'lon') lon=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'latitude') latit=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'longitude') lonit=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'area') area=netcdf.getVar(ncid,varid); end
end

if exist('lat','var') 
  if length(lat)~=(region)
    if exist('latit','var') lat=latit; end
  end
else
  if exist('latit','var') lat=latit; end
end

if exist('lon','var') 
  if length(lon)~=(region)
    if exist('lonit','var') lon=lonit; end
  end
else
  if exist('lonit','var') lon=lonit; end
end

netcdf.close(ncid);

reg=reg(ireg);
lat=lat(ireg);
lon=lon(ireg);


%% Read popregions file
% arvelat is -89.xx .. 89.xx
% arvelon is -179.xx .. 179.xx (col=lat)
% size arveregion is 4320 x 2160 (row=lon)

file='/h/lemmen/projects/glues/tex/2010/holopop/arve/popregions6.nc';
ncid=netcdf.open(file,'NC_NOWRITE');
varid=netcdf.inqVarID(ncid,'z');
arveregion=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'lat');
arvelat=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'lon');
arvelon=netcdf.getVar(ncid,varid);
netcdf.close(ncid);

%% Region region names
file='/h/lemmen/projects/glues/tex/2010/holopop/arve/pop_region_key2.txt';
fid=fopen(file,'r');
C=textscan(fid,'%d %s');
fclose(fid);
arveid=C{1};
arvename=C{2};
arvename{999}='Not_named';
arveid(999)=0;

%% Read GLUES raster
% map.latgrid is 89 . -89
% map.longrid is -179.. 179
% size(map.region) is 360 x 720

load('regionmap_sea_685.mat');

%% For each ARVE region find cells and read GLUES
ar=unique(arveregion);
nland=sum(sum(arveregion>0));
nwater=sum(sum(arveregion<0));

ar=ar(ar>0);
nar=length(ar);
[narow,nacol]=size(arveregion);
nreg=length(region);

debug=0;
if (debug) figure(1); clf reset; end

map.region=zeros(720,360);
for i=1:length(land.region)
    map.region(land.ilon(i),land.ilat(i))=land.region(i);
end
[nrow,ncol]=size(map.region);


g2r_id=zeros(nreg,nar)-NaN;
g2r_ncells=zeros(nreg,nar);

%%
nreg=length(reg);
for ireg=1:nreg
%for ia=213:213 % MAyan America
  [irow,icol,val]=find(map.region==ireg);
  gluesarea(ireg)=sum(calc_gridcell_area(map.latgrid(icol),0.5,0.5));
  
  % irow is lon, icol is lat
  
  iarow0=floor((irow-1)/(nrow*1.0/narow))+3;
  iarow=[iarow0-2 iarow0-1 iarow0 iarow0+1 iarow0+2 iarow0+3];
  iarow=repmat(iarow,6,1);
  iacol0=nacol-floor((icol-1)/(ncol*1.0/nacol));
  iacol=[iacol0; iacol0-1; iacol0-2; iacol0-3; iacol0-4; iacol0-5];
  iacol=repmat(iacol,1,6);
  iarow=reshape(iarow,numel(iarow),1);
  iacol=reshape(iacol,numel(iacol),1);
  % calculate arve regional area before ocean correction
  arvearea(ireg)=sum(calc_gridcell_area(arvelat(iacol),1/12.0,1/12.0));
  nirc=length(iacol);
 
  iv=[];
  for i=1:nirc
    if (arveregion(iarow(i),iacol(i))>0) iv=vertcat(iv,i); end
  end
  
  % convert to GLUES: col->row, reverse lats
  nirc=length(iv);
  arvearea(ireg)=sum(calc_gridcell_area(arvelat(iacol(iv)),1/12.0,1/12.0));

%  for i=1:nirc arveids(i)=arveregion(arvelon(i),arvelat(i)); end
 
  if debug
    clf reset;
    m_proj('miller','lon',...
      [min(arvelon(iarow))-1 max(arvelon(iarow))+1],...
      'lat',[min(arvelat(iacol))-1 max(arvelat(iacol))+1]);
    m_coast;
    m_grid;
    hold on;
    m_plot(arvelon(iarow(iv)),arvelat(iacol(iv)),'r.');
    m_plot(map.longrid(irow),map.latgrid(icol),'b.');
    for i=1:nirc
      
      m_text(arvelon(iarow(iv(i))),arvelat(iacol(iv(i))),num2str(arveregion(iarow(iv(i)),iacol(iv(i)))),...
          'Vertical','middle','Horizontal','center','fontsize',8);
    
      
    end
  end
  
  aid=[];
  for i=1:nirc aid(i)=arveregion(iarow(iv(i)),iacol(iv(i))); end
  uaid=unique(aid);
  g2r_id(ireg,1:length(uaid))=uaid;
  
  for i=1:sum(isfinite(g2r_id(ireg,:)))
    g2r_ncells(ireg,i)=sum(aid==g2r_id(ireg,i));
  end
  
  [gmax,gimax]=max(g2r_ncells(ireg,:));
  iid=find(arveid==uaid(gimax));
  if isempty(iid) iid=999; end
  
  
  fprintf('%3d %s\t%.2f %.2f %.2f\n',ireg,arvename{iid},gluesarea(ireg)/1E3,...
      area(ireg)/1E3,arvearea(ireg)/1E3);
  
end

%save('arveaggregate','-v6','arvedensity','arvesize','gluessize','gluesarea','garea','index','time');


return
end