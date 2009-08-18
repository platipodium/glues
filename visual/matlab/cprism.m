function map = cprism(m)
%CPRISM  CPrism color map.
%   CPRISM(M) returns an M-by-3 matrix containing repeated use
%   of six colors: red, orange, yellow, green, blue, violet.
%   The default value of M is the length of the current colormap.
%
%   CPRISM, with no input or output arguments, changes the colors
%   of any line objects in the current axes to the prism colors.
%
%   COLORMAP, PRISM.

%   Carsten Lemmen <carsten.lemmen@gkss.de>

cl_register_function();

if nargin + nargout == 0
   h = get(gca,'child');
   m = length(h);
elseif nargin == 0
   m = size(get(gcf,'colormap'),1);
end

% R = [red; orange; yellow; green; blue; violet]
R = [1 0 0; 0 0 1; .5 .5 0; 0 .5 .5; .5 0 .5; 0 0 .5];
% Generate m/6 vertically stacked copies of r with Kronecker product.
e = ones(ceil(m/6),1);
R = kron(e,R);
R = R(1:m,:);

if nargin + nargout == 0
   % Apply to lines in current axes.
   for k = 1:m
      if strcmp(get(h(k),'type'),'line')
         set(h(k),'color',R(k,:))
      end
   end
else
   map = R;
end
