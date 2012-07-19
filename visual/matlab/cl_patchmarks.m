function [hdl] = cl_patchmarks(x,y,varargin)
% Plots markers as patches

cl_register_function;

if isempty(x) x=[0.3 0.4 0.5]; y=[0 0.1 -0.1]; end

arguments = {...
  {'MarkerSize',10},...
  {'MarkerFaceColor','r'},...
  {'MarkerEdgeColor','k'},...
  {'MarkerEdgeAlpha',1},...
  {'MarkerFaceAlpha',1}
  {'Marker','d'}
};

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





end

