function cl_read_iiasa
%CL_READ_IIASA   Converts IIASA database to mat and netcdf
%  CL_READ_IIASA converts the .grd ascii files from the IIASA database to
%  Matlab .mat files and NetCDF format
%
%  two local files iiasa.mat and iiasa.nc are created
% 
%  See also CL_GET_IIASA

% Copyright 2009 Carsten Lemmen <carsten.lemmen@gkss.de>

cl_register_function;

parameters={'tmean','prec'};
np=length(parameters);

for ip=1:np
  par=parameters{ip};
  filename =  ['iiasa_' par '.grd'];
  if ~exist(filename,'file');
    cl_get_iiasa;
  end
  if ~exist(filename,'file');
      error('Cannot find IIASA data file');
  end
  
  eval([par '=load(filename,''-ascii'');']);
  
  if (ip==1)
    % Data is lower-left coded, change to center
    eval(['lon=' par '(:,1)+0.25;']); 
    eval(['lat=' par '(:,2)+0.25;']); 
  end
  
  eval([par '= ' par '(:,3:end);']);
  
end
  
save('-v6','iiasa',parameters{:},'lon','lat');

nid=length(lat);

if (1)
  ncid=netcdf.create('iiasa.nc','NC_WRITE');
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
