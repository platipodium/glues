function akp_plasim_timeseries(varargin)

data=clp_nc_timeseries('file','data/Pakistantotprec_0_11k_JJAS.nc',...
    'xcoord','x','ycoord','y','latlim',3,'lonlim',3,'var','var4',...
    'nosum',1,'notitle',1,'timeunit','day','fig',0)

set(gca,'XDir','reverse');
ylabel('Precipitation (mm/day)');
title('Plasim 11k Precipitation over North Pakistan');

return
end