function cl_gray = cl_gray(m)
%CL_GRAY  color map
%   optimal size is 11 entries

%   Carsten Lemmen 20012-07-18

cl_register_function();

if nargin < 1
   m = size(get(gcf,'colormap'),1);
end


if m==1 
   error('Colormap length must be greater than 1');
end

factor=1.2;
map=gray(round(m*factor));
offset=ceil((factor-1)/2.0*m);
map=map(offset:offset+m-1,:);

 
if (nargout>0) cl_gray=map; end;

return
end
