function phdl=cl_ellipse(x0,y0,xwidth,ywidth,varargin)

  if nargin<5
    varargin{1}='k';
  end
  
  if ~exist('x0','var') x0=0; end
  if ~exist('y0','var') y0=0; end
  if ~exist('xwidth','var') xwidth=1; end
  if ~exist('ywidth','var') ywidth=1; end
      
  
  circle=rsmak('circle');
  ellipse=fncmb(circle,[xwidth 0;0 ywidth]);
  ellipse=fncmb(ellipse,[x0;y0]);
  pellipse=fnplt(ellipse);
  phdl=patch(pellipse(1,:),pellipse(2,:),varargin{:});
  return;
end
