function plot_proxy_overview(varargin)

cl_register_function();

istart=1; iend=100000; scenario='o4n2w1'

if (nargin>0)
  istart=varargin{1}(1);
  if (length(varargin{1})==2) iend=varargin{1}(2); end;
  for iargin=2:nargin
    if strcmp(varargin{iargin},'FontSize') fs=varargin{iargin+1}; iargin=iargin+1; end;
    if strcmp(varargin{iargin},'Scenario') scenario=varargin{iargin+1}; iargin=iargin+1; end;
  end;
end; 

if nargin>0
  istart=varargin{1}(1);
  if (length(varargin{1})==2) iend=varargin{1}(2); end;
end

if ~exist('holodata.mat','file')
  printf('The file holodata.mat is required\n');
  return;
end

if ~exist('m_proj') addpath('~/matlab/m_map'); end;

[dirs,files]=get_files;
dirs.plot=fullfile(dirs.plot,['proxy_overview_' scenario]);

load('holodata.mat');
n=length(holodata.No);
iend=min([n,iend]);
  
lat=holodata.Latitude;
lon=holodata.Longitude;
ny=holodata.CutoffFreq;
pdf=holodata.SourcePDF;
src=holodata.Source;
comment=holodata.Comment;
no=holodata.No;
nosort=holodata.No_sort;
datafile=holodata.Datafile;
name=holodata.Plotname;
proxy=holodata.Proxy;

latlim=[min(lat)-1,max(lat)+1];
lonlim=[min(lon)-1,max(lon)+1];

nx=2;
ny=2;
ratio=0.8;
wx=ratio/nx;
wy=ratio/ny;
mx=(1-ratio)/nx/2;
my=(1-ratio)/nx/2;

axpos=zeros(nx*ny,4);
for ix=1:nx for iy=1:ny
    ipos=(ix-1)*ny+iy;
    axpos(ipos,:)=[mx+(ix-1)./nx 1-my-wy-(iy-1)./ny wx+mx wy+my];
%    fprintf('%d %d %d %f %f %f %f\n',ix, iy, ipos,axpos(ipos,:));
  end; 
end;

fs=16-(max(sqrt(nx*ny+max(nx,ny))));

fid=1;
if fid>0
  fid=fopen(['redfit_' scenario '.tsv'],'w');
  fprintf(fid,'"dataset" "npoints"  "nuquist" "band11" "band12" "sig1" "band21" "band22" "sig2" "band31" "band32" "sig3"\n');
end

for i=istart:iend
  figure(20); 
  clf reset;
  if (nx==2 & ny==2) set(gcf,'Position',[ 318.0000  573.0000  566.0000 370]); end

  axes('Position',axpos(1,:));
  m_proj('miller','lat',latlim,'lon',lonlim);
  m_coast('color',[0.8 0.8 1]);
  m_grid('box','fancy','tickdir','in');
  m_line(lon(i),lat(i),'Color','red','MarkerSize',8,'Marker','diamond','LineWidth',2);
  m_line(lon(i),lat(i),'Color','red','MarkerSize',1,'Marker','+');
  tposlon=lonlim(1)+10;
  tposlat=latlim(2)-10;
  infotext=sprintf('%s (%d)\n%.2fE %.2fN\n',name{i},no(i),lon(i),lat(i));
  hdl=m_text(tposlon,tposlat,infotext);
  set(hdl,'FontSize',fs,'VerticalAlignment','top','HorizontalAlignment','left','FontWeight','bold');
  
  tposlon=lonlim(2)-10;
  tposlat=latlim(1)+10;
  infotext=sprintf('%s\n',strrep(holodata.Datafile{i},'_','\_'));
  infotext=[infotext sprintf('%s\n%s\n',strrep(pdf{i},'_','\_'),strrep(src{i},'_','\_')) ];
  infotext=[infotext sprintf('%s (%d)\n',proxy{i},nosort(i)) ];

  hdl=m_text(tposlon,tposlat,infotext);
  set(hdl,'FontSize',fs-4,'VerticalAlignment','bottom','HorizontalAlignment','right');
  
  axes('Position',axpos(3,:));
  plot_single_timeseries(i,'FontSize',fs,'NoTitle''NoXTicks');
  axes('Position',axpos(4,:));
  plot_single_timeseries_anomaly(i,'FontSize',fs,'NoTitle');
  axes('Position',axpos(2,:).*[1 1 1 0.5]);
  plot_single_redfit(i,'low','FontSize',fs,'NoTitle','Scenario',scenario,'FileId',fid);
  axes('Position',axpos(2,:).*[1 1 1 0]+[0 my+0.5*wy 0 0.5*wy]);
  plot_single_redfit(i,'upp','FontSize',fs,'NoTitle','NoXTicks','Scenario',scenario,'FileId',fid);

  plot_multi_format(20,fullfile(dirs.plot,['proxy_overview_' num2str(i)]));
end  

if fid>0 fclose(fid); end

return
