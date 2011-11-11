%% Zimbabwe plots

fdir='/Users/lemmen/projects/zimbabwe/netlogo/data'

time=[2000:-200:200 100 0];
nt=length(time);
prefix='p';

cave=textread('/Users/lemmen/projects/zimbabwe/data/Thorp2001_etal_d180_SEAfrica.tsv','','headerlines',2);


file='../plots/zimbabwe/bryson_precipitation.avi';
paviobj=avifile(file,'fps',1.5,'videoname','Bryson reconstruction of annual precipitation');

file='../plots/zimbabwe/bryson_temperature.avi';
taviobj=avifile(file,'fps',1.5,'videoname','Bryson reconstruction of annual temperature');

file='../plots/zimbabwe/bryson_npp.avi';
naviobj=avifile(file,'fps',1.5,'videoname','Bryson/Miami reconstruction of NPP');

file='../plots/zimbabwe/bryson_cover.avi';
vaviobj=avifile(file,'fps',1.5,'videoname','Bryson/VECODE reconstruction of land cover');


%lsa=shaperead('/Users/lemmen/projects/zimbabwe/netlogo/data/late stone age.shp');

noprint=1;

for i=1:nt
  p=cl_read_arcgis_asc('file',fullfile(fdir,[prefix num2str(time(i)) '.asc']));

  if ~noprint
      pfig=figure(1); clf reset; hold on;
  m_proj('equidistant','lat',p.latlim,'lon',p.lonlim);
  m_coast;
  m_grid;
  m_pcolor(p.lon,p.lat,p.data);
  m_contour(p.lon,p.lat,p.data,[500 500],'color','r','linewidth',3);
  shading interp;
  colorbar;
  ax1=gca;
  set(gca,'Clim',[200,1200]);
  title('Bryson reconstruction of annual precipitation');
  if time(i)>2000 era='BC'; else era='AD'; end
  m_text(25.5,-16,sprintf('%4d %s',abs(2000-time(i)),era),'FontSize',16');
  
  f=getframe(pfig);
  paviobj=addframe(paviobj,f);
  end
  
  t=cl_read_arcgis_asc('file',fullfile(fdir,['t' num2str(time(i)) '.asc']));

  if ~noprint
      tfig=figure(2); clf reset; hold on;
  m_proj('equidistant','lat',t.latlim,'lon',t.lonlim);
  m_coast;
  m_grid;
  m_pcolor(t.lon,t.lat,t.data);
  shading interp;
  colorbar;
  ax1=gca;
  set(gca,'Clim',[15,30]);
  title('Bryson reconstruction of annual temperature');
  if time(i)>2000 era='BC'; else era='AD'; end
  m_text(25.5,-16,sprintf('%4d %s',abs(2000-time(i)),era),'FontSize',16');
  
  f=getframe(tfig);
  taviobj=addframe(taviobj,f);
  end
  
  % Calculate VECODE properties.
  
  gdd0=t.data*0+365*20;
  co2matrix=t.data*0+280;
  [climate.production,climate.share,climate.carbon,climate.p]=clc_vecode(t.data,p.data,gdd0,co2matrix);

  w=t;
  w.data=round(100*climate.share.forest);
  cl_write_arcgis_asc(w,'file',fullfile(fdir,['forest_fraction' num2str(time(i)) '.asc']),'nodata',-1);
  w.data=round(100*climate.share.grass);
  cl_write_arcgis_asc(w,'file',fullfile(fdir,['grass_fraction' num2str(time(i)) '.asc']),'nodata',-1);
  w.data=round(100*climate.share.desert);
  cl_write_arcgis_asc(w,'file',fullfile(fdir,['desert_fraction' num2str(time(i)) '.asc']),'nodata',-1);
  
  [npp,npp_p,npp_t,lp,lt]=clc_npp(t.data,p.data);
  
  if ~noprint
      nfig=figure(3); clf reset; hold on;
  m_proj('equidistant','lat',t.latlim,'lon',t.lonlim);
  m_coast;
  m_grid;
  m_pcolor(t.lon,t.lat,npp);
  shading interp;
  colorbar;
  ax1=gca;
  set(gca,'Clim',[300,1000]);
  title('Bryson/Miami reconstruction of NPP');
  if time(i)>2000 era='BC'; else era='AD'; end
  m_text(25.5,-16,sprintf('%4d %s',abs(2000-time(i)),era),'FontSize',16');
  
  itemp=(npp_p>npp_t);
  if any(itemp) 
    m_contour(t.lon,t.lat,itemp,[1 1],'color','k','linewidth',3);
  end
 
  f=getframe(nfig);
  naviobj=addframe(naviobj,f);
  end
  
  if 1%~noprint
    vfig=figure(4); clf reset; hold on;
    m_proj('equidistant','lat',t.latlim,'lon',t.lonlim);
    m_coast;
    m_grid;
    gcover=m_pcolor(t.lon,t.lat,climate.share.grass);
    set(gcover,'FaceAlpha','flat','AlphaDataMapping','none',...
        'AlphaData',climate.share.grass,'FaceColor','yellow');
    tcover=m_pcolor(t.lon,t.lat,climate.share.forest);
    set(tcover,'FaceAlpha','flat','AlphaDataMapping','none',...
        'AlphaData',climate.share.forest,'FaceColor','green');
   
    m_contour(t.lon,t.lat,climate.share.forest,[.5 .5],'color','r','linewidth',3);
 
    
    %dcover=m_pcolor(t.lon,t.lat,climate.share.desert);
    %set(dcover,'FaceAlpha','flat','AlphaDataMapping','none',...
    %    'AlphaData',climate.share.desert,'FaceColor','red');
    
   % shading interp;
    %colorbar;
    %ax1=gca;
    %set(gca,'Clim',[0,1]);
    title('Bryson/VECODE reconstruction of land cover');
    if time(i)>2000 era='BC'; else era='AD'; end
      m_text(25.5,-16,sprintf('%4d %s',abs(2000-time(i)),era),'FontSize',16');
   
    f=getframe(vfig);
    vaviobj=addframe(vaviobj,f);
  end
 
  
  
  if i==1
    zonal=zeros(nt,length(t.lat))-NaN;
  end
    
  nzonal=sum(isfinite(t.data),2);
  t.data(isnan(t.data))=0;
  szonal=sum(t.data,2);
  zonal(i,:)=(szonal./nzonal)';
  
  %figure(2); clf reset;
  %plot(zonal(i,:),d.lat,'k-');
  %set(gca,'Xlim',[200 1200]);
  %pause(1);
  
end

paviobj=close(paviobj);
taviobj=close(taviobj);
naviobj=close(naviobj);
vaviobj=close(vaviobj);

figure(3); clf reset; hold on;
il=300;
plot(time,zonal(:,il),'b-');
%plot(cave(:,1),movavg(cave(:,1),(cave(:,4)-mean(cave(:,4)))+mean(zonal(:,il)),200),'r-');
plot(cave(:,1),movavg(cave(:,1),0.5*(cave(:,4)-mean(cave(:,4)))+mean(zonal(:,il)),200),'r-');
set(gca,'XLim',[min(time) max(time)]);







