function cl_def_clustervalue(filename,varname)
%CL_DEF_CLUSTERVALUE  Defines which variable/data set is used for clustring
%  CL_DEF_CLUSTERVALUE(FILENAME,VARNAME) selects from the data set in 
%  FILENAME the variable VARNAME which will be used for subsequent clustering
%
%  Default values are to take npp from IIASA variable
%
%  A file clustervalue.mat is produced
%  
%  See also CL_READ_IIASA, CL_CREATE_CLUSTER, CL_CREATE_REGIONS

% Copyright 2009 Carsten Lemmen <carsten.lemmen@gkss.de>

cl_register_function;

if ~exist('filename','var') filename='iiasa.mat'; end
if ~exist('varname','var')  varname='npp'; end

if ~exist(filename,'file')
    error('Cannot read file');
end

data=load(filename);
lon=data.lon;
lat=data.lat;
if exist(['data.' varname],'var')
    value=eval(['data.' varname]); 
elseif (strcmp(varname,'npp'))
    temp=mean(data.tmean,2);
    prec=sum(data.prec,2);
    value=clc_npp(temp,prec);
else 
    error('I don''t know how to handle this variable name');
end

save('-v6','clustervalue','lon','lat','value');

return

end