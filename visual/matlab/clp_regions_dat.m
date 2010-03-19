function clp_regions_dat

% This functions plots the GLUES input file regions.dat (found in the setup
% directory) to check for its consistency

cl_register_function;

file='../../examples/setup/685/regions_80_685.dat';

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
  [line,count]=sscanf(sline,'%d %d\t%d %d %d\t%d');
  if count<1 continue; else i=i+1; end
  reg(i)=line(1);
  ncell(i)=line(2);
  area(i)=line(3);
  ilon(i)=line(4);
  ilat(i)=line(5);
  nneigh(i)=line(6);
  
  prefix=sprintf('%d %d\t%d %d %d\t%d',reg(i),ncell(i),area(i),ilon(i),ilat(i),nneigh(i));
  fprintf('%s',prefix);
  if nneigh(i)>0 sline=sline(length(prefix)+3:end); end
  for in=1:nneigh(i)
    line=sscanf(sline,'%d:%f');
    neigh(i,in)=line(1);
    fprintf('\t%d:%f',line(1),line(2));
  end
  fprintf('\n');
  
end


fclose(fid);

lon=longrid(ilon)+2;
lat=latgrid(ilat)-1;
nreg=length(reg);

figure(1);
clf reset;

m_proj('miller','lat',[min(lat)-3 max(lat)+3]);
m_coast;
hold on;
m_grid;
m_plot(lon,lat,'k.');


for i=1:nreg
  for j=1:nneigh(i)
    m_plot([lon(i),lon(neigh(i,j)+1)],[lat(i),lat(neigh(i,j)+1)],'r-');
  end
end

end