function cl_proxycsv2tex(proxyfile)

if ~exist('proxyfile','var')
  proxyfile='proxydescription_258_128.csv';
end


if ~exist(proxyfile,'file')
  error('File does not exist');
end


matfile=strrep(proxyfile,'.csv','.mat');
if ~exist('matfile','file');
  evinfo=read_textcsv(proxyfile);
else
  load(matfile); % into struct evinfo
end

% Find regions of interest
reg='lbk'; [ireg,nreg,loli,lali]=find_region_numbers(reg);

% Load events in region
evregionfile=sprintf('EventInReg_128_685.tsv');
evinreg=load(evregionfile,'-ascii');

evinreg=evinreg(ireg,:);

[ev,ievs]=unique(evinreg);
nev=length(ev);


texfile=strrep(proxyfile,'.csv','.tex');
fid=fopen(texfile,'w');
%  fprintf(fid,"\\begin{table*}" ; #fprintf(fid,"\\centering";
fprintf(fid,'\\scriptsize\n');
%fprintf(fid,'\\begin{tabular}{p{1ex} p{19ex} p{10ex} p{5ex} p{29ex}');
fprintf(fid,'\\begin{tabular}{p{0ex} p{19ex} p{7ex} p{5.5ex} p{34ex} p{1ex} p{19ex} p{11ex} p{5.5ex} p{29ex}}');
%fprintf(fid,' p{1ex} p{18ex} p{10ex} p{5ex} p{29ex}}\n');
fprintf(fid,'\\toprule\n');
fprintf(fid,'No & Site & Proxy & Per & Reference & No & Site & Proxy & Per & Reference\\\\\n');
fprintf(fid,'\\midrule\n');


format='%d & %s & %s & %d--%d & \\citealt{%s}';
for ie=1:nev
  iev=ev(ie);
  fprintf(fid,format,evinfo.No(iev),strrep(evinfo.Plotname{iev},' ','\,'),...
      strrep(evinfo.Proxy{iev},' ','\,'),...
      evinfo.t_min(iev),evinfo.t_max(iev),evinfo.Source{iev});
  if mod(ie,2)==1 fprintf(fid,'& ');
  else
    fprintf(fid,'\\\\[0ex]\n');
  end
end
if mod(nev,2)==1
  fprintf(fid,' & & & & & \\\\[0ex]\n');
end
 
fprintf(fid,'\\bottomrule\n\\end{tabular}');
%fprintf(fid,'\\end{table*}\n');


fclose(fid);


return
end


