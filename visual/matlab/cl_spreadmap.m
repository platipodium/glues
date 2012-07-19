function cl_spreadmap

% Percentage for timing
pc=0.5;


spread=load('spread_mechanism_all_eurolbk_base');
nhhreg=length(spread.hreg);
timing=zeros(nhhreg,1)+Inf;
reldQp=zeros(nhhreg,1)+NaN;

ifile='../../eurolbk_base.nc';
ofile='../../eurolbk_base_spread.nc';

% Open netcdf files
if ~exist(ifile,'file') error('File does not exist'); end
if exist(ofile,'file') delete(ofile); end
ncid=netcdf.open(ifile,'NC_NOWRITE');
ncout=netcdf.create(ofile,'NOCLOBBER');

% Define time and region dimension and vars
timedimid=netcdf.defDim(ncout,'time',0);
regdimid=netcdf.defDim(ncout,'region',length(spread.hreg));
timevarid=netcdf.defVar(ncout,'time','NC_DOUBLE',timedimid);
regvarid=netcdf.defVar(ncout,'region','NC_INT',regdimid);
farmvarid=netcdf.defVar(ncout,'farming','NC_DOUBLE',[regdimid timedimid]);

% Copy attributes for GLOBAL, time, region, farming
varids=[netcdf.getConstant('NC_GLOBAL') netcdf.inqVarID(ncid,'time') netcdf.inqVarID(ncid,'region') netcdf.inqVarID(ncid,'farming')];
ovarids=[netcdf.getConstant('NC_GLOBAL') netcdf.inqVarID(ncout,'time') netcdf.inqVarID(ncout,'region') netcdf.inqVarID(ncout,'farming')];
for ivarid=1:length(varids)
  varid=varids(ivarid);
  ovarid=ovarids(ivarid);
  if ivarid>1 [name,xtype,dimids,natts]=netcdf.inqVar(ncid,varid); else [ndims,nvars,natts,unlimdimid] = netcdf.inq(ncid); end
  for iatt=0:natts-1
    attname = netcdf.inqAttName(ncid,varid,iatt);
    netcdf.copyAtt(ncid,varid,attname,ncout,ovarid);
  end
  netcdf.putAtt(ncout,ovarid,'date_of_modification',datestr(now));
end

% Define new vars and attributes
spreadvarid=netcdf.defVar(ncout,'percentage_of_immigrant_farmers','NC_DOUBLE',[regdimid timedimid]);
varid=spreadvarid;
netcdf.putAtt(ncout,varid,'long_name','percentage_of_immigrant_farmers');
netcdf.putAtt(ncout,varid,'units', '1');
netcdf.putAtt(ncout,varid,'valid_min',0.0);
netcdf.putAtt(ncout,varid,'valid_max',1.0);
netcdf.putAtt(ncout,varid,'description','Percentage of immigrant farmers');
netcdf.putAtt(ncout,varid,'date_of_creation',datestr(now));
netcdf.putAtt(ncout,varid,'date_of_modification',datestr(now));

timingvarid=netcdf.defVar(ncout,'timing_of_farming','NC_DOUBLE',[regdimid]);
varid=timingvarid;
netcdf.putAtt(ncout,varid,'long_name','timing_of_farming');
netcdf.putAtt(ncout,varid,'units', 'years since 01-01-01');
netcdf.putAtt(ncout,varid,'calendar', '360_day');
netcdf.putAtt(ncout,varid,'description',sprintf('Time when >=%s%% are devoted to farming',num2str(round(pc*100))));
netcdf.putAtt(ncout,varid,'date_of_creation',datestr(now));
netcdf.putAtt(ncout,varid,'date_of_modification',datestr(now));

netcdf.endDef(ncout);
netcdf.close(ncid);

% Calculate with spread mechanism for base simulation
for i=1:length(spread.hreg) 
   itiming=min(find(spread.farming(i,:)>=pc));
   if ~isempty(itiming)
     timing(i)=spread.rtime(itiming);
   else
     timing(i)=Inf;
   end
end

% Add varialbe values to netcdf file
time=spread.rtime;
for i=1:length(time)
  netcdf.putVar(ncout,timevarid,i-1,double(time(i)));
end
netcdf.putVar(ncout,regvarid,spread.hreg);
netcdf.putVar(ncout,farmvarid,spread.farming);
netcdf.putVar(ncout,timingvarid,timing);
netcdf.putVar(ncout,spreadvarid,spread.reldQp);

netcdf.close(ncout);

cl_glues2grid('timelim',[min(time) max(time)],'timestep',50,'variables',...
    {'farming','timing_of_farming','percentage_of_immigrant_farmers'},...
    'file',ofile,'lonlim',[-10 42],'latlim',[31 57])


% Define new 
return;
   
end
















