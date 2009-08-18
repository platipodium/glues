function plot_map_projections

cl_register_function();

latlim=[-90,90];
lonlim=[-18,180];

fignum=figure(1);

p={'Stereographic','Orthographic','Azimuthal Equal-area','Azimuthal Equidistant','Gnomonic'...
  ,'Satellite','Albers Equal-Area Conic','Lambert Conformal Conic','Mercator','Miller'...
  ,'Equidistant Cylindrical','Oblique Mercator','Transverse Mercator','Sinusoidal'...
  ,'Gall-Peters','Hammer-Aitoff','Mollweide','UTM'}

n=length(p);
ncol=4;
nrow=6;

for i=1:n
    row=round((i-1)/ncol)+1;
    col=mod(i,(ncol+1));
    fprintf('%d %d %d %s\n',i,col,row,p{i});
    
    %a(i)=axes('position',[(col-1)/ncol (row-1)/nrow 1/ncol 1/nrow ]);
    figure(i);
    m_proj(p{i});
    m_coast;
    m_grid('box','on','XTickLabel',[],'YTickLabel',[]);
    title(p{i});
    text(0.9,0.9,num2str(i),'FontSize',30);
end;        
