function shape=cl_shp2mat(filename)

if nargin<1 error('Need filename as argument'); end
if ~exist(filename,'file'); error('File does not exist'); end


[filedir filebase fileext] = fileparts(filename);
shape=shaperead(filename);
save(fullfile(filedir,filebase),'shape');

return;
end
