function cl_nc_albedo_change(varargin)

cl_register_function();

surfacefile='../../data/final_N032_surf_0174.nc';
file='../../plasim_550.nc';

if ~exist(surfacefile,'file') error('Surface file does not exist');  end
if ~exist(file,'file') error('NetCDF file does not exist'); end

gridfile=strrep(file,'.nc','_0.5x0.5.nc');
if ~exist(gridfile,'file') cl_glues2grid('file',file,'res',0.5,...
   'reg','all','var','cropfraction_static','timelim',-2000); end


ncid=netcdf.open(gridfile,'NOWRITE');
varid=netcdf.inqVarID(ncid,'cropfraction_static');
cf=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'lon');
lon=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'lat');
lat=netcdf.getVar(ncid,varid);
netcdf.close(ncid);


system(sprintf('cp %s %s',surfacefile,strrep(surfacefile,'.nc','_change.nc')));
surfacefile=strrep(surfacefile,'.nc','_change.nc');

if ~exist(surfacefile,'file') error('Copy of surface file does not exist');  end

ncid=netcdf.open(surfacefile,'WRITE');
[ndims,nvars,ngatts,unlimdimid] = netcdf.inq(ncid);

for varid=0:nvars-1
  [varname,xtype,dimids,natts] = netcdf.inqVar(ncid,varid);
  %fprintf('%s\n',varname);
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
    case 174, name='albedo'; albedo=value; avarid=varid;
end
nglon=length(glon);
nglat=length(glat);

nlon=length(lon);
nlat=length(lat);
glon180=glon;
glon180(glon>180)=glon180(glon>180)-360;
% for ilon=1:nlon
%   [lmin,imin]=min(abs(glon180-lon(ilon)));
%   iglon(ilon)=imin(1);
% end
% for ilat=1:nlat
%   [lmin,imin]=min(abs(glat-lat(ilat)));
%   iglat(ilat)=imin(1);
% end
lon180=lon;
lon180(lon<0)=lon180(lon<0)+360;

dglon=abs(mean(glon(2:end)-glon(1:end-1)));
dglat=abs(mean(glat(2:end)-glat(1:end-1)));

gcf=albedo*0.0;

for iglon=1:nglon
  ilon=find(abs(lon-glon180(iglon))<=dglon/2);
  if isempty(ilon) continue; end
  for iglat=1:nglat
    ilat=find(abs(lat-glat(iglat))<=dglat/2);
    if isempty(ilat) continue; end
    
    icf = cf(ilon,ilat);
    icf= icf(1:end);
    icf = icf(isfinite(icf));
    if isempty(icf) continue; end
    
    gcf(iglon,iglat,:)=mean(icf);
       
  end
end

% General lighting by 0.05
lighter=albedo.*(1-gcf) + gcf .* (albedo+0.05);

% max(cropfraction) ca 0.18
% Forest-> Steppe transition 0.15->0.20

% Extremely light desert 0.3 assumption
desert=albedo.*(1-gcf) + gcf * 0.3;

netcdf.putVar(ncid,avarid,lighter);
netcdf.close(ncid);


figure(1); clf; hold on;
plot(albedo(1:end),gcf(1:end),'k.');
plot(lighter(1:end),gcf(1:end),'b.');
plot(desert(1:end),gcf(1:end),'r.');


return




 
