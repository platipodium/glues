function cl_print(varargin)
%
arguments = {...
  {'extension','png'},...
  {'resolution',300},... 
  {'fig',NaN},...
  {'name','figure'},...
};

cl_register_function;

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length 
  lv=length(a.value{i});
  if (lv>1 & iscell(a.value{i}))
    for j=1:lv
      eval( [a.name{i} '{' num2str(j) '} = ''' char(clp_valuestring(a.value{i}(j))) ''';']);         
    end
  else
    eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); 
  end
end

if isnan(fig) fig=gcf; end
set(fig,'PaperPositionMode','auto');

if ~iscell(extension) extension={extension}; end

dozip=0;
for ir=1:length(resolution)
  res=resolution(ir);
  for ie=1:length(extension);
    f=lower(extension{ie});
    switch (f)         
      case 'tif', extension{ie}='tiff';
      case 'jpg', extension{ie}='jpeg';
      case 'zip', dozip=1;  continue;
      otherwise
    end
    if length(resolution)>1
      fullname=[name '_' num2str(res) '.' extension{ie}];
    else
       fullname=[name '.' extension{ie}];
    end   
    try
      switch (f)
        case {'eps'}
          print(['-tiff -d' extension{ie} 'c2'],'-painters',fullname);
        case {'pdf','svg'}
          print(['-d' extension{ie}],'-painters',fullname); 
        case {'tiff','jpeg','ppm','png'}
          print(['-d' extension{ie}],['-r' num2str(res)],fullname); 
        otherwise
          print(['-d' extension{ie}],['-r' num2str(res)],fullname);      
      end
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
