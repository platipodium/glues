function yellowmap = yellow(m)
%YELLOW  color map
%   YELLOW(M) returns an M-by-3 matrix containing the continuous
%   colours from white to yellow
%   YELLOW, by itself, is the same length as the current figure's
%   colormap. If no figure exists, MATLAB creates one.
%

%   Carsten Lemmen 2009-06-2

cl_register_function();

if nargin < 1
   m = size(get(gcf,'colormap'),1);
end

if m==1 
   error('Colormap length must be greater than 1');
end

blue =[linspace(1,0,m)]';
red  =repmat(1,m,1);
green=repmat(1,m,1);

map=[red,green,blue];

if (nargout>0) yellowmap=map; end;

return
end
