function akp_plasim_timeseries(varargin)

% Info on plasim lat/lon
% ncdump -v lat,lon plasim_11k.nc
% lon = 0, 5.625, 11.25, 16.875, 22.5, 28.125, 33.75, 39.375, 45, 50.625, 
%    56.25, 61.875, 67.5, 73.125, 78.75, 84.375, 90, 95.625, 101.25, 106.875, 
%     112.5, 118.125, 123.75, 129.375, 135, 140.625, 146.25, 151.875, 157.5, 
%     163.125, 168.75, 174.375, 180, 185.625, 191.25, 196.875, 202.5, 208.125, 
%     213.75, 219.375, 225, 230.625, 236.25, 241.875, 247.5, 253.125, 258.75, 
%     264.375, 270, 275.625, 281.25, 286.875, 292.5, 298.125, 303.75, 309.375, 
%     315, 320.625, 326.25, 331.875, 337.5, 343.125, 348.75, 354.375 ;
% 
%  lat = -85.76059, -80.26878, -74.74454, -69.21297, -63.67863, -58.14296, 
%     -52.60653, -47.06964, -41.53246, -35.99508, -30.45755, -24.91993, 
%     -19.38223, -13.84448, -8.306703, -2.768903, 2.768903, 8.306703, 13.84448, 
%     19.38223, 24.91993, 30.45755, 35.99508, 41.53246, 47.06964, 52.60653, 
%     58.14296, 63.67863, 69.21297, 74.74454, 80.26878, 85.76059 ;
% }

%% Western rivers
% In the topographic map (clp_topography.m), we see that north pakistan is
% covered by one gridcell (centered on 73.13E 35.99N), this corresponds to
% influx to western rivers (but some is coming from the adjacant cells to
% the left (Kabul river) and right (Uper Indus).  corresponding netcdf
% gridcell is [x=2 y=2], i.e. latlim=3 and lonlim=3 for the routine below.

%[data,hdl]=clp_nc_timeseries('file','data/Pakistantotprec_0_11k_JJAS.nc',...
%    'xcoord','x','ycoord','y','latlim',3,'lonlim',3,'var','var4',...
%    'nosum',1,'notitle',1,'timeunit','day','fig',0,'nobar',1,'lim',[0 inf])

[data,hdl]=clp_nc_timeseries('file','data/Pakistan_sst_run_totprec_0_11k_JJAS.nc',...
    'xcoord','lon','ycoord','lat','latlim',[35 36],'lonlim',[72 74],'var','var4',...
    'nosum',1,'notitle',1,'timeunit','day','fig',0,'nobar',1,'lim',[0 inf])

set(gca,'XDir','reverse');
ylabel('Precipitation (mm/day)');
title('Plasim 11k Precipitation over North Pakistan (Western rivers)');
%set(hdl.p,'edgecolor','b','barwidth',0.00001)

time=get(hdl.p,'XData');
rain=get(hdl.p,'YData');

m200=movavg(time,rain,200);
hold on;
plot(time,m200,'r:','LineWidth',3);


%% Eastern rivers
% There is one gridcell covering the Punjab [x=2,y=1], but possibly also
% influx through the adjacent cells [3,1] and [3.2]. Problem: parts of this
% rainfall go into Ganges and Tibet Plateau.

% Todo: exercise for Aurangzeb

return
end