function cl_nc_add_albedo(varargin)

cl_register_function();

plasim='../../data/final_N032_surf_0174.nc';
file='../../plasim_550.nc';

if ~exist(plasim,'file') error('plasim file does not exist'); end
if ~exist(file,'file') error('NetCDF file does not exist'); end

ncid=netcdf.open(plasim,'NOWRITE');
[ndims,nvars,ngatts,unlimdimid] = netcdf.inq(ncid);

for varid=0:nvars-1
  [varname,xtype,dimids,natts] = netcdf.inqVar(ncid,varid);
  fprintf('%s\n',varname);
  switch varname
      case 'lat',glat=netcdf.getVar(ncid,varid);
      case 'lon',glon=netcdf.getVar(ncid,varid);
      case 'time',time=netcdf.getVar(ncid,varid);
      otherwise
          value=netcdf.getVar(ncid,varid);
          unit=netcdf.getAtt(ncid,varid,'units');
          longname=netcdf.getAtt(ncid,varid,'long_name');
          code=netcdf.getAtt(ncid,varid,'code');
          type=xtype;
  end
end

switch code
    case 174, name='albedo';
end

nglon=length(glon);
nglat=length(glat);
netcdf.close(ncid);

% Average over time
if exist('time','var')
  value=squeeze(mean(value,3));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Read mapping and convert plasim grid to regions
matfile='regionmap_685.mat';

load(matfile)
if ~exist('region','var') 
  region.length=regionlength;
end

if ~exist('map','var')
    map.region=regionmap;
end

if ~exist('land','var')
    land.region=regionnumber;
    land.map=regionindex;
    land.lat=lat;
    land.lon=lon;
end

nreg=length(region.length);
[cols,rows]=size(map.region);


glon1=find(glon<=180);
glon2=find(glon>180);
glon=[glon(glon2)-360; glon(glon1)];
gvalue=[value(glon2,:); value(glon1,:)];
glat=flipud(glat);

debug=1;

val=zeros(nreg,1)+NaN;
for ireg=1:-nreg
  % select all cells of this region  
  
  iselect=find(land.region == ireg);
  nselect=length(iselect);
  if nselect<1 error('Something is wrong here, no cells with region'); end

  [ilon,ilat]=regidx2geoidx(land.map(iselect),cols);
  iclon=ceil(ilon/cols*nglon);
  iclat=ceil((361-ilat)/rows*nglat);
  ind=sub2ind(size(gvalue),iclon,iclat);
  
%  val(ireg)=calc_geo_mean(land.lat(iselect),diag(squeeze(gvalue(iclon,iclat))));
   val(ireg)=calc_geo_mean(land.lat(iselect),gvalue(ind));
   if mod(nreg,25)==0 fprintf('%d ',nreg); end
  
   if debug
      figure(1); clf reset;
      latlim=[min([land.lat(ilat);glat(iclat)])-1,max([land.lat(ilat);glat(iclat)])+1];
      lonlim=[min([land.lon(ilon);glat(iclon)])-1,max([land.lon(ilon);glon(iclon)])+1];
      
      m_proj('miller','lat',latlim,'lon',lonlim);
      m_grid;
      hold on;
      m_coast;
      m_plot(land.lon(ilon),land.lat(ilat),'r.');
      m_plot(glon(iclon),glat(iclat),'ms');
       
       
   end
end
load('region_albedo.mat');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Write information to new netcdf
ncid=netcdf.open(file,'WRITE');
rdimid=netcdf.inqDimID(ncid,'region');

[ndims,nvars,ngatts,unlimdimid] = netcdf.inq(ncid);
for varid=0:nvars-1
  [varname,xtype,dimids,natts] = netcdf.inqVar(ncid,varid);
  if strcmp(varname,name) break; end
end

if ~strcmp(varname,name)
  netcdf.reDef(ncid);
  varid=netcdf.defVar(ncid,name,type,rdimid);
  netcdf.putAtt(ncid,varid,'long_name',longname);
  netcdf.putAtt(ncid,varid,'code',code);
  netcdf.putAtt(ncid,varid,'units',unit);
  netcdf.endDef(ncid);
end

netcdf.putVar(ncid,varid,val);

name='albedo_lu';
longname='albedo_under_landuse';

varid=netcdf.inqVarID(ncid,'time');
time=netcdf.getVar(ncid,varid);
itime=find(time==-2000);
varid=netcdf.inqVarID(ncid,'cropfraction_static');
cropfraction=netcdf.getVar(ncid,varid);
cropfraction=squeeze(cropfraction(:,itime));

for varid=0:nvars-1
  [varname,xtype,dimids,natts] = netcdf.inqVar(ncid,varid);
  if strcmp(varname,name) break; end
end

if ~strcmp(varname,name)
  netcdf.reDef(ncid);
  varid=netcdf.defVar(ncid,name,type,rdimid);
  netcdf.putAtt(ncid,varid,'long_name',longname);
  netcdf.putAtt(ncid,varid,'units',unit);
  netcdf.endDef(ncid);
end

value=cropfraction*0.05+val;
netcdf.putVar(ncid,varid,value);

netcdf.close(ncid);


return




 
