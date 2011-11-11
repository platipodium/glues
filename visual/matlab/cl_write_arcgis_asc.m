function d=cl_write_arcgis_asc(d,varargin)
% Writes raster data for ARCGIS  as ascii,

% This format is expected in structure d
% ncols         392
% nrows         341
% xllcorner     25.228034779539
% yllcorner     -22.426731220461
% cellsize      0.02
% NODATA_value  -9999
% <data>

arguments = {...
  {'latlim',[-inf inf]},...
  {'lonlim',[-inf inf]},...
  {'nodata',NaN},... 
  {'file','test.asc'},... 
  {'noprint',0},...
  {'center',0},...
  {'xtype','int'},...
};

cl_register_function();

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length 
  eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); 
end

fid=fopen(file,'w');
fprintf(fid,'ncols\t%d\r\n',length(d.lon));
fprintf(fid,'nrows\t%d\r\n',length(d.lat));
if center
  fprintf(fid,'xllcenter\t%f\r\n',min(d.lon));
  fprintf(fid,'yllcenter\t%f\r\n',min(d.lat));
else
  fprintf(fid,'xllcorner\t%f\r\n',min(d.lon));
  fprintf(fid,'yllcorner\t%f\r\n',min(d.lat));
end
fprintf(fid,'cellsize\t%f\r\n',abs(d.lat(2)-d.lat(1)));
fprintf(fid,'NODATA_value\t%d\r\n',nodata);

d.data(isnan(d.data))=nodata;

if strcmp(xtype,'int')
  for i=1:size(d.lat,2)
    fprintf(fid,'%2d ',d.data(i,1:end-1));
    fprintf(fid,'%2d\r\n',d.data(i,end));
  end
elseif strcmp(xtype,'float')
  for i=1:size(d.lat,2)
    fprintf(fid,'%f ',d.data(i,1:end-1));
    fprintf(fid,'%f\r\n',d.data(i,end));
  end
else
  error('xtype argument must be float or int');
end

fclose(fid);
return
end


