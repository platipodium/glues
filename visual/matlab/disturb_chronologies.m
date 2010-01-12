function disturb_chronologies
%
cl_register_function();

numd=7;
delta=-0.1;

[d,f]=get_files;

indir=fullfile(d.proxies,'redfit/data/input/total');
outdir=strrep(indir,'total',['total_disturbed_' num2str(numd) '_' num2str(delta)]);

if ~exist('outdir','file') mkdir(outdir); end

d=dir(fullfile(indir,'*.dat'));

n=length(d);

for i=1:n 
  
  infile=fullfile(indir,d(i).name);
  outfile=fullfile(outdir,d(i).name);
  
  if exist(outfile,'file') continue; end
  
  data=load(infile,'-ascii');
  tin=data(:,1);
  tout=disturb_chronology(tin,numd,delta);
  data(:,1)=tout;
  save(fullfile(outdir,d(i).name),'-ascii','data');
end

v=struct2cell(cl_get_version);
vtext=v{1};
for i=2:length(v)
  vtext=[vtext ' ' v{i}];
end


rfile=fullfile(outdir,'README.txt');
fid=fopen(rfile,'w');
fprintf(fid,'%s\n','This directory was automatically generated with the matlab',...
  'script disturb_chronologies.m based on files in ',indir,'Version information:',vtext);
fclose(fid);

return
end

  
