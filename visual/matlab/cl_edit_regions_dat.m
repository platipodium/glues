
function cl_edit_regions_dat(varargin)

% This functions reads the GLUES input file regions.dat (found in the setup
% directory) and makes editing possible

cl_register_function;

file='../../examples/setup/685/regions_80_685.dat';
ofile='../../examples/setup/685/regions_80_685_test.dat'


%file='../../src/test/regions_11k_685.dat';

%% Read file
if ~exist(file,'file') error('File does not exist'); end
fid=fopen(file,'r');
if fid<1 error('Could not open file'); end


latgrid=89.75:-0.5:-89.75;
longrid=-179.75:0.5:179.75;

i=0;
neigh=zeros(685,30)+NaN;

while (~feof(fid))
  sline=fgetl(fid);
  sline=strrep(sline,'\t',' ');
  for j=1:4 sline=strrep(sline,'  ',' '); end
  
  
  [line,count]=sscanf(sline,'%d %d %d %d %d %d',6);
  if count<1 continue; else i=i+1; end
  reg(i)=line(1);
  ncell(i)=line(2);
  area(i)=line(3);
  ilon(i)=line(4);
  ilat(i)=line(5);
  nneigh(i)=line(6);
  
  prefix=sprintf('%d %d %d %d %d %d',reg(i),ncell(i),area(i),ilon(i),ilat(i),nneigh(i));
  fprintf('%s',prefix);
  if nneigh(i)>0 sline=sline(length(prefix)+3:end); 
     line=sscanf(sline,'%d:%f'); 
  end
  for in=1:nneigh(i)
    if in>2
        in;
    end
    neigh(i,in)=line(1+(in-1)*2);
    border(i,in)=line(2+(in-1)*2);
    fprintf(' %d:%f',neigh(i,in),border(i,in));
  end
  fprintf('\n');  
end
fclose(fid);

% Change index +1
nreg=length(reg);
%reg=reg+1;
%neigh=neigh+1;

% Area should be around 130 Mio sqkm (all land without Antarctica)
% Some uncertainty remains with islands
area=round(area.*130E6/sum(area));

ofid=fopen(ofile,'w');

for i=1:nreg
  fprintf(ofid,'%d %d %d %d %d %d',reg(i),ncell(i),area(i),ilon(i),ilat(i),nneigh(i));
  for in=1:nneigh(i)
    fprintf(ofid,' %d:%.1f',neigh(i,in),border(i,in));
  end
  fprintf(ofid,'\n');
end    
fclose(ofid);


nreg=length(reg);


%% Plot some statistics
fprintf('%s\n',file);
fprintf('Number of regions: %d\n',nreg);
fprintf('Number of gridcelles: %d %d %d %d %d\n',sum(ncell),mean(ncell),min(ncell),max(ncell));

  
end