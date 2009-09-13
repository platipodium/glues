function [xc,yc]=distribute_around(x,y,n,dist)
% [XOUT,YOUT]=DISTRIBUTE_AROUND(XIN,YIN,N,DISTANCE)
%
% distributes around a point (x,y) 

cl_register_function();

xc=NaN;
yc=NaN;

offset=45;

if (n<4) % circle

  angle=360./n;
  for i=1:n
    xc(i)=x+dist*cos(pi/180*(angle*(i-1)+offset));
    yc(i)=y+dist*sin(pi/180*(angle*(i-1)+offset));
  end
else
    angle=360./(n-1);
    xc(1)=x; yc(1)=y;
   for i=2:n
    xc(i)=x+dist*cos(pi/180*(angle*(i-2)+offset));
    yc(i)=y+dist*sin(pi/180*(angle*(i-2)+offset));
   end
end
   
  
% else if n<8 circle with dot

