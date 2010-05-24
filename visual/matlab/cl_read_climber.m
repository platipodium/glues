function cl_read_climber
%CL_READ_CLIMBER  Converts CLIMBER database to mat and netcdf
%  CL_READ_CLIMBER converts the .grd ascii files from the CLIMBER model to
%  Matlab .mat files and NetCDF format
%
%  two local files climber.mat and climber.nc are created
% 
%  See also CL_READ_IIASA

% Copyright 2010 Carsten Lemmen <carsten.lemmen@gkss.de>

cl_register_function;

filename='data/tran.dat';

if ~exist(filename,'file');
  error('Could not find climber data file ''tran.dat''');
end

%   /* ========== GRID DESCRIPTION ====================================
%    70      | LX      | longitudinal dimension
%    36      | LY      | latitudinal dimension
%    5.14285 | dxt     | longitudinal step (deg)
%    5.      | dyt     | latitudinal step (deg)
%    -177.42857  | sxt     | longitude of i=1
%    87.5    | syt     | latitude of j=1 (positive !)
%    Data is 4-Byte BIG_ENDIAN
%   */
% 

fid=fopen(filename,'r','b');
data=fread(fid,inf,'float32=>single');
fclose(fid);

ndata=length(data);
nlat=36;
nlon=70;
nm=12;
nvar=3;
ny=ndata/(nlat*nlon*nm*nvar);


lat=fliplr(87.5-[0:(nlat-1)]*180.0/nlat);
lon=-177.42857+[0:(nlon-1)]*360.0/nlon;


%climate=reshape(data,ny,nm,nvar,nlat,nlon);
climate=reshape(data,nlon,nlat,nvar,nm,ny);
temp=squeeze(climate(:,:,1,:,:));
prec=squeeze(climate(:,:,2,:,:));
npp=squeeze(climate(:,:,3,:,:));

npp(npp>9000)=NaN;

atemp=double(squeeze(mean(temp,3)));
aprec=double(squeeze(sum(temp,3)));
anpp=double(squeeze(mean(npp,3)));


%% reshape data

%vars=data(1:3*nlat*nlon*nm);
%var=reshape(vars,nlon,nlat,nvar,nm);

%prec=double(squeeze(var(:,:,2,:)));
%temp=double(squeeze(var(:,:,1,:)));
%npp=double(squeeze(var(:,:,3,:)));

figure(1);
clf reset;
m_proj('miller');
m_coast; hold on;

for m=1:20:ny 
 p=m_pcolor(lon,lat,squeeze(anpp(:,:,m))'); 
 pause(0.03);
end

figure(2);
clf reset;
hold on;
pcolor(1:ny,lat,(squeeze(mean(aprec,1))));


d=aprec;
figure(3);
clf reset;
hold on;
plot(1:ny,squeeze(mean(mean(d,2),1)),'b-');
plot(1:ny,squeeze(min(min(d))),'b-');
plot(1:ny,squeeze(max(max(d))),'b-');


return
  
save('-v6','climber',parameters{:},'lon','lat');

nid=length(lat);

if (1)
  ncid=netcdf.create('climber.nc','NC_WRITE');
  mondim=netcdf.defDim(ncid,'month',12);
  netcdf.defVar(ncid,'month','NC_BYTE',mondim);
  iddim=netcdf.defDim(ncid,'id',nid);
  netcdf.defVar(ncid,'id','NC_INT',iddim);
  latid=netcdf.defVar(ncid,'lat','NC_FLOAT',iddim);
  netcdf.putAtt(ncid,latid,'Description','Latitude (centered) of land grid cell');
  lonid=netcdf.defVar(ncid,'lon','NC_FLOAT',iddim);
  netcdf.putAtt(ncid,lonid,'Description','Longitude (centered) of land grid cell');

  for ip=1:np
    netcdf.defVar(ncid,parameters{ip},'NC_FLOAT',[iddim,mondim]);
  end
  
  netcdf.endDef(ncid);
  
  monid=netcdf.inqVarID(ncid,'month');
  netcdf.putVar(ncid,monid,[1:12]);
  
  idid=netcdf.inqVarID(ncid,'id');
  netcdf.putVar(ncid,idid,[1:nid]);
  
  varid=netcdf.inqVarID(ncid,'lat');
  netcdf.putVar(ncid,varid,lat);
  varid=netcdf.inqVarID(ncid,'lon');
  netcdf.putVar(ncid,varid,lon);
  
  
  for ip=1:np
    par=parameters{ip};
    parid=netcdf.inqVarID(ncid,par); 
    eval(['parval = ' par ';']);
    netcdf.putVar(ncid,parid,parval);
  end
  
  netcdf.close(ncid);
end

return;
end
