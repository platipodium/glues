% Prepares new geographic grid for China


clp_nc_variable('file','../../examples/simulations/grid_china/gridchina.nc',...
    'var','farming','reg','eng','marble',0,...
    'rpath','regionpath_0.5_grid_china','timelim',[-6000 1000],'timestep',20,...
'treshold',0.5)

%[lonlim,latlim] = cl_geographic_limits('countr','China');
%cl_create_regions('lat',latlim,'lon',lonlim);

