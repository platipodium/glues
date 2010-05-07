function nc_pangaea

 
input_filename='../../src/test/pangaea_reg.nc';
region_filename='../../src/test/glues_map_dim.nc';
output_filename='pangaea.nc';
  
ncin =netcdf.open(input_filename,'NC_NOWRITE');
ncmap=netcdf.open(region_filename,'NC_NOWRITE');
ncfile=netcdf.create(output_filename,'NC_SHARE');

timestring=datestr(now);

%Create dimensions, CF-conventions desires T,Z,Y,X (time,altitude,latitude,longitude)
dimid=netcdf.inqDimId(ncmap,'lon');
[dummy,nlon]=netcdf.inqDim(ncmap,dimid);
londim=netcdf.defDim(ncfile,'lon',nlon);

dimid=netcdf.inqDimId(ncmap,'lat');
[dummy,nlat]=netcdf.inqDim(ncmap,dimid);
latdim=netcdf.defDim(ncfile,'lat',nlat);

timedim=netcdf.defDim(ncfile,'time',netcdf.getConstant('NC_UNLIMITED'));

%% Copy global attributes
varid=netcdf.getConstant('NC_GLOBAL');
[ndims,nvars,numatts,unlimdimid]=netcdf.inq(ncin);

for i=0:numatts-1
  attname=netcdf.inqAttName(ncin,varid,i);
  netcdf.copyAtt(ncin,varid,attname,ncfile,varid);
end
netcdf.putAtt(ncfile,varid,'modification_date',timestring);
netcdf.putAtt(ncfile,varid,'filenames_input',[input_filename ', ' region_filename]);
netcdf.putAtt(ncfile,varid,'filenames_output',[output_filename]);

%% Copy time dimension and variable from ncin
ivarid=netcdf.inqVarId(ncin,'time');
[varname, xtype, dimids, numatts]=netcdf.inqVar(ncin,ivarid);
varid=netcdf.defVar(ncfile,'time',xtype,timedim);
for i=0:numatts-1
  attname=netcdf.inqAttName(ncin,ivarid,i);
  netcdf.copyAtt(ncin,ivarid,attname,ncfile,varid);
end
time=netcdf.getVar(ncin,ivarid);
timeid=varid;
ntime=length(time);

%% Copy lat lon from ncmap
ivarid=netcdf.inqVarId(ncmap,'lat');
[varname, xtype, dimids, numatts]=netcdf.inqVar(ncmap,ivarid);
varid=netcdf.defVar(ncfile,'lat',xtype,latdim);
for i=0:numatts-1
  attname=netcdf.inqAttName(ncmap,ivarid,i);
  netcdf.copyAtt(ncmap,ivarid,attname,ncfile,varid);
end
lat=netcdf.getVar(ncmap,ivarid);
latid=varid;
nlat=length(lat);

ivarid=netcdf.inqVarId(ncmap,'lon');
[varname, xtype, dimids, numatts]=netcdf.inqVar(ncmap,ivarid);
varid=netcdf.defVar(ncfile,'lon',xtype,londim);
for i=0:numatts-1
  attname=netcdf.inqAttName(ncmap,ivarid,i);
  netcdf.copyAtt(ncmap,ivarid,attname,ncfile,varid);
end
lon=netcdf.getVar(ncmap,ivarid);
lonid=varid;
nlon=length(lon);

%% Copy id from ncmap, make all sea NaN
ivarid=netcdf.inqVarId(ncmap,'id');
map=netcdf.getVar(ncmap,ivarid);
map(map<0)=NaN;

ivarid=netcdf.inqVarId(ncin,'region');
[varname, xtype, dimids, numatts]=netcdf.inqVar(ncin,ivarid);
varid=netcdf.defVar(ncfile,varname,xtype,[londim,latdim]);
for i=0:numatts-1
  attname=netcdf.inqAttName(ncin,ivarid,i);
  netcdf.copyAtt(ncin,ivarid,attname,ncfile,varid);
end
mapid=varid;


%% Copy pop/tech/farm from ncin
ivarid=netcdf.inqVarId(ncin,'population_density');
pid=ivarid;
if (0)
[varname, xtype, dimids, numatts]=netcdf.inqVar(ncin,ivarid);
varid=netcdf.defVar(ncfile,varname,xtype,[londim,latdim,timedim]);
for i=0:numatts-1
  attname=netcdf.inqAttName(ncin,ivarid,i);
  netcdf.copyAtt(ncin,ivarid,attname,ncfile,varid);
end
netcdf.putAtt(ncfile,varid,'modification_date',timestring);
end

ivarid=netcdf.inqVarId(ncin,'technology');
tid=ivarid;
if(1)
[varname, xtype, dimids, numatts]=netcdf.inqVar(ncin,ivarid);
varid=netcdf.defVar(ncfile,varname,xtype,[londim,latdim,timedim]);
for i=0:numatts-1
  attname=netcdf.inqAttName(ncin,ivarid,i);
  netcdf.copyAtt(ncin,ivarid,attname,ncfile,varid);
end
netcdf.putAtt(ncfile,varid,'modification_date',timestring);
end

ivarid=netcdf.inqVarId(ncin,'economies');
eid=ivarid;
if (0)
[varname, xtype, dimids, numatts]=netcdf.inqVar(ncin,ivarid);
varid=netcdf.defVar(ncfile,varname,xtype,[londim,latdim,timedim]);
for i=0:numatts-1
  attname=netcdf.inqAttName(ncin,ivarid,i);
  netcdf.copyAtt(ncin,ivarid,attname,ncfile,varid);
