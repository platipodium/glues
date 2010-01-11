function meanval=calc_geo_mean(lat,value)
% meanval=CALC_GEO_MEAN(lat,value)
%
% This function calculates the latitude-weighted mean of the value,
% excluding latitude out-of-range and NaN values

cl_register_function();

nlat=numel(lat);
lat=reshape(lat,nlat,1);
value=reshape(value,nlat,1);


valid=find(isfinite(value) & lat>=-90 & lat<=90);
if length(valid)<1 
    meanval=NaN;
else
  weight=cosd(lat);
  sweight=sum(weight(valid));

  meanval=sum(weight(valid).*value(valid))/sweight;
end
  
return;
end
