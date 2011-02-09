function plantagomap = clc_plantago(m)
%PLANTAGO  color map
%   PLANTAGO(M) returns an M-by-3 matrix containing the continuous
%   colours from blue to white to red
%   PLANTAGO, by itself, is the same length as the current figure's
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

red  =linspace(0.4,0.984,m)';
green=linspace(0.055,1,m)';
blue =linspace(0.008,0.51,m)';


map=[red,green,blue];

if (nargout>0) plantagomap=map; end;

return
end