end
netcdf.putAtt(ncfile,varid,'modification_date',timestring);
end


ivarid=netcdf.inqVarId(ncin,'farming');
[varname, xtype, dimids, numatts]=netcdf.inqVar(ncin,ivarid);
varid=netcdf.defVar(ncfile,varname,xtype,[londim,latdim,timedim]);
for i=0:numatts-1
  attname=netcdf.inqAttName(ncin,ivarid,i);
  netcdf.copyAtt(ncin,ivarid,attname,ncfile,varid);
end
netcdf.putAtt(ncfile,varid,'modification_date',timestring);
fid=ivarid;

%% Get Region ids, make all ids < 0 equal to -1
varid=netcdf.inqVarId(ncin,'region');
region=netcdf.getVar(ncin,varid);
nreg=length(region);


load('hyde_glues_cropfraction');
htime=-9500:20:2000;
for i=1:ntime
  it=find(htime>=-9500+(i-1)*50 & htime < -9500+i*50);
  if isempty(it) 
    crop(:,i)=zeros(nreg,1)+NaN;
    deforest(:,i)=zeros(nreg,1)+NaN;
  else
    crop(:,i)=mean(cropfraction(:,it),2);
    deforest(:,i)=mean(deforestation(:,it),2);
  end
end
crop=crop*100; % Convert to pertenthousand
deforest=deforest/10; % Convert from t/ha to kg/m2

varid=netcdf.inqVarId(ncfile,'farming');
netcdf.putAtt(ncfile,varid,'units','%');

varid=netcdf.defVar(ncfile,'crop_fraction','NC_FLOAT',[londim,latdim,timedim]);
netcdf.putAtt(ncfile,varid,'creation_date',timestring);
netcdf.putAtt(ncfile,varid,'long_name','crop_fraction');
netcdf.putAtt(ncfile,varid,'units','%');
netcdf.putAtt(ncfile,varid,'valid_min',0);
netcdf.putAtt(ncfile,varid,'valid_max',1);
netcdf.putAtt(ncfile,varid,'description','Fraction of grid cell used for crops');
netcdf.putAtt(ncfile,varid,'coordinates','time lon lat');

varid=netcdf.defVar(ncfile,'deforestation','NC_FLOAT',[londim,latdim,timedim]);
netcdf.putAtt(ncfile,varid,'creation_date',timestring);
netcdf.putAtt(ncfile,varid,'long_name','accumulated_deforestation');
netcdf.putAtt(ncfile,varid,'units','kg C m^{-2}');
netcdf.putAtt(ncfile,varid,'reference_year',time(1)-22.5);
netcdf.putAtt(ncfile,varid,'description','Accumulated deforestation since reference year');
netcdf.putAtt(ncfile,varid,'coordinates','time lon lat');

% End define mode and put variables
netcdf.endDef(ncfile);

pop =netcdf.getVar(ncin,pid);
tech=netcdf.getVar(ncin,tid);
farm=netcdf.getVar(ncin,fid);
farm=farm*100; % Convert to % 
econ=netcdf.getVar(ncin,eid);

netcdf.putVar(ncfile,latid,lat);
netcdf.putVar(ncfile,lonid,lon);
map=map';
netcdf.putVar(ncfile,mapid,map);

% Empty arrays.
fmap=zeros(nlon,nlat)-NaN;
tmap=fmap;
pmap=fmap;
emap=fmap;
cmap=fmap;
dmap=fmap;
%pid=netcdf.inqVarId(ncfile,'population_density');
tid=netcdf.inqVarId(ncfile,'technology');
%eid=netcdf.inqVarId(ncfile,'economies');
fid=netcdf.inqVarId(ncfile,'farming');
cid=netcdf.inqVarId(ncfile,'crop_fraction');
did=netcdf.inqVarId(ncfile,'deforestation');


time=time+2.5; % Offset the non-centered averaging in pangaea.sh

for itime=1:ntime
  fprintf('Time %d (%.0f) ..\n',itime, time(itime));
  for ireg=0:nreg-1
    imap=find(map==ireg);
    fmap(imap)=farm(ireg+1,itime);
    tmap(imap)=tech(ireg+1,itime);
    pmap(imap)=pop(ireg+1,itime);
    emap(imap)=econ(ireg+1,itime);
    cmap(imap)=crop(ireg+1,itime);
    dmap(imap)=deforest(ireg+1,itime);
  end
  netcdf.putVar(ncfile,fid,[0,0,itime-1],[nlon,nlat,1],fmap);
  netcdf.putVar(ncfile,tid,[0,0,itime-1],[nlon,nlat,1],tmap);
  %netcdf.putVar(ncfile,eid,[0,0,itime-1],[nlon,nlat,1],emap);
  %netcdf.putVar(ncfile,pid,[0,0,itime-1],[nlon,nlat,1],pmap);
  netcdf.putVar(ncfile,cid,[0,0,itime-1],[nlon,nlat,1],cmap);
  netcdf.putVar(ncfile,did,[0,0,itime-1],[nlon,nlat,1],dmap);
  netcdf.putVar(ncfile,timeid,[itime-1],time(itime));
end


%% Clean up
netcdf.close(ncin);
netcdf.close(ncmap);
netcdf.close(ncfile);


return
end



