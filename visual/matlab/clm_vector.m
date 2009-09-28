function p=clm_vector(lon,lat,varargin)

% plots a vector along lon/lat with triangle arrow at end

if length(lat)<2 | length(lon)<2
    error('Need at least 2 points');
end

if nargin>0
  p=m_line(lon,lat);
else 
  p=m_line(lon,lat);
end


[x,y]=m_ll2xy(lon(end-1:end),lat(end-1:end));
dx=x(2)-x(1);
dy=y(2)-y(1);
r=sqrt(dx*dx+dy*dy);


sina=dy/r;
alpha=asin(sina);
if (dx<0) alpha=pi-alpha; end
r=0.01;

alpha,r,dx,dy

y1=y(2)+r*sin(pi+alpha+pi/6);
y2=y(2)+r*sin(pi+alpha-pi/6);
x1=x(2)+r*cos(pi+alpha+pi/6);
x2=x(2)+r*cos(pi+alpha-pi/6);

%plot([x1,x2,x(1),x(2)],[y1,y2,y(1),y(2)],'m.');


p1=patch([x2,x(2),x1],[y2,y(2),y1],'b','EdgeColor','none','FaceColor',get(p,'Color'));

%if nargout==0 delete(p); end

return
end