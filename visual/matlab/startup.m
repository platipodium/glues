%
newpath=pwd;
addpath(genpath(newpath));
fprintf('Added %s and subdirectories to MATLAB search path\n',newpath);

newpath=fullfile(getenv('HOME'),'matlab','m_map');
if exist(newpath,'file')
  addpath(newpath);
  fprintf('Added %s to MATLAB search path\n',newpath);
end

if ~exist('m_proj')
  warning('M_PROJ mapping toolbox not found, please install with command ''get_mproj''');
end