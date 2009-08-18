function [ifound,nfound]=find_region_numbers(varargin)

cl_register_function();

% see also special version for 686 regions find_region_numbers_685 !

if nargin<1 return; end


% defaults
latlim=[-80,80];
neighlim=[];
nofind=[];
lonlim=[-180,180];
include=0;
regionpathfile='regionpath_685';

iarg=1;
while iarg<=nargin
  
  arg=lower(varargin{iarg});
  
  switch arg(1:3)
    case 'lat'
      latlim=varargin{iarg+1};
      iarg=iarg+1;
    case 'lon'
      lonlim=varargin{iarg+1};
      iarg=iarg+1;
    case 'eme'
      lonlim=[-15,42];
      latlim=[27,55];
      case 'chi'
          latlim=[18,40]; lonlim=[95,120];
     case 'sea'
          latlim=[12,44]; lonlim=[80,130];

    case 'med'
      lonlim=[-15,41];
      latlim=[31,53];
   case 'eur'
      lonlim=[-15,50];
      latlim=[18,63];
    case 'all'
    case 'wor'
    case 'exc'
      include=0;
    case 'nof'
       nofind=varargin{iarg+1};
    case 'inc'
      include=1;
    case 'nei'
      neighlim=varargin{iarg+1};
      iarg=iarg+1;
    case 'fil'
          regionpathfile=varargin{iarg+1};
          iarg=iarg+1;
    otherwise
      fprintf('Unknown keyword %s.',varargin{iarg});    
  end
  iarg=iarg+1;
end

load(regionpathfile);

if exist('region','var') & isstruct(region) 
  nreg=region.nreg; 
  regionpath=region.path;
end

ifound=[1:nreg];
nfound=nreg;

  
% TODO remove correction in lat/lon
regionpath(:,:,1)=regionpath(:,:,1)+0.5;
regionpath(:,:,2)=regionpath(:,:,2)+1.0;
% END TODO

%disp('Limits lon\in %d %d, lat \in %d %d',lonlim,latlim);

ifound=[];

if isempty(neighlim)  && include==1
  for i=1:nreg
    valid=find(regionpath(i,:,2)>-999);
    if all(   regionpath(i,valid,2)>latlim(1) ...
          & regionpath(i,valid,2)<latlim(2) ... 
          & regionpath(i,valid,1)>lonlim(1) ... 
          & regionpath(i,valid,1)<lonlim(2) );
    ifound=[ifound;i];
    end
  end 
elseif isempty(neighlim) && include==0
  for i=1:nreg
    valid=find(regionpath(i,:,2)>-999);
    if any(   regionpath(i,valid,2)>latlim(1) ...
          & regionpath(i,valid,2)<latlim(2) ... 
          & regionpath(i,valid,1)>lonlim(1) ... 
          & regionpath(i,valid,1)<lonlim(2) );
    ifound=[ifound;i];
    end
  end
elseif ~isempty(neighlim)
  for i=1:length(neighlim)
    ifound=[ifound;find(any(regionpath(:,:,3)==neighlim(i),2))];
  end
end

for i=1:length(nofind)
    ifound=ifound(find(ifound ~= nofind(i))); 
end;

nfound=length(ifound);

return
