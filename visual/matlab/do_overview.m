% Run script to plot the most important information from a GLUES result

filename='../../lowdelta_base.nc';
sce='test';
reg='all';
timelim=-4000;
riverfile=['river_hr_' reg '.mat'];

%if ~strcmp('reg','all') & ~exist(riverfile,'file') m_gshhs('fr','save',riverfile); end

[d,b]=clp_nc_variable('var','farming','timelim',[-inf,inf],'reg',reg,...
     'marble',0,'transpar',0,'sce',sce,...
    'nogrid',1,'threshold',0.5,'file',filename,'flip',1,'fig',0);
f{1}=b;
%if ~strcmp('reg','all') m_usercoast(riverfile); end

[d,b]=clp_nc_variable('var','npp','timelim',timelim,'reg',reg,...
     'marble',0,'transpar',0,'sce',sce,...
    'nogrid',1,'file',filename,'lim',[0 1200]);
f{2}=b;

[d,b]=clp_nc_variable('var','temperature_limitation','timelim',timelim,'reg',reg,...
     'marble',0,'transpar',0,'sce',sce,...
    'nogrid',1,'file',filename,'lim',[0 1]);
f{3}=b;
return;

[d,b]=clp_nc_variable('var','population_density','timelim',timelim,'reg',reg,...
     'marble',0,'transpar',0,'sce',sce,...
    'nogrid',1,'file',filename,'lim',[0 8]);
f{4}=b;

[d,b]=clp_nc_variable('var','economies','timelim',timelim,'reg',reg,...
     'marble',0,'transpar',0,'sce',sce,...
    'nogrid',1,'file',filename,'lim',[0 8]);
f{5}=b;

[d,b]=clp_nc_variable('var','economies_potential','timelim',timelim,'reg',reg,...
     'marble',0,'transpar',0,'sce',sce,...
    'nogrid',1,'file',filename,'lim',[0 8]);
f{6}=b;

[d,b]=clp_nc_variable('var','farming','timelim',timelim,'reg',reg,...
     'marble',0,'transpar',0,'sce',sce,...
    'nogrid',1,'file',filename,'lim',[0 1]);
f{7}=b;

[d,b]=clp_nc_variable('var','technology','timelim',timelim,'reg',reg,...
     'marble',0,'transpar',0,'sce',sce,...
    'nogrid',1,'file',filename,'lim',[1 inf]);
f{8}=b;

[d,b]=clp_nc_variable('var','cropfraction_static','timelim',timelim,'reg',reg,...
     'marble',0,'transpar',0,'sce',sce,...
    'nogrid',1,'file',filename,'mult',100);
f{9}=b;

[d,b]=clp_nc_variable('var','subsistence_intensity','timelim',timelim,'reg',reg,...
     'marble',0,'transpar',0,'sce',sce,...
    'nogrid',1,'file',filename,'lim',[0 inf]);
f{10}=b;

[d,b]=clp_nc_variable('var','natural_fertility','timelim',timelim,'reg',reg,...
     'marble',0,'transpar',0,'sce',sce,...
    'nogrid',1,'file',filename,'lim',[0 1]);
f{11}=b;

[d,b]=clp_nc_variable('var','actual_fertility','timelim',timelim,'reg',reg,...
     'marble',0,'transpar',0,'sce',sce,...
    'nogrid',1,'file',filename,'lim',[0 1]);
f{12}=b;


[d,b]=clp_nc_trajectory('var','population_density','timelim',[-inf inf],'reg',reg,...
     'sce',sce,'file',filename,'lim',[0 8],'nosum',1);
t{1}=b;
[d,b]=clp_nc_trajectory('var','economies','timelim',[-inf inf],'reg',reg,...
     'sce',sce,'file',filename,'lim',[0 8],'nosum',1);
t{2}=b;
[d,b]=clp_nc_trajectory('var','farming','timelim',[-inf inf],'reg',reg,...
     'sce',sce,'file',filename,'lim',[0 1],'nosum',1);
