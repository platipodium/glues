% runs script do_trb.m
% Carsten Lemmen 
% 2011-02-08


%% Define region to TRB
reg='trb';
timelim=[-4650 -2050];
[ireg,nreg,loli,lali]=find_region_numbers(reg);
lonlim=loli;latlim=lali;

% get lat/lon from regionpath, since they are wrong in the above file
if ~exist('lonlat_685.mat','file')
  load('regionpath_685');
  regionpath(:,:,1)=regionpath(:,:,1)+0.5;
  regionpath(:,:,2)=regionpath(:,:,2)+1;
  lats=squeeze(regionpath(:,:,2));
  lons=squeeze(regionpath(:,:,1));

  for ir=1:nreg
    lat(ir)=calc_geo_mean(lats(ir,:),lats(ir,:));
    lon(ir)=calc_geo_mean(lats(ir,:),lons(ir,:));
  end
  save('lonlat_685','lon','lat');
else load('lonlat_685');
end


  % For Pinhasi
  load('../../data/Pinhasi2005_etal_plosbio_som1.mat');
  slat=Pinhasi.latitude;
  slon=Pinhasi.longitude;
  period=Pinhasi.period;
  site=Pinhasi.site;
  sage=Pinhasi.age_cal_bp;
  sage_upper=sage+Pinhasi.age_cal_bp_s;
  sage_lower=sage-Pinhasi.age_cal_bp_s;

stime=1950-sage;
sutime=stime+(sage_lower-sage);
sltime=stime+(sage_upper-sage);

is=find(slat>=latlim(1) & slat<=latlim(2) & slon>=lonlim(1) & slon<=lonlim(2) ...
    & sltime>=timelim(1) & sutime<=timelim(2));

slon=slon(is);
slat=slat(is);
period=period(is);
site=site(is);
sltime=sltime(is);
sutime=sutime(is);
srange=sltime-sutime;
stime=stime(is);

ns=length(slon);
dlat=[slat repmat(lat(272),ns,1)];
dlat=reshape(dlat',2*ns,1);
dlon=[slon repmat(lon(272),ns,1)];
dlon=reshape(dlon',2*ns,1);
sdists=m_lldist(dlon,dlat);
sdists=sdists(1:2:end);

ncol=13;
cmap=flipud(jet(ncol));
iscol=floor((stime-min(timelim))./(timelim(2)-timelim(1))*ncol)+1;
iscol(iscol<1)=1;
viscol=find(iscol<=ncol);

if (3==3)
%% plot farming timing (figure 3)


[data,basename]=clp_nc_variable('var','farming','threshold',0.5,'reg',reg,'marble',0,'transparency',0,'nocolor',0,...
      'showstat',0,'timelim',timelim,'showtime',0,'flip',1,'showvalue',0,...
      'file','../../eurolbk_events.nc','figoffset',0,'sce','base',...
      'noprint',1,'notitle',1,'ncol',ncol,'cmap','clc_plantago');
  
cb=findobj('tag','colorbar');
ytl=get(cb,'YTickLabel');
yt=get(cb,'YTick');
yt=[0:1/(ncol):1]';
ytl=num2str(1950-[timelim(1):200:timelim(2)]');
set(cb,'YTick',yt,'YTickLabel',ytl);
ytt=get(cb,'Title');
set(ytt,'String','Years cal BP','FontSize',14,'FontName','Times','FontWeight','normal');
cmap=clc_plantago(ncol);

for i=1:length(viscol)
  m_plot(slon(viscol(i)),slat(viscol(i)),'ko','MarkerFaceColor',cmap(iscol(viscol(i)),:));
end

ct=findobj(gcf,'-property','FontName');
set(ct,'FontSize',14,'FontName','Times','FontWeight','normal');

m_coast('color','k');
m_grid('box','fancy','linestyle','none');
cl_print('name',strrep(basename,'farming_','timing_'),'ext','png','res',[150,600]);


%ct=findobj(gcf,'type','text'); set(ct,'visible','off');
%ct=findobj(gcf,'-property','YTickLabel'); set(ct,'YTickLabel',[]);
%ct=findobj(gcf,'-property','XTickLabel'); set(ct,'XTickLabel',[]);
%set(ytt,'visible','off');

    
end



