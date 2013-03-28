function bricks=cl_read_brick_technologies(varargin)
% read_brick_technologies(filename)

% subsidiary script to clp_ivc_city_bricks_technology.m

if nargin==0
  filename='/Users/lemmen/projects/glues/tex/2013/indusreview/brick_locations.tsv';
else
  filename=varargin{1}
end

if ~exist(filename,'file')
    error('File does not exist')
end

fid=fopen(filename,'rt');
d=textscan(fid,'%s%f%f%f%f','Delimiter','\t');
fclose(fid);

times=unique([d{2};d{3};d{4};d{5}]);
times=flipud(times(isfinite(times)));

mstart=d{2}
mend=d{3}
bstart=d{4}
bend=d{5}
for i=1:length(times)
  t=times(i);
  allcount(i)=sum((mstart>=t | bstart>=t) & (mend<=t | bend<=t));
  bcount(i)=sum(bstart>=t & bend<=t);
  mcount(i)=allcount(i)-bcount(i);%sum(mstart>=t & mend<=t);
end
bricks=[times mcount' bcount']
bricks(end,2:3)=NaN
bricks(end,1)=950;

return
end