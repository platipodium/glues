% Matlab run script for testing the bug
% which occured in Jan 2012




predir='/Users/lemmen/devel';
prefixes={'glues','glues-1.1.14','glues-1.1.13','glues-1.1.12','glues-1.1.11'};
postfix='test';

for ipre=1:length(prefixes)
    file=fullfile(predir,prefixes{ipre},[postfix '.nc']);
    if ~exist(file,'file'); continue; end
    
    pfile=fullfile(predir,prefixes{ipre},[postfix '_map.png']);
    if exist(pfile,'file');
      fdir=dir(file);
      pdir=dir(pfile);
      if datenum(fdir.date)<datenum(pdir.date) continue; end;
    end
      
    [d,b]=clp_nc_variable('var','farming','threshold',0.5,'reg','lbk','file',file,'noprint',1,'timelim',[-7000 -3000],'showvalue',1);
    title(['Timing ' prefixes{ipre} '_' postfix]);
    cl_print(gcf,'name',fullfile(predir,prefixes{ipre},[postfix '_map']),'ext','png');
    clp_nc_trajectory('var','farming','timelim',[-7000 -1000],'file',file,'noprint',1,'reg','lbk','ylim',[0 1],'nosum',1)
    title(['Farming ' prefixes{ipre} '_' postfix]);
    cl_print(gcf,'name',fullfile(predir,prefixes{ipre},[postfix '_farming']),'ext','png');
    clp_nc_trajectory('var','population_density','timelim',[-7000 -1000],'file',file,'noprint',1,'reg','lbk','ylim',[0 5],'nosum',1)
    title(['Population ' prefixes{ipre} '_' postfix]);
    cl_print(gcf,'name',fullfile(predir,prefixes{ipre},[postfix '_population_density']),'ext','png');
    
end


predir='/Users/lemmen/devel/glues/';
prefixes={'ref','eurolbk'};
postfixes={'base','demic','cultural','nospread','events'};


for ipre=1:length(prefixes)
  for ipost=1:length(postfixes)
    file=fullfile(predir,[prefixes{ipre} '_' postfixes{ipost} '.nc']);
    if ~exist(file,'file'); continue; end
    
    pfile=fullfile(predir,[prefixes{ipre} '_' postfixes{ipost} '_map.png']);
    if exist(pfile,'file');
      fdir=dir(file);
      pdir=dir(pfile);
      if datenum(fdir.date)<datenum(pdir.date) continue; end;
    end
      
    [d,b]=clp_nc_variable('var','farming','threshold',0.5,'reg','lbk','file',file,'noprint',1,'timelim',[-7000 -3000],'showvalue',1);
    title(['Timing ' prefixes{ipre} '_' postfixes{ipost}]);
    cl_print(gcf,'name',fullfile(predir,[prefixes{ipre} '_' postfixes{ipost} '_map']),'ext','png');
    clp_nc_trajectory('var','farming','timelim',[-7000 -1000],'file',file,'noprint',1,'reg','lbk','ylim',[0 1],'nosum',1)
    title(['Farming ' prefixes{ipre} '_' postfixes{ipost}]);
    cl_print(gcf,'name',fullfile(predir,[prefixes{ipre} '_' postfixes{ipost} '_farming']),'ext','png');
    clp_nc_trajectory('var','population_density','timelim',[-7000 -1000],'file',file,'noprint',1,'reg','lbk','ylim',[0 5],'nosum',1)
    title(['Population ' prefixes{ipre} '_' postfixes{ipost}]);
    cl_print(gcf,'name',fullfile(predir,[prefixes{ipre} '_' postfixes{ipost} '_population_density']),'ext','png');
    
  end
end


for ipre=1:length(prefixes)
  for ipost=1:length(postfixes)
    file=fullfile(predir,[prefixes{ipre} '_' postfixes{ipost} '.nc']);
    if ~exist(file,'file'); continue; end
    
    res=0.5;
    pfile=strrep(file,'.nc','_0.5x0.5.nc');
    if exist(pfile,'file');
      fdir=dir(file);
      pdir=dir(pfile);
      if datenum(fdir.date)<datenum(pdir.date) continue; end;
    end
    
    cl_glues2grid('file',file,'timelim',[-7100 -0],'variables',{'population_density','farming'},...
        'timestep',100,'resolution',0.5,'lonlim',[-10,42],'latlim',[31,57]);
  end
end


arguments = {...
  {'timelim',[-9500,-9000]},...
  {'variables',{'population_density','farming'}},...
  {'timestep',100},...
  {'file','../../test.nc'},...
  {'resolution',0.5},...
  {'latlim',[-90 90]},...
  {'lonlim',[-180 180]},...
};






names={'map','farming','population'};
for iname=1:length(names)
fprintf('\\begin{tabular}{c c}\n');
for ipost=1:length(postfixes)
  for ipre=1:length(prefixes)
 
    name=fullfile(predir,[prefixes{ipre} '_' postfixes{ipost} '_' names{iname} '.png']);
    if iname==1 fprintf('\\includegraphics[viewport=70 75 465 370,clip=,width=0.5\\hsize]{%s}',name);
    else fprintf('\\includegraphics[viewport=0 25 560 400,clip=,width=0.5\\hsize]{%s}',name);
    end
    if ipre==length(prefixes) fprintf('\\\\\n'); else fprintf(' & '); end
  
  end
end
fprintf('\\end{tabular}\n');
end






 