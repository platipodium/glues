function plot_multi_format(varargin)
% PLOT_MULTI_FORMAT saves the current figure in the default formats pdf and png
% PLOT_MULTI_FORMAT(hdl) saves the figure with handle hdl in the default formats
% PLOT_MULTI_FORMAT(hdl,basename) saves the figure with handle hdl in the default
%   formats with file basename 
% PLOT_MULTI_FORMAT(hdl,basename,extensionlist) saves the figure in formats given
%  in extensionlist

% Carsten Lemmen 
% GKSS-Forschungzentrum Geesthacht GmbH

cl_register_function();

if (nargin<1) fig=gcf; else fig=varargin{1}; end
if (nargin<2) basename='figure'; else basename=varargin{2}; end
if (nargin<3) extensions={'pdf','png'}; 
else 
  for iarg=3:nargin extensions{iarg-2}=varargin{iarg}; end
end
n=length(extensions);

dozip=0;
for i=1:n
  set(gcf,'PaperPositionMode','auto');
  ext=lower(extensions{i});
  switch (ext)
    case 'tif', ext='tiff'; extensions{i}='tiff';
    case 'jpg', ext='jpeg'; extensions{i}='jpeg';
    case 'zip', dozip=1;  continue;
    otherwise
  end
  try
    switch (ext)
      case {'eps'}
        print(['-tiff -d' ext 'c2'],'-painters',[basename '.' ext]); % -r600
      case {'pdf','svg'}
        print(['-d' ext],'-painters',[basename '.' ext]); % -r600
      case {'tiff','jpeg','ppm','png'}
        print(['-d' ext],'-r600',[basename '.' ext]); 
      otherwise
        print(['-d' ext],[basename '.' ext]);      
    end
  end
end

offset=0;
if (dozip==1)
  ziplist{1}={[basename '.zip']};
  for i=1:n
    ext=lower(extensions{i});
    if strcmp(ext,'zip'); offset=1; continue; end
    ziplist{i-offset}={[basename '.' ext]};
  end
  zip([basename '.zip'],ziplist{:});
end

return;
%EOF
