function [rdata,rlon,rlat]=clp_globe(varargin)
% Plots the Global One km resolution database
% Assuming raw binary little-endian int16

arguments = {...
  {'region','Austria'},...
  {'lonlim',[9 17]},{'latlim',[46 49]},... 
  {'fig',NaN},...
  {'noborder',1},...
  {'nocoast',1},...
  {'noriver',0},...
  {'nofigure',0},...
  {'nogrid',1},...
  {'rdata',NaN},...
  {'rlon',NaN},...
  {'rlat',NaN},...
};

% {'lonlim',[9 17]},{'latlim',[46 49]},... % Austria
% {'lonlim',[-10 42]},{'latlim',[31 57]},... % Europe
% Harapp is at 30°38?N 72°52?E

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


file=['../../data/globe_' region '.hdr'];
if ~exist(file,'file') error('File does not exist'); end
fid=fopen(file,'r');
C=textscan(fid,'%s %s','Delimiter','=');
fclose(fid);

res=str2num(char(C{2}(strmatch('grid_size',C{1}))));
llx=str2num(char(C{2}(strmatch('left_map_x',C{1}))));
urx=str2num(char(C{2}(strmatch('right_map_x',C{1}))));
lly=str2num(char(C{2}(strmatch('lower_map_y',C{1}))));
ury=str2num(char(C{2}(strmatch('upper_map_y',C{1}))));
nrow=str2num(char(C{2}(strmatch('number_of_rows',C{1}))));
ncol=str2num(char(C{2}(strmatch('number_of_columns',C{1}))));

if isinf(latlim(1)) latlim(1)=lly; end
if isinf(latlim(2)) latlim(2)=ury; end
if isinf(lonlim(1)) lonlim(1)=llx; end
if isinf(lonlim(2)) lonlim(2)=urx; end

if llx>lonlim(1) | urx<lonlim(1) | lly >latlim(1) | ury<latlim(2)
  warning('Region is not within specified latitude/longitude. Returned.');
  return
end


file=strrep(file,'.hdr','.bin');
fid=fopen(file,'rb','b');
[data,count]=fread(fid,[ncol nrow],'int16');
data=flipud(data');
fclose(fid);

lon=llx+[0:ncol-1]*res+0.5*res;
lat=lly+[0:nrow-1]*res+0.5*res;
ilat=find(lat>=latlim(1) & lat<=latlim(2));
ilon=find(lon>=lonlim(1) & lon<=lonlim(2));
data=data(ilat,ilon);
lon=lon(ilon);
lat=lat(ilat);

if nargout>0
  rlon=lon;
  rlat=lat;
  rdata=data;
end

if nofigure return; end

if isnan(fig) fig=figure; clf reset;
else figure(fig);
  hold on;
end


m_proj('equidistant','lat',latlim,'lon',lonlim);
hold on;

m_pcolor(lon,lat,data);
demcmap(data);
shading interp;

%m_coast;
if nogrid m_grid('box','off','Xtick',[],'Ytick',[]);
else m_grid('box','fancy');
end


gxfile=sprintf('gshhs_X_%d_%d_%d_%d.mat',round(lonlim),round(latlim));
prefix='cbr';
for i=1:3
  gfile=strrep(gxfile,'X',prefix(i));
  if ~exist(gfile,'file') 
    m_gshhs(['h' prefix(i)],'save',gfile)
  end
end
    
if ~nocoast m_usercoast(strrep(gxfile,'X',prefix(1)),'color','black','linewidth',0.3,'linestyle','-','tag','coastline'); 
end % plot coastline in high resolution
if ~noborder m_usercoast(strrep(gxfile,'X',prefix(2)),'color','red','linewidth',0.2,'linestyle','-','tag','border'); % plot boundaries in high resolution
end
if ~noriver m_usercoast(strrep(gxfile,'X',prefix(3)),'color','blue','linewidth',0.1,'tag','river'); % plot rivers in high resolution
end

return


% Below for flooding
river=load(gfile);
rlon=river.ncst(:,1);
rlat=river.ncst(:,2);
irlat=round((rlat-min(lat))/res)+1;
irlon=round((rlon-min(lon))/res)+1;

vir=find(irlat>0 & irlat<=length(lat) & isfinite(irlat) ...
    & irlon>0 & irlon<=length(lon) & isfinite(irlon));

grlat=rlat+NaN; grlat(vir)=lat(irlat(vir))';
grlon=rlon+NaN; grlon(vir)=lon(irlon(vir))';
grelev=rlon+NaN; 
idata=sub2ind(size(data),irlon(vir),irlat(vir));
grelev(vir)=data(idata);


level=2;
rep=20;
iflat=repmat(irlat(vir),1,rep*rep)+repmat([1:rep]-ceil(rep/2),length(vir),rep);
iflon=repmat(irlon(vir),1,rep*rep)+repmat(reshape(repmat([1:rep]-ceil(rep/2),rep,1),1,rep*rep),length(vir),1);
felev=repmat(grelev+level,1,rep*rep);

vf=find(iflat>0 & iflon>0 & iflat<=length(lat) & iflon<=length(lon));
idata=sub2ind(size(data),iflon(vf),iflat(vf));
fdata=data;
fdata(idata)=felev(vf);
[iglon iglat]=find(fdata>data);

flood=m_plot(lon(iglon),lat(iglat),'bs');
set(flood,'MarkerFaceColor','b','MarkerSize',2);


return
end