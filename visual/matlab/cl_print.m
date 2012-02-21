function cl_print(varargin)
%
arguments = {...
  {'extension','pdf'},...
  {'resolution',300},... 
  {'fig',NaN},...
  {'name','test'},...
  {'noshrink',0},...
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
pos=get(fig,'Position');
set(fig,'PaperType','A4','PaperPositionMode','auto','PaperUnits','points');
ppos=get(fig,'PaperPosition');
psize=get(fig,'PaperSize');

if ~noshrink
  set(fig,'PaperPositionMode','Manual','PaperOrientation','portrait');
  set(fig,'PaperPosition',ppos.*[0 0 psize(1)/ppos(3) psize(1)/ppos(3)]+[-20 -0 -40 -40]);
  ppos=get(fig,'PaperPosition');
  set(fig,'PaperSize',psize.*[1 0]+ppos(3:4).*[0 1])
end

%psize=get(gcf,'PaperSize');
%if psize(2)<psize(1) set(fig,'PaperOrientation','rotated')
%else set(fig,'PaperOrientation','portrait');
%closeend
% 
% ax=findobj(gcf,'type','axes');
% for i=1:length(ax);
%   axes(ax(i));
%   apos=get(gca,'Position');
%   axlim=get(gca,'XLim');
%   aylim=get(gca,'YLim');
%   axw=axlim(2)-axlim(1);
%   ayw=aylim(2)-aylim(1);
%   t=findobj(gca,'-property','position','type','text');
%   tpos=cell2mat(get(t,'Position'));
%   ext=cell2mat(get(t,'Extent'));
%  
%   b=[min([ext(:,1); tpos(:,1)]) ...
%           min([ext(:,2); tpos(:,2)]) ...
%           max([ext(:,1)+ext(:,3); tpos(:,1)]) ...
%           max([ext(:,2)+ext(:,4); tpos(:,2)])];
%       
%   bpos=apos(1)-(axlim(1)-b(1))*apos(3)/axw;
%   
% end

%pos=cell2mat(get(ax,'Position'));

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
