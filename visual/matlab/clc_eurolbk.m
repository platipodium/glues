function cmap = clc_eurolbk(m)
%CLC_EUROLBK  color map
%   CLC_EUROLBK(M) returns an M-by-3 matrix 
%   Carsten Lemmen 2010-02-24

cl_register_function();

if nargin < 1
   m = size(get(gcf,'colormap'),1);
end

if m==1 
   error('Colormap length must be greater than 1');
end


map=[
  [1 0 1];
  [0.5 0 1];
  [0 0 1];
  [0 0.5 0.8];
  [0 1 1];
  [0.5 0.8 0.8];
  [0.5 1 0.5];
  [1 0.9 0.5];
  [0.9 0.9 0];
  [1 0.5 0];
  [1 0 0];
  [0.5 0 0];
  [0 0 0];
];

s=size(map,1)
if s<m
  map=resample(map,m,s);
elseif s>m
  map=map(int8(1+(s-m)/2):int8(s-(s-m)/2),:);  
end


map(map<0)=0.0;
map(map>1)=1.0;
   
if (nargout>0) cmap=map; end;

return
end
