function [cbar]=cl_colorbar(varargin)

arguments = {...
  {'cbar',NaN},...
  {'cmap',NaN},...
  {'ax',NaN},...
  {'fig',NaN},...
  {'value',[0 0.7 1]},...
  {'label',NaN}
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
if isnan(ax) ax=gca; end

cbar=findobj(gcf,'-property','location','-and','tag','Colorbar','-or','tag','colorbar');
if isnan(cbar) | cbar==0 cbar=colorbar(ax); end

ncol=length(value)-1;

if isnan(cmap) cmap=jet(ncol); end

ylim=get(cbar,'Ylim');
ytick=get(cbar,'YTick');

set(cbar,'Ylim',[min(value) max(value)]);
set(cbar,'YTick',value);
if length(label)~=length(value)
  label=num2str(value');
end
set(cbar,'YTickLabel',label);

xlim=get(cbar,'XLim');
axes(cbar);
for i=1:ncol
  p(i)=patch([xlim fliplr(xlim)],value([i i i+1 i+1]),cmap(i,:));
end

return;


