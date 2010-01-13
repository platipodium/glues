function [currentargs,remainingargs] = clp_arguments(varargin)

if nargin<2
    warning('Not enough arguments');
    return;
end

if nargin>2
    warning('TODO');
    return
end

% Set default values to all current arguments
cargs=varargin{2};
ncargs=length(cargs);
for i=1:ncargs
  if iscell(cargs{i})
      args.name{i}=cargs{i}{1};
  else 
      args.name{i}=cargs{i};
  end
  
  args.size{i}=length(cargs{i});
  if (args.size{i} == 2)
    args.value{i}=cargs{i}{2};
  else
    args.value{i}=1;
  end
end


rargs=varargin{1};
nargs=length(rargs);

irarg=1;
remargs={};
for iarg=1:nargs
  if ~ischar(rargs{iarg}(1)) continue; end
    
  for i=1:length(rargs{iarg})
    found=strncmpi(rargs{iarg},args.name,i);
    if sum(found)>1 continue; end
    
    if sum(found)==1 found=find(found);
    else found=0;
    end
    break;
    
  end
  
  if ~found 
    remargs{irarg}=rargs{iarg};
    irarg=irarg+1;
    continue;
  end
      
  if args.size{found}==2
      args.value{found}=rargs{iarg+1};
      iarg=iarg+1;
  end
  
  %case 'pat'
  %    drawmode='patch';
  %    colpath=varargin{iarg+1};
  %    iarg=iarg+1;
  %  case 'lin'
  %    drawmode='line';
  %    colpath=varargin{iarg+1};
  %    iarg=iarg+1;

end


if nargout>0
  remainingargs=remargs;
  currentargs.value=args.value;
  currentargs.name=args.name;
  currentargs.length=length(args.value);
end

return
end