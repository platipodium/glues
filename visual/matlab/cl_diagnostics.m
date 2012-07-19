function d=cl_diagnostics(varargin)
% CL_SUBSISTENCE_INTENSITY(varargin)
% 

global ncid recalculate
cl_register_function;

arguments = {...
  {'file','../../euroclim_0.4.nc'},...
  {'variable','subsistence_intensity'},...
  {'nowrite',1},...
  {'recalculate',0},...
};

[args,rargs]=clp_arguments(varargin,arguments);
for i=1:args.length   
  eval([ args.name{i} ' = ' clp_valuestring(args.value{i}) ';']); 
end

if ~exist(file,'file') error('File does not exist'); end
ncid=netcdf.open(file,'NOWRITE');

try
  varid=netcdf.inqVarID(ncid,variable);
  found=1;
catch
  found=0;   
end

if recalculate found=0; end
if found  
  value=netcdf.getVar(ncid,varid);
else
  switch (variable)
      case('lossterm'), value=calc_lossterm();
      case('growthterm'), value=calc_growthterm();
      case('relative_growth_rate'), value=calc_relative_growth_rate();
      case('capacity'), value=calc_capacity();
      case('subsistence_intensity'), value=calc_subsistence_intensity();
      case('actual_fertility'), value=calc_actual_fertility();
      case('artisans'), value=calc_artisans();
      case('overexploitation'), value=calc_overexploitation();
      case('forager_subsistence'), value=calc_forager_subsistence();
      case('farmer_subsistence'), value=calc_farmer_subsistence();
      otherwise error('Expression not defined (yet)');     
  end
    
end

if ~nowrite
    error('Not yet implemented');
end

netcdf.close(ncid);

d=value;
return;


return
end

function relative_growth_rate=calc_relative_growth_rate()
  relative_growth_rate = calc_growthterm() - calc_lossterm();
  return;
end

function lossterm=calc_lossterm()
  global ncid;
  varid=netcdf.getConstant('GLOBAL')
  rho=netcdf.getAtt(ncid,varid,'param_gammab');
  Tlit=netcdf.getAtt(ncid,varid,'param_LiterateTechnology');
  
  varid=netcdf.inqVarID(ncid,'population_density');
  P=netcdf.getVar(ncid,varid);
  varid=netcdf.inqVarID(ncid,'technology');
  T=netcdf.getVar(ncid,varid);
  
  lossterm=rho*exp(-T/Tlit) .* P;
  return;
end

function growthterm=calc_growthterm()
  global ncid;
  varid=netcdf.getConstant('GLOBAL');
  mu=netcdf.getAtt(ncid,varid,'param_gammab');
  growthterm = mu*calc_actual_fertility().*calc_artisans().*calc_subsistence_intensity();
  return;
end
  
function artisans=calc_artisans()
  global ncid;
  varid=netcdf.getConstant('GLOBAL');
  omega=netcdf.getAtt(ncid,varid,'param_omega');
  varid=netcdf.inqVarID(ncid,'technology');
  T=netcdf.getVar(ncid,varid);
  artisans=1-omega*T;
  return;
end

function actual_fertility=calc_actual_fertility()
  global ncid;
  varid=netcdf.inqVarID(ncid,'natural_fertility');
  natural_fertility=netcdf.getVar(ncid,varid);
  actual_fertility=(1-calc_overexploitation()).*natural_fertility;
  return;
end

function overexploitation=calc_overexploitation()
  global ncid;
  varid=netcdf.getConstant('GLOBAL');
  gamma=netcdf.getAtt(ncid,varid,'param_overexp');
  varid=netcdf.inqVarID(ncid,'population_density');
  P=netcdf.getVar(ncid,varid);
  varid=netcdf.inqVarID(ncid,'technology');
  T=netcdf.getVar(ncid,varid);
  
  overexploitation = gamma*sqrt(T).*P;
  return;
end


function subsistence_intensity=calc_subsistence_intensity()
  global ncid;
  global recalculate
  
  if recalculate
    subsistence_intensity=calc_forager_subsistence() + calc_farmer_subsistence();      
  else try
      varid=netcdf.inqVarID(ncid,'subsistence_intensity');
      subsistence_intensity=netcdf.getVar(ncid,varid);
      catch
      subsistence_intensity=calc_forager_subsistence() + calc_farmer_subsistence();      
      end
  end
  return
end

function forager_subsistence=calc_forager_subsistence()
  global ncid;
  
  varid=netcdf.inqVarID(ncid,'farming');
  Q=netcdf.getVar(ncid,varid);
  varid=netcdf.inqVarID(ncid,'technology');
  T=netcdf.getVar(ncid,varid);
  forager_subsistence=(1-Q) .* sqrt(T);
  return;
end

function farmer_subsistence=calc_farmer_subsistence()
  global ncid;
  
  varid=netcdf.inqVarID(ncid,'farming');
  Q=netcdf.getVar(ncid,varid);
  varid=netcdf.inqVarID(ncid,'technology');
  T=netcdf.getVar(ncid,varid);
  varid=netcdf.inqVarID(ncid,'economies');
  E=netcdf.getVar(ncid,varid);
  varid=netcdf.inqVarID(ncid,'temperature_limitation');
  tlim=netcdf.getVar(ncid,varid);
  farmer_subsistence=Q .* T .* E .* tlim;
  return;
end



  
  


