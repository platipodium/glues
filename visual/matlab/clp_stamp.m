function stamp_handle=clp_stamp(varargin)

error('Nonfunctional routine, await further development');

arguments = {...
  {'ax',NaN},...
  {'xpos',NaN},...
  {'ypos',NaN},...
  {'color',repmat(0.5,1,3)},...
  {'visible',1}
};

cl_register_function;

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); end
 
if isnan(ax) ax=gca; end
if isnan(xpos) xpos=min(get(ax,'Xlim')); end
if isnan(ypos) ypos=min(get(ax,'Ylim')); end
    
v=cl_get_version;
stamptext=sprintf('%s, created by %s (%s)',v.copy,v.file,v.version);
stamp=text(ax,xpos,ypos,stamptext);
set(stamp,'Color',color,'Interpreter','none','VerticalAlignment','bottom');
if (visible==0) set(stamp,'Visible','off'); end

if nargout>0 stamp_handle=stamp; end

return
end