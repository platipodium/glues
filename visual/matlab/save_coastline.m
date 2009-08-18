function save_coastline(projection)

cl_register_function();

if ~exist('projection','var') projection='miller'; end
latlim=[-90,90];
lonlim=[-180,180];

fig=figure(21);
clf reset;
m_proj(projection,'lat',latlim,'lon',lonlim);
m_coast('line','color',[0.8 0.8 0.8]);
axischildren=get(gca,'Children');
coastline=axischildren(5);
x=get(coastline,'XData');
y=get(coastline,'YData');
n=length(x);

fprintf('Found %d data points, saving to file ',n);
fid=fopen('coastline.tsv','w');
for i=1:n 
  fprintf(fid,'%7.2f %7.2f\n',x,y); 
  if (mod(i,30)==0) fprintf('.'); end;
end
fprintf(' done\n');
fclose(fid);
close(fig);

end
