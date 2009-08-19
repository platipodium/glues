function xget_map_coordinates

cl_register_function();

figure(1);
clf reset;

latlim=[28,51];
lonlim=[-10,40];

m_proj('miller','lat',latlim,'lon',lonlim);
m_coast;
m_grid;
hold on;

while (ishandle(1))
  try 
      d=ginput;
  catch
      break;
  end %MATLAB:ginput:FigureDeletionPause
      
  x=d(:,1);
  y=d(:,2);
  plot([x;x(1)],[y;y(1)],'r-');
  [lo,la]=m_xy2ll(x,y);
  fprintf('[[');
  fprintf('%.2f ',lo');
  fprintf('];[');
  fprintf('%.2f ',la');
  fprintf(']]\n');
  
end


return
end
