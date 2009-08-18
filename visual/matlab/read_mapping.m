function read_mapping
% Reads a mapping file and displays the region vector,
% also dumps the region vector to matlab binary file 

% Variables
%   n:            Skalar uint number of regions in .dat.len file
%   nland:        Skalar ulong number of land cells in .dat file
%   ncells:       Skalar ulong number of saved cells in .dat file
%   maxn:         Skalar ulong number of maximum cells in region
%   regionlength: Vector uint[n] of number of cells in region
%   regionindex:  Vector uint[nland] of cell id
%   regionvector: Vector ulong[n*maxn] of cell id
%   regionarray:  Vector ulong[n,maxn] of cell id
%   regionnumber: Vector uint[nland] of region id


cl_register_function();

warning('This function needs to be followed by calc_region_struct');


dir='/h/lemmen/projects/glues/glues/glues/examples/setup/686';
file=fullfile(dir,['mapping_80_686' '.dat.len']);

if ~exist(file,'file') return; end
fid=fopen(file,'r','ieee-le');
regionlength=fread(fid,inf,'uint32');
n=length(regionlength);
nland=sum(regionlength);
fprintf('Total coverage of %ld land cells',nland);
fclose(fid);

regionindex=zeros(nland,1);
regionnumber=regionindex;

file=fullfile(dir,['mapping_80_686' '.dat']);
if ~exist(file,'file') return; end
fid=fopen(file,'r','ieee-le');
regionvector=fread(fid,inf,'uint32');
ncells=length(regionvector);
fclose(fid);

maxn=floor(ncells./n);

rows=360;
cols=720;
map=zeros(rows*cols,1);

regionarray=reshape(regionvector,maxn,n)';
  
colors=prism(6);
%figure(1); clf reset;
%m_proj('Miller','lat',[-75 85]);
%m_coast('line','color','k');

offset=1;
for i=1:n
  len=floor(regionlength(i));
  bot=floor(offset);
  top=floor(offset+len-1);
  regionindex(bot:top)=regionarray(i,1:len);
  regionnumber(bot:top)=i;
  map(regionarray(i,1:len))=i;
  %fprintf('%d %d',i,len);
  color=colors(mod(i,6)+1,:);
  
  ix=mod(regionindex(bot:top)-1,cols);
  iy=ceil(regionindex(bot:top)/cols);
  lon=(ix-358.5)/2.0; 
  lat=(181.5-iy)/2.0;
  
  %if i==1 latmin=min(lat)-10; latmax=max(lat)+10; lonmin=min(lon)-10; lonmax=max(lon)+10; end
  %latmin=max([-90,latmin,min(lat)-10]);
  %latmax=min([ 90,latmax,max(lat)+10]);
  %lonmin=max([-180,lonmin,min(lon)-20]);
  %lonmax=min([ 180,lonmax,max(lon)+20]);
    
  %figure(1); clf reset;
  %m_proj('Mercator','lon',[lonmin lonmax],'lat',[latmin latmax]);
  %m_coast('line','color','k');
  %m_line(lon,lat,'color',color,'Linestyle','none','marker','.');
  offset=top+1;
 
end

ix=mod(regionindex-1,cols);
iy=ceil(regionindex/cols);
lon=(ix-358.5)/2.0;
lat=(181.5-iy)/2.0;
longrid=([1:720]-360.5)/2.0;
latgrid=([1:360]-180.5)/2.0;
regionmap = reshape(map,cols,rows);

file=fullfile(dir,['mapping_80_686' '.mat']);
save(file,'regionarray','regionindex',...
  'regionmap','regionnumber','regionlength','latgrid','longrid','lat','lon');
fprintf('Mapping saved to %s\n',file);

return
