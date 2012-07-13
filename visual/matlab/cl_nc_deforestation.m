function cl_nc_deforestation(varargin)
% Calculates deforestation and carbon emission 
% from a glues result file and a climate file
%

cl_register_function;

arguments = {...
  {'file','../../euroclim_0.3.nc'},...
  {'climate','../../data/plasim_11k_vecode_685.nc'},...
};

[args,rargs]=clp_arguments(varargin,arguments);
for i=1:args.length   
  eval([ args.name{i} ' = ' clp_valuestring(args.value{i}) ';']); 
end

%% Read variables from glues result file
ncid=netcdf.open(file,'NC_NOWRITE');
varid=netcdf.inqVarID(ncid,'time');
time=netcdf.getVar(ncid,varid);
timeunit=netcdf.getAtt(ncid,varid,'units');
time=cl_time2yearAD(time,timeunit);
region=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'region'));
farming=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'farming'));
population_density=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'population_density'));
cropfraction=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'cropfraction_static'));
technology=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'technology'));
area=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'area'));
netcdf.close(ncid);


%% Visual inspection of full-scale agricultural societeis in mesopotamia
% Crop area per farmer
% Alternative formulation of cropfraction
cpf=0.02; % km2 per farmer
cropfraction=cpf.*farming.*population_density; % 
cropfraction(cropfraction>1)=1;

%% Curtis et al (2002) estimate 100 t/ha aboveground carbon in temp decid
% forest
% naturalforest=repmat(climate.fshare',1,r.nstep)*100;


% new VECODE formulation
ncid=netcdf.open(climate,'NC_NOWRITE');
ctime=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'time'));
ctime=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'time'));
forest_share=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'forest_share'));
grassland_share=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'grassland_share'));
soilcarbon=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'carbon_in_soil'));
leafcarbon=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'carbon_in_leaves'));
stemcarbon=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'carbon_in_stems'));
littercarbon=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'carbon_in_litter'));
netcdf.close(ncid);

fshare=interp1(ctime,forest_share',time,'linear',NaN);
iprior=find(time<ctime(1));
fshare(iprior,:)=repmat(fshare(iprior(end)+1,:),[length(iprior) 1]);

gshare=interp1(ctime,grassland_share',time,'linear',NaN);
gshare(iprior,:)=repmat(gshare(iprior(end)+1,:),[length(iprior) 1]);

c_leaf=interp1(ctime,leafcarbon',time,'linear',NaN);
c_leaf(iprior,:)=repmat(c_leaf(iprior(end)+1,:),[length(iprior) 1]);
c_litter=interp1(ctime,littercarbon',time,'linear',NaN);
c_litter(iprior,:)=repmat(c_litter(iprior(end)+1,:),[length(iprior) 1]);
c_soil=interp1(ctime,soilcarbon',time,'linear',NaN);
c_soil(iprior,:)=repmat(c_soil(iprior(end)+1,:),[length(iprior) 1]);
c_stem=interp1(ctime,stemcarbon',time,'linear',NaN);
c_stem(iprior,:)=repmat(c_stem(iprior(end)+1,:),[length(iprior) 1]);

naturalcarbon=(c_leaf + c_litter + c_stem + c_soil)';
livecarbon=(c_leaf + c_stem);

% Growing crops = forest conversion
grassfraction=gshare';
forestfraction=fshare'-cropfraction;

% Crops remove the stems, leave the leaves, and destroy 42% of litter/soil
% TODO: adjust to prior definition 
emission=cropfraction.*(c_stem'+0.42*c_soil'+0.42*c_litter');
remainingcarbon=naturalcarbon-emission;

% Emission is in kg/m2, multiply with area and convert to t
cumulative_emission=emission.*repmat(area,1,length(time))*10E6/10E3;

% carbon is calculated as t/ha
% naturalcarbon=b12f.*fshare+b12g.*gshare ...
%     +b34f.*fshare+b34g.*gshare;
% remainingcarbon=b12f.*(fshare-cropfraction) ...
%     +b12g.*(gshare+cropfraction) ...
%     +b34f.*(fshare-cropfraction)...
%     +0.58*b34f.*cropfraction...
%     +b34g.*gshare;

ncid=netcdf.open(file,'NC_WRITE');
timedimid=netcdf.inqDimID(ncid,'time');
regdimid=netcdf.inqDimID(ncid,'region');

try
  varid=netcdf.inqVarID(ncid,'carbon_in_live_vegetation');
catch ('MATLAB:netcdf:inqVarID:variableNotFound');   
  netcdf.reDef(ncid);

  varid=netcdf.defVar(ncid,'carbon_in_live_vegetation','NC_FLOAT',[regdimid timedimid]);
  netcdf.putAtt(ncid,varid,'units','kg m-2');
  netcdf.putAtt(ncid,varid,'min_value',0);
  netcdf.putAtt(ncid,varid,'model','VECODE');
  netcdf.putAtt(ncid,varid,'date_of_creation',datestr(now));

  varid=netcdf.defVar(ncid,'carbon_in_potential_vegetation','NC_FLOAT',[regdimid timedimid]);
  netcdf.putAtt(ncid,varid,'units','kg m-2');
  netcdf.putAtt(ncid,varid,'min_value',0);
  netcdf.putAtt(ncid,varid,'model','VECODE');
  netcdf.putAtt(ncid,varid,'date_of_creation',datestr(now));

  varid=netcdf.defVar(ncid,'carbon_emission','NC_FLOAT',[regdimid timedimid]);
  netcdf.putAtt(ncid,varid,'units','10E3 kg');
  netcdf.putAtt(ncid,varid,'min_value',0);
  netcdf.putAtt(ncid,varid,'model','GLUES');
  netcdf.putAtt(ncid,varid,'date_of_creation',datestr(now));

  varid=netcdf.defVar(ncid,'carbon_in_used_vegetation','NC_FLOAT',[regdimid timedimid]);
  netcdf.putAtt(ncid,varid,'units','kg m-2');
  netcdf.putAtt(ncid,varid,'model','VECODE+GLUES');
  netcdf.putAtt(ncid,varid,'min_value',0);
  netcdf.putAtt(ncid,varid,'date_of_creation',datestr(now));

  netcdf.endDef(ncid);
end

netcdf.putVar(ncid,netcdf.inqVarID(ncid,'carbon_in_potential_vegetation'),naturalcarbon);
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'carbon_in_used_vegetation'),remainingcarbon);
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'carbon_in_live_vegetation'),livecarbon);
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'carbon_emission'),cumulative_emission);
netcdf.close(ncid);

return;
end


    
