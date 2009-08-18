function [xout,yout] = dislocate_slightly(xin,yin,crit)

cl_register_function();

n=length(xin);
x=xin;
y=yin;

for nloop=1:3
for i=1:n-1
 dist=sqrt( (x(i+1:n)-x(i)).^2 + (y(i+1:n)-y(i)).^2);
 j=find(dist<crit);
 if ~isempty(j)
     if isvert(j) j=vertcat(i,i+j);
     else j=horzcat(i,i+j);
     end
     xc=mean(x(j));
     yc=mean(y(j));
     [xd,yd]=distribute_around(xc,yc,length(j),crit);
     x(j)=xd;
     y(j)=yd;
     
 end
 
end
end
xout=x;
yout=y;

end
