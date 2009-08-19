function write_mapping(varargin)
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

matfile='regionmap_686.mat';

%if nargin<1 return; end

iarg=1;
while iarg<=nargin
  arg=lower(varargin{iarg});
  
  switch arg(1:3)
    case 'fil'
          matfile=varargin{iarg+1};
          iarg=iarg+1;
      otherwise
        warning('Unknown keyword %s skipped.',varargin{iarg});    
  end
  iarg=iarg+1;
end

if ~exist(matfile,'file') 
    error('Input file does not exist'); 
end

prefix=strrep(matfile,'.mat','');
binfile=[prefix '.bin'];
lenfile=[prefix '.len'];
txtfile=[prefix '.txt'];

load(matfile);
% read 'regionarray','regionindex',...
% 'regionmap','regionnumber','regionlength','latgrid','longrid','lat','lon'

fid=fopen(lenfile,'w','ieee-le');
fwrite(fid,region.length,'uint32');
nland=sum(region.length);
fprintf('Total coverage of %ld land cells\n',nland);
fclose(fid);

fid=fopen(binfile,'w','ieee-le');
[nreg,maxn]=size(region.land);
regionvector=reshape(region.land,maxn*nreg,1);
fwrite(fid,regionvector,'uint32');
fclose(fid);

v=get_version;
fid=fopen(txtfile,'w');
fprintf(fid,'Binary format: ieee-le uint32\n');
fprintf(fid,'Land info: %d land cells in %d regions\n',nland,length(region.length));
fprintf(fid,'Version info: %s',struct2stringlines(v));
fclose(fid);

return
end
