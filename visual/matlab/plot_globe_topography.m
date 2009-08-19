function plot_globe_topography

cl_register_function();

load('topo.mat','topo','topomap1');

[x,y,z] = sphere(50);

cla reset
axis square off
props.AmbientStrength = 0.3;
props.DiffuseStrength = 1.0;
props.SpecularColorReflectance = .3;
props.SpecularExponent = 20;
props.SpecularStrength = 1;
props.FaceColor= 'texture';
props.EdgeColor = 'none';
props.FaceLighting = 'phong';
props.Cdata = topo;
surface(x,y,z,props);
light('position',[-1 0 1]);
light('position',[-1.5 0.5 -0.5], 'color', [.6 .2 .2]);
view(3);

colormap(topomap1);
return;
end
