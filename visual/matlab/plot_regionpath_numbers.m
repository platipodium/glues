function plot_regionpath_numbers(varargin)

cl_register_function();

% Defaults
mode='optimal';
region='europe';
%lat=[10 30];
%lon=[-120 -90];

regionpathfile='regionpath_939';
%iselect=find_region_numbers('lat',lat,'lon',lon);
itodo=[];

if nargin==1
  iselect=varargin{1};
else 
  iarg=1;
  while iarg<=nargin
  switch lower(varargin{iarg}(1:min([end,3])))
    case 'reg' 
      iselect=varargin{iarg+1};
      iarg=iarg+1;
    case 'pat'
      mode='patch';
      color=varargin{iarg+1};
      iarg=iarg+1;
    case 'lin'
      mode='line';
      color=varargin{iarg+1};
      iarg=iarg+1;
      case 'lat'
          latlim=varargin{iarg+1};
          iarg=iarg+1;
      case 'lon'
          lonlim=varargin{iarg+1};
          iarg=iarg+1;
      case 'fil'
          regionpathfile=varargin{iarg+1};
          iarg=iarg+1;
    otherwise
      itodo=[itodo,iarg];
  end
  iarg=iarg+1;
end
end
if length(itodo)>0 varargin=varargin(itodo); else varargin=[]; end


iselect=find_region_numbers(region,'file',regionpathfile);%[216, 279, 315, 170];
load(regionpathfile);


if exist('region','var') & isstruct(region) 
  nreg=region.nreg; 
  regionpath=region.path;
  
end





if mode=='optimal'
    icolors=calc_regioncolors(regionpathfile);
    ncolors=max(icolors);
    colors=[0.9 0.2 0.9; 0.2 0.9 0.9; 0.9 0.9 0.2; 
            0.8 0.4 0.8; 0.4 0.8 0.8; 0.8 0.8 0.4;
            0.6 0.6 0.8; 0.6 0.8 0.6; 0.8 0.6 0.6];
    colors=prism;
    colors=rgb2hsv(colors(1:6,:));
    colors(:,2)=0.3; % make pastel;
    colors=hsv2rgb(colors);
end


% TODO remove correction in lat/lon
regionpath(:,:,1)=regionpath(:,:,1)+0.5;
regionpath(:,:,2)=regionpath(:,:,2)+1.0;

lonoffset=10; latoffset=10;

lats=squeeze(regionpath(iselect,:,2));
lons=squeeze(regionpath(iselect,:,1));
latmin=min(lats(lats>-999))-latoffset;
latmax=max(lats(lats>-999))+latoffset;
lonmax=max(lons(lons>-999))+lonoffset;
lonmin=min(lons(lons>-999))-lonoffset;

if exist('lonlim','var') lonmin=lonlim(1); lonmax=lonlim(2); end;
if exist('latlim','var') latmin=latlim(1); latmax=latlim(2); end;


if ~ishold clf reset;
  %if strcmp(region,'emea') 
      m_proj('miller','lon',[lonmin,lonmax],'lat',[latmin,min([latmax,90])]);
  %else m_proj('mercator'); end
  m_grid;
end

for i=1:length(iselect)
  
  valid=isfinite(regionpath(iselect(i),:,2));
  if isempty(valid) continue; end
  
  if strcmp(mode,'patch')
    m_patch(regionpath(iselect(i),valid,1),regionpath(iselect(i),valid,2),color);
  elseif strcmp(mode,'line') 
    if ~isempty(varargin) m_line(regionpath(iselect(i),valid,1),regionpath(iselect(i),valid,2),varargin{:});
    else m_line(regionpath(iselect(i),valid,1),regionpath(iselect(i),valid,2)); end
  else 
    mp=m_patch(regionpath(iselect(i),valid,1),regionpath(iselect(i),valid,2),colors(icolors(iselect(i)),:));      
    %set(mp,'LineStyle','none');
  end
  regioncenter(iselect(i),1:2)=mean([regionpath(iselect(i),valid,1)+0.5;regionpath(iselect(i),valid,2)+1]',1);
end
m_coast;

%[lo,la]=regioncenter(iselect,[2,1]);
[xt,yt]=m_ll2xy(regioncenter(iselect,1),regioncenter(iselect,2));
[xt,yt]=dislocate_slightly(xt,yt,0.01);
[lo,la]=m_xy2ll(xt,yt);

for i=1:length(iselect)
  mt(i)=m_text(lo(i),la(i),num2str(iselect(i)),'HorizontalAlignment','center');
end






return
