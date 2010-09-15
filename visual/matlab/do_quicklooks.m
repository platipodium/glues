function do_quicklooks(sce)
% DO_QUICKLOOKS script creates quick look figures from GLUES results

if ~exist('sce','var') sce='reference'; end
file=fullfile('../..',[sce '.nc']);
timelim=[-9500 -1000];
is=0; id=0;
printtimes=[-9500 -8000 -6000 -4000 -3000 -2000 -1000];

if ~exist(file,'file') error('Requested file does not exist'); end


ncid=netcdf.open(file,'NOWRITE');
[ndims,nvars,ngatts,unlimdimid] = netcdf.inq(ncid);
for varid=0:nvars-1 
  [varname,xtype,dimids,natts] =netcdf.inqVar(ncid,varid);
  fprintf('%s %d\n',varname,length(dimids));
  % Don't do anything with time dim
  if strcmp(varname,'time') continue; end
  % Do static plots when no time dim
  if length(dimids)==1
    is=is+1; static_vars{is}=varname;
  else
    id=id+1; dynamic_vars{id}=varname;
  end
end



%% Create wiki tables
nd=length(dynamic_vars);


fid=fopen(['doc/QuickLook_' sce '.wiki'],'w');
fprintf(fid,'= Dynamic variables =\n');
j=1;
while (nd>0 & j*6<=nd); 
  fprintf(fid,'== ');
  for id=(1+(j-1)*6):(min([j*6,nd])-1) fprintf(fid,'%s,',dynamic_vars{id}); end
  fprintf(fid,'%s ==\n',dynamic_vars{min([j*6,nd])});
  fprintf(fid,'||');
  for id=1+(j-1)*6:min([j*6,nd]) fprintf(fid,'<<arnica(file_regex=.*%s_[0-9],show_text=0,show_date=0)>>||',dynamic_vars{id}); end
  fprintf(fid,'\n\n');
  j=j+1;
end
fclose(fid);


for id=1:length(static_vars)
  clp_nc_variable('sce',sce,'file',file,'var',static_vars{id},'reg','eur','showtime',0,'showstat',0);
  clp_nc_variable('sce',sce,'file',file,'var',static_vars{id},'reg','all','showtime',0,'showstat',0);
end


for id=1:nd
   d=clp_nc_trajectory('sce',sce,'nosum',1,'file',file,'var',dynamic_vars{id},'reg','all','timelim',timelim);
   close(gcf);
   for it=1:length(printtimes)
     clp_nc_variable('sce',sce,'file',file,'var',dynamic_vars{id},'reg','all','timelim',printtimes(it),...
         'lim',[min(min(min(d))) max(max(max(d)))]);   
     close(gcf);
   end
   d=clp_nc_trajectory('sce',sce,'nosum',1,'file',file,'var',dynamic_vars{id},'reg','eur','timelim',timelim);
   close(gcf);
   for it=1:length(printtimes)
     clp_nc_variable('sce',sce,'file',file,'var',dynamic_vars{id},'reg','eur','timelim',printtimes(it),...
         'lim',[min(min(min(d))) max(max(max(d)))]);   
     close(gcf);
   end
end




%% return to main

return;
end
