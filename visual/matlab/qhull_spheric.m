function qhull_spheric(lat,lon)

cl_register_function();

if (~exist('lat','var'))
  lat=[5 60 -30];
  lon=[0 150 101];
  clf
  m_proj('miller','lat',[-90 90],'lon',[-180,180]);
  %m_proj('miller','lat',[18 30],'lon',[60 70]);
  m_coast('line','color',[0.8 0.8 0.8]);
  m_grid;
end

n=length(lat);

for a=1:n-2
  m_line(lon(a),lat(a),'Marker','diamond');
  for b=a+1:n-1
    m_line(lon(b),lat(b),'Marker','diamond');

    % Konstruiere Mittelsenkrechten, i.e. a great circle through     
    [r,lo,la]=m_lldist(lon([a,b]),lat([a,b]),100);
    m_line(lo,la);

    [s,a2b,b2a] = m_idist(lon(a),lat(a),lon(b),lat(b));
    [xlo,xla,x2a] = m_fdist(lon(a),lat(a),a2b,s/2);
    
    for c=b+1:n
      m_line(lon(c),lat(c),'Marker','diamond');
      
      % Konstruiere Mittelsenkrechten, i.e. a great circle through     
      [r,lo,la]=m_lldist(lon([a,c]),lat([a,c]),100);
      m_line(lo,la);

      [s,a2c,c2a] = m_idist(lon(a),lat(a),lon(c),lat(c));
      [wlo,wla,w2a] = m_fdist(lon(a),lat(a),a2c,s/2);

      [zlo1,zla1,z1w] = m_fdist(wlo,wla,w2a+90,5E6);
      [ylo1,yla1,y1x] = m_fdist(xlo,xla,x2a-90,1E6);
      [zlo2,zla2,z2w] = m_fdist(wlo,wla,w2a-90,1E7);
      [ylo2,yla2,y2x] = m_fdist(xlo,xla,x2a+90,1E6);
      yzlo=[zlo1,zlo2,ylo1,ylo2];
      if zlo1>180 zlo1=zlo1-180; end;
      if zlo2>180 zlo2=zlo2-180; end;
      if ylo1>180 ylo1=ylo1-180; end
      if ylo2>180 ylo2=ylo2-180; end
        
      [r,ylog,ylag]=m_lldist([ylo1,ylo2],[yla1,yla2],1000);
      [r,zlog,zlag]=m_lldist([zlo1,zlo2],[zla1,zla2],1000);
      m_idist(ylog,ylag,zlog,zlag);
      
      m_line([xlo,wlo],[xla,wla],'Color','r');
      m_line([zlo1,zlo2,ylo1,ylo2],[zla1,zla2,yla1,yla2],'Color','b','Linestyle','none','Marker','diamond');
      m_line(zlog,zlag,'Color','g');
      m_line(ylog,ylag,'Color','g');
  end
end




%Most of the calculations are the same as used to draw the voronoi diagram. First of all, for each set of three points
% , I calculate the orthocentre of the three points. That is, I calculate the point which is equidistant from all three
%  points. Then, for each orthocentre x, I check all the points in P, to make sure that the three points used to find x 
%    are the three closest points of P to x. If they are not, I reject x from consideration. It is not needed to draw 
%    the voronoi diagram. Then, for each orthocentre x not rejected, I draw lines between the points that were used to
%      find this orthocentre. Roughly speaking, that's it.
return

      while (1)
        d=d+i*scale*1E3;
        [zlo,zla,z2w] = m_fdist(wlo,wla,w2a+90,d);
        [ylo,yla,y2x] = m_fdist(xlo,xla,x2a-90,d);
        m_line(zlo,zla,'Marker','.','Color','r');
        m_line(ylo,yla,'Marker','.','Color','g');

        r=m_lldist([zlo,ylo],[zla,yla]);
        fprintf('%5d %5d %5d\n',r,r1,rmin);
        if r<rmin rmin=r; 
          i=i+1;
        end
        if (rmin<scale) 
          i=0;
          d=d-1*scale*1E3;
          scale=scale/10; 
        end;
        if (scale<1) | (r==r1)  break; end;
        r1=r;
      end       
      zlo,ylo,zla,yla;
      
    end    
