function hotcoldmap = hotcold(m)
%HOTCOLD  color map
%   HOTCOLD(M) returns an M-by-3 matrix containing the continuous
%   colours from blue to white to red
%   HOTCOLD, by itself, is the same length as the current figure's
%   colormap. If no figure exists, MATLAB creates one.
%

%   Carsten Lemmen 2009-02-23

cl_register_function();

if nargin < 1
   m = size(get(gcf,'colormap'),1);
end


if m==1 
   error('Colormap length must be greater than 1');
end

blue =[linspace(1,1,ceil(m/2)) linspace(1,0,floor(m/2))]';
red  =[linspace(0,1,ceil(m/2)) linspace(1,1,floor(m/2))]';
green=[linspace(0,1,ceil(m/2)) linspace(1,0,floor(m/2))]';

map=[red,green,blue];

if (nargout>0) hotcoldmap=map; end;

return
end
