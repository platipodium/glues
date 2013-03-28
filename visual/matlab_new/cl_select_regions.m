function [ifound,nfound,lonlim,latlim]=cl_select_regions(varargin)

cl_register_function();

arguments = {...
  {'latlim',[-inf,inf]},...
  {'lonlim',[-inf,inf]},...
  {'reg','lbk'},...
  {'rpath','regionpath_685'},...
  {'include',0},...
};

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length 
  eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); 
end


load(sprintf('%s.mat',rpath))
if exist('region','var') & isstruct(region) 
  nreg=region.nreg; 
  regionpath=region.path;
end

if all(isfinite([latlim,lonlim]))
 
  ifound=[];
  for i=1:nreg
    valid=find(regionpath(i,:,2)>-999);
    if any(   regionpath(i,valid,2)>latlim(1) ...
          & regionpath(i,valid,2)<latlim(2) ... 
          & regionpath(i,valid,1)>lonlim(1) ... 
          & regionpath(i,valid,1)<lonlim(2) );
      ifound=[ifound;i];
    end
  end  
  nfound=length(ifound);
  return
end

if isnumeric(reg) 
  ifound=reg;
  nfound=length(ifound);
  for i=1:nfound
    valid=find(regionpath(i,:,2)>-999);
    latlim=cl_minmax(regionpath(i,valid,2));
    lonlim=cl_minmax(regionpath(i,valid,1));
  end
else
  reg=lower(reg);
  switch reg(1:3)
    case 'old'
      lonlim=[-30,180];
      latlim=[-40,60];
    case 'cp1' % For CP paper with Gaillard
      lonlim=[-25,145];
      latlim=[-40,60];
    case 'afr'
      lonlim=[-20,60];
      latlim=[-40,20];
    case 'saf'
      lonlim=[10,52];
      latlim=[-36,-5];
    case 'cam'
      lonlim=[-110,-70];
      latlim=[0,30];
    case 'sam'
      lonlim=[-80,-20];
      latlim=[-60,15];
    case 'nam'
      lonlim=[-170,-50];
      latlim=[15,80];
    case 'usa'
      lonlim=[-125,-70];
      latlim=[10,50];
    case 'swa'
      % Southwest Asia from Near East to Indus Valley
      lonlim=[32 80];
      latlim=[18 40];
    case 'ivc'
      % Indus Valley Culture
      lonlim=[60 80];
      latlim=[20 40];
    case 'lbk'
      lonlim=[-10,42];
      latlim=[31,57];
    case 'trb'
      lonlim=[5,17];
      latlim=[49,58];
    case 'eme'
      lonlim=[-15,42];
      latlim=[27,55];
    case 'chi'
      latlim=[18,40]; lonlim=[95,122];
    case 'sea'
      latlim=[-12,23]; lonlim=[90,130];
    case 'med'
      lonlim=[-15,41];
      latlim=[31,53];
   case 'eur'
      lonlim=[-10,40];
      latlim=[36,56];
    case 'ind'
      lonlim=[65,91];latlim=[6,32];
    case 'ecl'
        % Euroclimate simulation
      lonlim=[-10,42];
      %lonlim=[6,42];
      latlim=[31,57];
    case 'eng'
      latlim=[45 55]; lonlim=[-10 2];
    case 'all'
    case 'wor'
    case 'zim' % Zimbabwe
      lonlim=[23.8,34.6];
      latlim=[-23.8,-14.2];
    otherwise
      error('Region not known');
  end
  
  ifound=[];
  for i=1:nreg
    valid=find(regionpath(i,:,2)>-999);
    if any(   regionpath(i,valid,2)>latlim(1) ...
          & regionpath(i,valid,2)<latlim(2) ... 
          & regionpath(i,valid,1)>lonlim(1) ... 
          & regionpath(i,valid,1)<lonlim(2) );
      ifound=[ifound;i];
    end
  end  
end


nfound=length(ifound);

return
