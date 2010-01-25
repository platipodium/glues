function [values]=cl_get_variable(expression,files)

if ~exist('expression','var') expression='Density'; end
if ~exist('files','var') files='results.mat'; end

data=load(files);


%% Evaluate combined expressions
switch (lower(expression))
    case 'population_size', expression='population_density * area';
    otherwise vars{1}=expression;
end

rem=expression;
ntok=1;
ops=[];
while (~isempty(rem))
  [tok,rem]=strtok(rem,'*/+-()');
  vars{ntok}=strrep(tok,' ','');
  if ~isempty(rem) ops(ntok)=char(rem(1)); end
  ntok=ntok+1;
end

nvar=length(vars);


for ivar=1:nvar
  var=vars{ivar};
  avars{ivar}='';
  
   
%% Find alternate source variable names
  switch (lower(var))
      case 'population_density', avars{ivar}='Density'; 
      case 'density', avars{ivar}='population_density'; 
      otherwise, if (var(1)<'a') avars{ivar}=lower(var); end
  end
  
  if (~isfield(data,vars{ivar}) && ~isfield(data,avars{ivar}) && length(data)==1)
    data=eval(['data.' char(fieldnames(data)) ';']);
  end
  
  if (isfield(data,vars{ivar})) vals{ivar}=eval(['data.' vars{ivar}]);
  elseif (isfield(data,avars{ivar})) vals{ivar}=eval(['data.' avars{ivar}]);
  else
      warning('Variable not found in result file');
      values=-1;
      return
  end
end

%% Process arithmetic expressions
val=vals{1};
for i=1:length(ops)
  s1=size(vals{i});
  s2=size(vals{i+1});

  vals{i}=repmat(vals{i},ceil(s2./s1)); 
  vals{i+1}=repmat(vals{i+1},ceil(s1./s2)); 

  val=eval(sprintf('vals{%d} .%c vals{%d};',i,ops(i),i+1));
end


%% Return result
if nargout>0
  values=vals{1};
end

return;
end
