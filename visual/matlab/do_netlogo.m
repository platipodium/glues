% Script to prepare for GLUES-EDU version

file='../../euroclim_0.0.nc';
gridfile=strrep(file,'.nc','_0.5x0.5.nc');

variables={'natural_fertility','temperature_limitation','region'};
timelim=[-5000 -5000];

if ~exist(gridfile)
  cl_glues2grid('file',file,'var',variables,...
      'timelim',timelim,'res',0.5,'reg','lbk');
end


ncid=netcdf.open(gridfile,'NOWRITE');

varid=netcdf.inqVarID(ncid,'lat');
d.lat=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'lon');
d.lon=netcdf.getVar(ncid,varid);

nvar=length(variables);
for ivar=1:nvar
  varid=netcdf.inqVarID(ncid,variables{ivar});
  [varname,xtype,dimids,natts]=netcdf.inqVar(ncid,varid);
  if (xtype==5 | xtype==6) xtype='float';
  else xtype='int';
  end
  
  d.data=netcdf.getVar(ncid,varid)';
  ofile=strrep(gridfile,'.nc',sprintf('_%s_%05d.asc',varname,timelim(1)));
  
  cl_write_arcgis_asc(d,'file',ofile,'xtype',xtype);
end

netcdf.close(ncid);