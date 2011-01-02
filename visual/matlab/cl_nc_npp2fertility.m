function cl_nc_npp2fertility(varargin)

file='../../data/biome4.nc';
ncid=netcdf.open(file,'WRITE');
varid=netcdf.inqVarID(ncid,'npp');
npp=netcdf.getVar(ncid,varid);

ivalid=find(npp>0);
factor=1; kappa=550;
natfert=npp*0-9999.0;
natfert(ivalid)=naturalfertility(npp(ivalid),kappa,factor);

nppa=[0:2000];
figure(1); clf reset;
plot(nppa,naturalfertility(nppa,kappa,factor),'r-','LineWidth',3);
xlabel('Net primary productivity');
ylabel('Natural fertility');
title(sprintf('NPP-NatFert relationship (kappa=%d,alpha=%.2f)',kappa,factor));

icefactor=1;
suitspec=npp*0-9999.0;
suitspec(ivalid)=suitablespecies(npp(ivalid),kappa,icefactor);
figure(2); clf reset;
plot(nppa,suitablespecies(nppa,kappa,icefactor),'r-','LineWidth',3);
xlabel('Net primary productivity');
ylabel('Suitable species');
title(sprintf('NPP-SuitSpecies relationship (kappa=%d,alpha=%.2f)',kappa,icefactor));


[ndims,nvars,ngatts,unlimdimid] = netcdf.inq(ncid);
for i=1:nvars
  varnames{i}=netcdf.inqVar(ncid,i-1);
end

if isempty(strmatch('natural_fertility',varnames))
  netcdf.reDef(ncid);
  [varname,xtype,dimids,natts] = netcdf.inqVar(ncid,varid);
  varid=netcdf.defVar(ncid,'natural_fertility','NC_FLOAT',dimids);
  netcdf.putAtt(ncid,varid,'units','');
  netcdf.putAtt(ncid,varid,'long_name','Relative natural fertility');
  netcdf.putAtt(ncid,varid,'missing_value',-9999.0);
  netcdf.putAtt(ncid,varid,'scale_factor',1.0);
  netcdf.putAtt(ncid,varid,'add_offset',0.0);
  netcdf.endDef(ncid);
end

if isempty(strmatch('suitable_species',varnames))
  netcdf.reDef(ncid);
  [varname,xtype,dimids,natts] = netcdf.inqVar(ncid,varid);
  varid=netcdf.defVar(ncid,'suitable_species','NC_FLOAT',dimids);
  netcdf.putAtt(ncid,varid,'units',''); 
  netcdf.putAtt(ncid,varid,'long_name','Relative number of suitable species');
  netcdf.putAtt(ncid,varid,'missing_value',-9999.0);
  netcdf.putAtt(ncid,varid,'scale_factor',1.0);
  netcdf.putAtt(ncid,varid,'add_offset',0.0);
  netcdf.endDef(ncid);
end

varid=netcdf.inqVarID(ncid,'natural_fertility');
netcdf.putVar(ncid,varid,natfert);

varid=netcdf.inqVarID(ncid,'suitable_species');
netcdf.putVar(ncid,varid,suitspec);
netcdf.close(ncid);




%% Compares to other version 
% with calculation of natural fertiltiy and suitable species from the
% aggregated regions
file='../../data/biome4_685.mat';
if exist(file,'file');
  load(file);
  figure(3); clf reset; hold on;
  plot(climate.natural_fertility,naturalfertility(climate.npp,kappa,factor),'r.');
  plot(climate.suitable_species,suitablespecies(climate.npp,kappa,icefactor),'b.');
  xlabel('half-degree resolution');
  ylabel('region-aggregated resolution');
  legend('Natural fertility','Suitable species','Location','NorthWest');
end



return 
end

%%
% Returns potential fertility dependent on NPP
% see RegionalClimate.cc::54
function naturalfertility=naturalfertility(npp,kappa,factor)
  naturalfertility=hyper(kappa*1.5,factor.*npp,2);
  return;
end
  
%% Returns suitable species dependent on NPP
% see RegionalClimate.cc::63
% neglects ice_fac so far
function suitablespecies=suitablespecies(npp,kappa,icefactor)
  suitablespecies=hyper(kappa,icefactor*npp,4);
  return
end

%% Returns hyperbolic function
function hyper=hyper(kap,np,n)
  ka=kap.^(n-1);
  hyper=n.*ka.*np./(ka.*kap.*(n-1)+np.^n);
  return;
end

