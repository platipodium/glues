function read_plasim_example

cl_register_function();

clear all
mdir='/h/lemmen/data/plasim';

pmask='finalymprecip';
tmask='ymT2m';
nmask='ymNPP';

m=[1:12];

for im=m
    mstr(im,:)=sprintf('%02d',m(im));
    files{im}=fullfile(mdir,[pmask mstr(im,:) '.nc']);
    files{im+12}=fullfile(mdir,[tmask mstr(im,:) '.nc']);
    files{im+24}=fullfile(mdir,[nmask mstr(im,:) '.nc']);
end

ncid=netcdf.open(files{1},'NC_NOWRITE');
[ndim nvar natt udimid] = netcdf.inq(ncid);

delete('plasim_klima.nc');
ncout=netcdf.create('plasim_klima.nc','NC_SHARE');

% Copy dimensions
for idim=0:ndim-1
  [dimname, dimlen] = netcdf.inqDim(ncid,idim);
  switch(dimname)
    case 'time'
      netcdf.defDim(ncout,dimname,12);
      %  netcdf.defDim(ncout,dimname,netcdf.getConstant('NC_UNLIMITED'));
    case 'x'
      netcdf.defDim(ncout,'lon',dimlen);
    case 'y' 
      netcdf.defDim(ncout,'lat',dimlen);
    otherwise
    netcdf.defDim(ncout,dimname,dimlen);  
  end
end;

% Copy global attributes
for iatt=0:natt-1
  attname = netcdf.inqattname(ncid,netcdf.getConstant('NC_GLOBAL'),iatt);
  netcdf.copyAtt(ncid,netcdf.getConstant('NC_GLOBAL'),attname,ncout,netcdf.getConstant('NC_GLOBAL'));
end

% Copy variables
for ivar=0:nvar-1
  [varname,xtype,dimids,natt] = netcdf.inqVar(ncid,ivar);
  varid = netcdf.defVar(ncout,varname,xtype,dimids);
  
  for iatt=0:natt-1
    attname = netcdf.inqAttName(ncid,varid,iatt);
    netcdf.copyAtt(ncid,varid,attname,ncout,varid);
  end
end
netcdf.close(ncid);

for infix={pmask,tmask,nmask}
  file=fullfile(mdir,[char(infix) '01.nc']);
  if ~exist(file,'file') continue; end
  
  ncid=netcdf.open(file,'NC_NOWRITE');
  [ndim nvar natt udimid] = netcdf.inq(ncid); 
  
  for ivar=0:nvar-1
    [varname,xtype,dimids,natt] = netcdf.inqVar(ncid,ivar);
    try
      ovar=netcdf.inqVarID(ncout,varname);
      continue;
    catch ('MATLAB:netcdf:inqVarID:variableNotFound');
    end
    varid = netcdf.defVar(ncout,varname,xtype,dimids);
  
    for iatt=0:natt-1
      attname = netcdf.inqAttName(ncid,varid,iatt);
      netcdf.copyAtt(ncid,varid,attname,ncout,varid);
    end
  end
  netcdf.close(ncid);
end

[ndim nvar natt udimid] = netcdf.inq(ncout);


for ivar=0:nvar-1
  [varname,xtype,dimids,natt] = netcdf.inqVar(ncout,ivar);

  switch(varname)
    case 'time', timeid=ivar; continue;
    case 'var142', pvarid=ivar; netcdf.renameVar(ncout,ivar,'P');
    case 'var167', tvarid=ivar; netcdf.renameVar(ncout,ivar,'T');
    case 'var301', nvarid=ivar; netcdf.renameVar(ncout,ivar,'NPP');
    otherwise,
       error('Variable code not defined');
  end
end

NC_GLOBAL=netcdf.getConstant('NC_GLOBAL');
netcdf.putAtt(ncout,NC_GLOBAL,'data_origin','Kerstin Haberkorn');
netcdf.putAtt(ncout,NC_GLOBAL,'data_user','Carsten Lemmen');

netcdf.putAtt(ncout,timeid,'units','Month of the year')
netcdf.putAtt(ncout,timeid,'description','Time within climatological year of PlaSim 50-year control run')
netcdf.putAtt(ncout,tvarid,'units','degree Celsius')
netcdf.putAtt(ncout,tvarid,'description','Montly mean temperature')
netcdf.putAtt(ncout,pvarid,'units','mm')
netcdf.putAtt(ncout,pvarid,'description','Montly precipitation sum')
netcdf.putAtt(ncout,nvarid,'units','kg m-2')
netcdf.putAtt(ncout,nvarid,'description','Montly mean NPP')

netcdf.endDef(ncout);

for idim=0:ndim-1
  [dimname, dimlen] = netcdf.inqDim(ncout,idim);
  dimlens(idim+1)=dimlen;
end;

pdata=zeros(dimlens);
tdata=pdata;
ndata=pdata;

for im=m for offset=[0,12,24]
  ncid=netcdf.open(files{im+offset},'NC_NOWRITE');
  [ndim nvar natt udimid] = netcdf.inq(ncid);


  for ivar=0:nvar-1 
    [varname,xtype,dimids,natt] = netcdf.inqVar(ncid,ivar);
    %fprintf('%d %s %d %d %d %d\n',ivar,varname,xtype,dimids,natt);
    switch(varname)
        case 'time', netcdf.putVar(ncout,ivar,m); continue;
        case 'var142', ovarid=pvarid; data=pdata;
        case 'var167', ovarid=tvarid; data=tdata;
        case 'var301', ovarid=nvarid; data=ndata;
       otherwise,
       error('Variable code not defined');
   end
    
    mdata = netcdf.getVar(ncid,ivar);
    data(:,:,im)=mdata;
    netcdf.putVar(ncout,ovarid,data);
    switch(varname)
      case 'var142', pdata=data;
      case 'var167', tdata=data;
      case 'var301', ndata=data;
      otherwise,
       error('Variable code not defined');
    end
  end
  end
end
  
netcdf.close(ncout);


return
end
