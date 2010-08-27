function clp_plasim_surface(varargin)
% Reads a variable from the Planet Simulators surface description

var='LSM';

% Z Geopotential, SSRD surface solar radiation downward
% LSM Landsea mask, SR surface roughness, AL albedo
% TTRC top net thermal rad, SSRC surface net solar radiation
% IE Instantaneous moisture flux

codes={129,  169,   172, 173, 174,  209,  210,  232, 1730};
names={'Z','SSRD','LSM','SR','AL','TTRC','SSRC','IE','Unknown'};
%units={'m^2 s^-2',}
%       173         0    110100        -1        64        32         0      5014

file='/h/lemmen/projects/glues/plasim/Most/plasim/run/surface.txt';
if ~exist(file,'file') error('File does not exist'); end

fid=fopen(file,'r');

code=173;
i=0;
while (~feof(fid))
  header=fscanf(fid,'%10d',8);
  if isempty(header) break; end
  i=i+1;
  vcode(i)=header(1); nlon(i)=header(5); nlat(i)=header(6);
  nlines=nlat(i)*nlon(i)/8;
  if (vcode(i)==code)
    % read data
    for j=1:nlines
      data((j-1)*8+1:j*8)=fscanf(fid,'%12f',8);
      fseek(fid,1,'cof'); % Advance over newline
    end
    break;
  else
    offset=nlines*(8*12+1);
    status=fseek(fid,offset,'cof');
    % skip data  
  end
end
fclose(fid);

if isempty(data) return; end
nlat=nlat(i);
nlon=nlon(i);

lat=90-180*[0:nlat-1]./(nlat)-90/nlat;
lon=-180+360*[0:nlon-1]./(nlon)+180/nlon;
g=reshape(data,nlon,nlat);
grid(1:nlon/2,:)=g(nlon/2+1:nlon,:);
grid(nlon/2+1:nlon,:)=g(1:nlon/2,:);


m_proj('miller');
m_pcolor(lon,lat,grid');
m_grid;

return
end

%'(8E12.6)',IOS