t{3}=b;
[d,b]=clp_nc_trajectory('var','technology','timelim',[-inf inf],'reg',reg,...
     'sce',sce,'file',filename,'lim',[0 8],'nosum',1);
t{4}=b;
[d,b]=clp_nc_trajectory('var','subsistence_intensity','timelim',[-inf inf],'reg',reg,...
     'sce',sce,'file',filename,'lim',[0 inf],'nosum',1);
t{5}=b;
[d,b]=clp_nc_trajectory('var','cropfraction_static','timelim',[-inf inf],'reg',reg,...
     'sce',sce,'file',filename,'lim',[0 15],'nosum',1,'mult',100);
t{6}=b;


fid=fopen(['overview_' sce '_' reg '.tex'],'w');
fprintf(fid,'\\documentclass{scrartcl}\n\\usepackage{graphicx}\n');
fprintf(fid,'\\begin{document}\n\\noindent\n');
fprintf(fid,'\\parbox{0.5\\hsize}{\\includegraphics[width=\\hsize]{%s-crop}}%s\n',f{1},'%');
fprintf(fid,'\\parbox{0.5\\hsize}{\\includegraphics[width=\\hsize]{%s-crop}}\\\\%s\n',f{2},'%');
fprintf(fid,'\\parbox{0.5\\hsize}{\\includegraphics[width=\\hsize]{%s-crop}}%s\n',f{3},'%');
fprintf(fid,'\\parbox{0.5\\hsize}{\\includegraphics[width=\\hsize]{%s-crop}}\\\\%s\n',f{4},'%');
fprintf(fid,'\\parbox{0.5\\hsize}{\\includegraphics[width=\\hsize]{%s-crop}}%s\n',f{5},'%');
fprintf(fid,'\\parbox{0.5\\hsize}{\\includegraphics[width=\\hsize]{%s-crop}}\\\\%s\n',f{6},'%');
fprintf(fid,'\\parbox{0.5\\hsize}{\\includegraphics[width=\\hsize]{%s-crop}}%s\n',f{7},'%');
fprintf(fid,'\\parbox{0.5\\hsize}{\\includegraphics[width=\\hsize]{%s-crop}}\\\\%s\n',f{8},'%');
fprintf(fid,'\\parbox{0.5\\hsize}{\\includegraphics[width=\\hsize]{%s-crop}}%s\n',f{9},'%');
fprintf(fid,'\\parbox{0.5\\hsize}{\\includegraphics[width=\\hsize]{%s-crop}}\\\\%s\n',f{10},'%');
fprintf(fid,'\\parbox{0.5\\hsize}{\\includegraphics[width=\\hsize]{%s-crop}}%s\n',f{11},'%');
fprintf(fid,'\\parbox{0.5\\hsize}{\\includegraphics[width=\\hsize]{%s-crop}}\\\\%s\n',f{12},'%');
fprintf(fid,'\\newpage\n\\noindent\n');
fprintf(fid,'\\parbox{0.5\\hsize}{\\includegraphics[width=\\hsize]{%s-crop}}%s\n',t{1},'%');
fprintf(fid,'\\parbox{0.5\\hsize}{\\includegraphics[width=\\hsize]{%s-crop}}\\\\%s\n',t{2},'%');
fprintf(fid,'\\parbox{0.5\\hsize}{\\includegraphics[width=\\hsize]{%s-crop}}%s\n',t{3},'%');
fprintf(fid,'\\parbox{0.5\\hsize}{\\includegraphics[width=\\hsize]{%s-crop}}\\\\%s\n',t{4},'%');
fprintf(fid,'\\parbox{0.5\\hsize}{\\includegraphics[width=\\hsize]{%s-crop}}%s\n',t{5},'%');
fprintf(fid,'\\parbox{0.5\\hsize}{\\includegraphics[width=\\hsize]{%s-crop}}\\\\%s\n',t{6},'%');
fprintf(fid,'\\end{document}');
fclose(fid);

% Command line
fprintf('for F in `ls /Users/lemmen/devel/glues/visual/plots/variable/*/*_685_amant_base_climb*[r0].pdf` ; do pdfcrop  $F; done');
