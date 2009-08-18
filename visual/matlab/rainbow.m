function rainbowmap = rainbow(m)
%RAINBOW rainbow color map
%   RAINBOW(M) returns an M-by-3 matrix containing repeated use
%   of seven colors: magenta, blue, cyan, green, yellow, orange, red.
%   RAINBOW, by itself, is the same length as the current figure's
%   colormap. If no figure exists, MATLAB creates one.
%

%   Carsten Lemmen 2008-09-15

cl_register_function();

if nargin < 1
   m = size(get(gcf,'colormap'),1);
end

R = [2/3 0 2/3; 1 0 1; 1 2/3 1; 0 0 1; 0 1 1; 2/3 1 1; 0 1 0; 1 1 2/3; 1 1 0; 2/3 2/3 0; 1 1/2 0; 1 2/3 1/3; 1 0 0; 1/2 0 0];
nr = length(R);

if m==1 
   error('Colormap length must be greater than 1');
end


if m<nr
    ir=floor([0:m-1]*(nr-1)/(m-1)+1);
    map=R(ir,:);
else
  nr = size(R,1);
  ng=nr-1;

  map=zeros(m,3);
  
  for ir=1:ng
    im=[(ir-1)*floor(m/ng)+1:ir*ceil(m/ng)];
    nm=length(im);
  
    Rdiff(ir,:)=R(ir+1,:)-R(ir,:);
  
    for j=1:3
      if Rdiff(ir,j)==0 map(im,j)=R(ir,j); 
    %elseif R(ir,j)<R(ir+1,j) map(im,j)=[R(ir,j):1./(nm-1):R(ir+1,j)];
    %else   map(im,j)=[R(ir,j):-1./(nm-1):R(ir+1,j)];
      else map(im,j)=[R(ir,j):Rdiff(ir,j)./(nm-1):R(ir+1,j)]';
      end
    end
  
    ngmax=ng*round(m/ng);
    for ir=ngmax+1:m
      map(ir,:)=R(nr,:);
    end
end
end

if any(any(isnan(map)))
    error('Map bug created NaN, please choose different size');
end

if (nargout>0) rainbowmap=map; end;

return
end
