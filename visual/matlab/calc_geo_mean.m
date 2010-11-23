function meanval=calc_geo_mean(lat,value)
% meanval=CALC_GEO_MEAN(lat,value)
%
% This function calculates the latitude-weighted mean of the value,
% excluding latitude out-of-range and NaN values

cl_register_function();

if numel(lat)==numel(value)
  nlat=numel(lat);
  lat=reshape(lat,nlat,1);
  value=reshape(value,nlat,1);
  valid=find(isfinite(value) & lat>=-90 & lat<=90);
elseif numel(lat)=size(value,1);
  valid=find(lat>=-90 & lat<=90);  
elseif numel(lat)=size(value,2);
  valid=find(lat>=-90 & lat<=90);  
else
    error('Dimension mismatch. This case not handled yet, please implement');
end
  
if length(valid)<1 
    meanval=NaN;
else
  weight=cosd(lat);
  sweight=sum(weight(valid));

  meanval=sum(weight(valid).*value(valid))/sweight;
end
  
return;
end
