function [p,lonlim,latlim]=clp_naturalearth(varargin)

cl_register_function;
%global naturalearth

arguments = {...
  {'latlim',[-90 90]},...
  {'lonlim',[-180 180]},...
  {'fig',NaN},...
  {'filename','../../data/naturalearth/SR_LR'},...
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

filename=strrep(filename,'.tif','');
matfile=sprintf('%s_%04d_%04d_%03d_%03d.mat',filename,...
    floor(lonlim(1)),ceil(lonlim(2)),floor(latlim(1)),ceil(latlim(2)));
filename=sprintf('%s.tif',filename);

if 0==1 %exist('naturalearth','var') && ~isempty(naturalearth) a=naturalearth; 
elseif exist(matfile,'file') 
  load(matfile);  
elseif exist(filename,'file') 
    a=imread(filename);
%naturalearth=a;
[nla,nlo,ncol]=size(a);
 
gla=[90:-180./(nla-1):-90];
glo=[-180+180./nlo:360./nlo:180-180./nlo];
 
% get only interesting part (i.e. between latlim and lonlim);
igla=find(gla>=latlim(1) & gla<=latlim(2));
iglo=find(glo>=lonlim(1) & glo<=lonlim(2));
latlim(1)=gla(igla(end)); latlim(2)=gla(igla(1));
lonlim(2)=glo(iglo(1)); lonlim(2)=glo(iglo(end));
glo=glo(iglo);
gla=gla(igla);
a=a(igla,iglo,:);
save(matfile,'a');


else
  warning('File %s does not exist, please go to www.naturalearthdata.com and download.',filename);
  return;
end
 

clf reset;
global MAP_COORDS
if ~exist('MAP_COORDS','var') && isempty(MAP_COORDS)
  m_proj('equidistant','lat',latlim,'lon',lonlim);
  m_grid;
  m_coast;
end

[llx,lly]=m_ll2xy(lonlim(1),latlim(1),'clip','off');
[urx,ury]=m_ll2xy(lonlim(2),latlim(2),'clip','off');

hold on;

p=image([llx,urx],[ury,lly],a);
if length(size(a))==2 colormap(gray(255));
%hold on;m_coast; m_grid;

return
end