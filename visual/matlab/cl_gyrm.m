function cl_gyrm = cl_gyrm(m)
%CL_GYRM  color map
%   optimal size is 17 entries

%   Carsten Lemmen 20012-07-18

cl_register_function();

if nargin < 1
   m = size(get(gcf,'colormap'),1);
end


if m==1 
   error('Colormap length must be greater than 1');
end

bp=[ ...
[7 31 0 6]; ...
[99 96 64 5]; ...
[94 0 9 2 ]; ...
[48 0 24 3]; ...
[85 55 88 NaN]];

i=1;
blue =linspace(bp(i,3),bp(i+1,3),bp(i,4)+1);
green=linspace(bp(i,2),bp(i+1,2),bp(i,4)+1);
red  =linspace(bp(i,1),bp(i+1,1),bp(i,4)+1);

for i=2:size(bp,1)-1
  c=linspace(bp(i,3),bp(i+1,3),bp(i,4)+1);
  blue=horzcat(blue,c(2:end));
  c=linspace(bp(i,2),bp(i+1,2),bp(i,4)+1);
  green=horzcat(green,c(2:end));
  c=linspace(bp(i,1),bp(i+1,1),bp(i,4)+1);
  red=horzcat(red,c(2:end));
end


if m~=17
  xi=1:16/(m-1):17;
  blue=interp1(1:17,blue,xi);
  red=interp1(1:17,red,xi);
  green=interp1(1:17,green,xi);
end

map=[red',green',blue']/100.0;

 
if (nargout>0) cl_gyrm=map; end;

return
end
