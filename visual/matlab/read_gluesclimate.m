function [lon,lat,npp,gdd]=read_gluesclimate(filename)

cl_register_function();

if ~exist('filename','var') filename='../../src/region/gluesclimate.bin'; end;
if ~exist(filename,'file') return; end;

nvar=4; % Number of variables (lon,lat,npp,gdd)
nrec=23; % Number of records (23 years in climber)

sizes=[10,9,7,6];

fprintf('Reading file %s..\n',filename);
fid=fopen(filename,'r','b');

data=fread(fid,'int32');
ncell=ftell(fid)*1.0/nvar/nrec;
if (mod(ncell,1)>0)
    fprintf('File does not contain whole records, please check\n');
    return
end
fclose(fid);

% Byte order:              BIG_ENDIAN
% Number of records:      22
% Record length:          249932 byte
% Variable number:        4
% Variable length:        62483
% Description:           (packed) Longitude: lon=value/2.0-180.0
% Retrieval formula:     y =( x mod 2^10) / 2^0
% Description:           (packed) Latitude:  lat=value/2.0-60.0
% Retrieval formula:     y =( x mod 2^19) / 2^10
% Description:           (packed) NPP g/m^2/a: npp=value*10.0-0.0(packed) Latitude:  gdd=value*6.0
% Retrieval formula:     y =( x mod 2^26) / 2^19
% Description:           (packed) Latitude:  gdd=value*6.0
% Retrieval formula:     y =( x mod 2^32) / 2^26

if (length(data)==ncell*nrec)
  d=reshape(data,ncell,nrec);
  lon=mod(d,2^10)/2^0;  lon=lon/2.0-180;
  lat=mod(d,2^19)/2^10; lat=lat/2.0-60;
  npp=mod(d,2^26)/2^19; npp=npp*11.0;
  gdd=mod(d,2^32)/2^26; gdd=gdd*6.0;
end;

lon=lon(:,1);
lat=lat(:,1);


return
