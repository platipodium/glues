function greenredmap = greenred(m)
%GREENRED  color map
%   GREENRED(M) returns an M-by-3 matrix containing the continuous
%   colours from dark green to yellow to dark red
%   GREENRED, by itself, is the same length as the current figure's
%   colormap. If no figure exists, MATLAB creates one.
%

%   Carsten Lemmen 2010-05-17

cl_register_function();

if nargin < 1
   m = size(get(gcf,'colormap'),1);
end


if m==1 
   error('Colormap length must be greater than 1');
end


dkgreen=[0.1    0.3    0.2  1]; % pos 1
brgreen = [0 1 0 20]; % pos 20 
yellow = [1 1 0 40]; % pos 40
brred = [1 0 0 60] ; % pos 60
dkred = [0.5 0 0 64]; % pos 64

%if (m~=64)
  brgreen(4)=ceil((1.0*brgreen(4)*m)/64);
  yellow(4)=ceil((1.0*yellow(4)*m)/64);
  brred(4)=ceil((1.0*brred(4)*m)/64);
  dkred(4)=ceil(m);
%end


red=[linspace(dkgreen(1),brgreen(1),brgreen(4)),...
  linspace(brgreen(1),yellow(1),yellow(4)-brgreen(4)),...
  linspace(yellow(1),brred(1),brred(4)-yellow(4)),...
  linspace(brred(1),dkred(1),dkred(4)-brred(4))];


green=[linspace(dkgreen(2),brgreen(2),brgreen(4)),...
  linspace(brgreen(2),yellow(2),yellow(4)-brgreen(4)),...
  linspace(yellow(2),brred(2),brred(4)-yellow(4)),...
  linspace(brred(2),dkred(2),dkred(4)-brred(4))];

blue=[linspace(dkgreen(3),brgreen(3),brgreen(4)),...
  linspace(brgreen(3),yellow(3),yellow(4)-brgreen(4)),...
  linspace(yellow(3),brred(3),brred(4)-yellow(4)),...
  linspace(brred(3),dkred(3),dkred(4)-brred(4))];

map=[red',green',blue'];

if (nargout>0) greenredmap=map; end;

return
end
