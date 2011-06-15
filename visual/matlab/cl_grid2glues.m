function cl_grid2glues(varargin)
% This function takes gridded data and maps them to 
% a glues mapping (with regions as coordinate)

arguments = {...
  {'timelim',[-inf,inf]},...
  {'variables','npp'},...
  {'file','../../data/plasim_11k_vecode.nc'},...
  {'latlim',[-90 90]},...
  {'lonlim',[-180 180]},...
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


variables='all';


%% Read glues mapping (todo: from nc file)

matfile='regionmap_685.mat';
load(matfile)
if ~exist('region','var') 
  region.length=regionlength;
end

if ~exist('map','var')
    map.region=regionmap;
end

if ~exist('land','var')
    land.region=regionnumber;
    land.map=regionindex;
    land.lat=lat;
    land.lon=lon;
end

nreg=length(region.length);
[cols,rows]=size(map.region);


%% Read variables from gridded data
ncid=netcdf.open(file,'NC_NOWRITE');

% Read dimensions
[ndim nvar natt udimid] = netcdf.inq(ncid);
for i=0:ndim-1
  [dimname, dimlen] = netcdf.inqDim(ncid,i);
  if strcmp(dimname,'lat') latdim=i;
  elseif strcmp(dimname,'latitude') latdim=i;
  elseif strcmp(dimname,'lon') londim=i;
  elseif strcmp(dimname,'longitude') londim=i;
  elseif strcmp(dimname,'time') timedim=i;
  end
end

% Read coordinate variables
[timename, ntime] = netcdf.inqDim(ncid,timedim);
varid=netcdf.inqVarID(ncid,timename);
time=netcdf.getVar(ncid,varid);
[latname, nlat] = netcdf.inqDim(ncid,latdim);
varid=netcdf.inqVarID(ncid,latname);
lat=netcdf.getVar(ncid,varid);
[lonname, nlon] = netcdf.inqDim(ncid,londim);
varid=netcdf.inqVarID(ncid,lonname);
lon=netcdf.getVar(ncid,varid);

if ischar(variables) && strcmp(variables,'all')
  j=0;
  variables={};
  for ivar=0:nvar-1
    [varname,xtype,dimids,natt] = netcdf.inqVar(ncid,ivar);
    if strcmp(varname,latname) continue;
    elseif strcmp(varname,lonname) continue;
    elseif strcmp(varname,timename) continue;
    end
    j=j+1;
    variables{j}=varname;
  end
end
       
% Read variables
for i=1:length(variables)
  if iscell(variables) varname=variables{i};
  else varname=variables;
  end
  
  varid=netcdf.inqVarID(ncid,varname);
  var{i}=netcdf.getVar(ncid,varid);
end

latres=lat(2:end)-lat(1:end-1);
if all(latres>0) latup=1; else latup=0; end
latres=unique(latres);


tmpfilename='tmp_cl_grid2glues.mat';
if ~exist(tmpfilename,'file')  
  for ireg=1:nreg
  % select all cells of this region
    
    iselect{ireg}=find(land.region == ireg);
    nselect=length(iselect);
    if nselect<1 error('Something is wrong here, no cells with region'); end

    [ilon,ilat]=regidx2geoidx(land.map(iselect{ireg}),cols);
    iclon{ireg}=ceil((1.0*ilon)/cols*nlon);
  
    if latup==1
      iclat{ireg}=ceil(ilat/rows*nlat);
    else
      iclat{ireg}=ceil((361-ilat)/rows*nlat);
    end
    subindex{ireg}=sub2ind([nlon,nlat],iclon{ireg},iclat{ireg});
    weight{ireg}=cosd(land.lat(iselect{ireg}));
    sweight=sum(weight{ireg});
    weight{ireg}=weight{ireg}/sweight;
  end
  save(tmpfilename,'weight','subindex');
else load(tmpfilename);
end


for i=1:length(variables)
  varid=netcdf.inqVarID(ncid,variables{i});
  [varname,xtype,dimids,natt] = netcdf.inqVar(ncid,varid);
  ilatdim=find(dimids==latdim);
  ilondim=find(dimids==londim);
 
  fprintf('%s ...',varname);
    
  if length(dimids)==1
    if dimids==latdim
       warning('Undefined dimension order');
    elseif londim==dimids
      warning('Undefined dimension order');
    else
      [othername,nother]=netcdf.inqDim(ncid,dimids(1));
      regval=zeros(nreg,nother);
      for iother=1:nother 
        regval(:,iother)=var{i}(iother); 
      end
    end
  
  elseif length(dimids)==2
      if [ilatdim,ilondim]==dimids
        warning('Undefined dimension order');
      elseif [ilondim,ilatdim]==dimids
        warning('Undefined dimension order');
      else
        warning('Undefined dimension order');
      end
  elseif length(dimids)==3 
      if [ilatdim,ilondim]==dimids(1:2)
        [othername,nother]=netcdf.inqDim(ncid,dimids(3));
        regval=zeros(nreg,nother)-NaN;
        for ireg=1:nreg
          for iother=1:nother
            gridval=squeeze(var{i}(:,:,iother));
            regval(ireg,iother)= ...
                sum(weight{ireg}.*gridval(subindex{ireg}));
          end
          % fprintf('r');
        end
      elseif [ilatdim,ilondim]==dimids(2:3)
        warning('Undefined dimension order');
      elseif [ilondim,ilatdim]==dimids(1:2)
        warning('Undefined dimension order');
      elseif [ilondim,ilatdim]==dimids(2:3)
        warning('Undefined dimension order');
      else
        warning('Undefined dimension order');
      end
    else
        warning('Undefined dimension order');
    end
    rvar{i}=regval;
    fprintf('\n');

end 

%rvar{1}=rand(nreg,ntime);  

outfile=strrep(file,'.nc',['_' num2str(nreg) '.nc']);
if exist(outfile,'file') delete(outfile); end
ncout=netcdf.create(outfile,'NOCLOBBER');

timedim=netcdf.defDim(ncout,'time',0);
regdim=netcdf.defDim(ncout,'region',nreg);

netcdf.defVar(ncout,'time','NC_DOUBLE',timedim);
netcdf.defVar(ncout,'region','NC_INT',regdim);

for i=1:length(variables)
  varname=variables{i};
  varid=netcdf.defVar(ncout,varname,'NC_FLOAT',[regdim,timedim]);
end

[ndim nvar natt udimid] = netcdf.inq(ncout);

% Copy attributes for all variables
for ovar=0:nvar-1
  if ovar==0
    natts=natt;
    ivar=0;
  else
    [varname,xtype,dimids,natts]=netcdf.inqVar(ncout,ovar);
    if strcmp(varname,'region') continue; end
    ivar=netcdf.inqVarID(ncid,varname);
    [varname,xtype,dimids,natts]=netcdf.inqVar(ncid,ivar);
  end
  for iatt=0:natts-1
    attname = netcdf.inqAttName(ncid,ivar,iatt);
    netcdf.copyAtt(ncid,ivar,attname,ncout,ovar);
  end
  netcdf.putAtt(ncout,ovar,'date_of_modification',datestr(now));
end

netcdf.endDef(ncout);
netcdf.close(ncid);


for i=1:ntime
  varid=netcdf.inqVarID(ncout,'time');
  netcdf.putVar(ncout,varid,i-1,time(i));
end

netcdf.putVar(ncout,netcdf.inqVarID(ncout,'region'),1:nreg);

for i=1:length(variables)
  varid=netcdf.inqVarID(ncout,variables{i});
  netcdf.putVar(ncout,varid,rvar{i});
end

netcdf.close(ncout);

return;



