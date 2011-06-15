function cl_nc_writeclimate(varargin)

% This function takes gridded data and maps them to 
% a glues mapping (with regions as coordinate)

arguments = {...
  {'timelim',[-inf,inf]},...
  {'variables',{'npp','gdd'}},...
  {'file','../../data/plasim_11k_vecode_685.nc'},...
};

cl_register_function;

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length 
  lv=length(a.value{i});
  if (lv>1 & iscell(a.value{i}))
    for j=1:lv
      eval( [a.name{i} '{' num2str(j) '} = ''' char(clp_valuestring(a.value{i}(j))) ''';']);         
    end
  else
    eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); 
  end
end

cl_register_function();


variables={'gdd','npp'};
v=cl_get_version;

ncid=netcdf.open(file,'NC_NOWRITE');

for i=1:length(variables);
  varname=variables{i};
  varid=netcdf.inqVarID(ncid,varname);
  [varname,xtype,dimids,natt] = netcdf.inqVar(ncid,varid);
  value=netcdf.getVar(ncid,varid);
  value(isnan(value))=0;
  value=double(value);
  
  regdimid=netcdf.inqDimID(ncid,'region');
  [regname,nreg]=netcdf.inqDim(ncid,regdimid);
  timedimid=netcdf.inqDimID(ncid,'time');
  [timename,ntime]=netcdf.inqDim(ncid,timedimid);
  varid=netcdf.inqVarID(ncid,'time');
  time=netcdf.getVar(ncid,varid);
  varid=netcdf.inqVarID(ncid,'region');
  region=netcdf.getVar(ncid,varid);
  
  if dimids==[timedimid regdimid] value=value'; end
  
  txtfile=strrep(file,'.nc',['_' varname '.tsv']);
  fid=fopen(txtfile,'w');
  fprintf(fid,'# ASCII data info: columns\n');
  fprintf(fid,'# 1. region id 2. number of climates,\n');
  fprintf(fid,'# 3..n %s from %s\n',varname,file);
  fprintf(fid,'# Version info: %s\n',struct2stringlines(v));

  for ireg=1:nreg 
    fprintf(fid,'%04d %03d',region(ireg),ntime);
    fprintf(fid,' %4d',round(value(ireg,:)));
    fprintf(fid,'\n');
  end
  fclose(fid);
end

return;
  
