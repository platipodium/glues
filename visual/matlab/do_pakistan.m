function do_pakistan

plots=[1:11];

%% Load country boundaries
load('../../data/naturalearth/10m_admin_0_countries.mat');
for i=1:length(shape)
    if strmatch(shape(i).SOVEREIGNT,'Pakistan') ipak=i; break; end
end
plat=shape(ipak).Y;
plon=shape(ipak).X;
latlim=[min(plat) max(plat)] + 0.5*[-1 1];
lonlim=[min(plon) max(plon)] + 0.5*[-1 1];

latlim=[22 35.5];
lonlim(2)=77.0;

%% Load site data
% This file is generated by plot_randall_periods.m and has
% information p_index and p_time for certain periods in the whole dataset
load 'randall_ivc_data_periods.mat';
  
% Load the whole data set
data=load('../../data/randall_ivc_data');
period=data.period';
im=[
  strmatch('Accharwala',period);
  strmatch('Ahar-Banas',period);
  strmatch('Amri',period);
  strmatch('Anarta',period);
  strmatch('Andrhra',period);
  strmatch('Anjira',period);
  strmatch('BMAC',period);
  strmatch('Bara',period);
  strmatch('Bhurj',period);
  strmatch('Bihar',period);
  %strmatch('Black',period);
  strmatch('Buddhist',period);
  strmatch('Burj',period);
  %strmatch('Burnished',period);
  strmatch('Cem',period);
  strmatch('Chalcolithic',period);
  strmatch('Complex B',period);
  strmatch('Damb Sadaat',period);
  strmatch('Dasht',period);
  strmatch('Early',period);
  strmatch('GAZ',period);
  strmatch('Ganeshwar',period);
  %strmatch('Grindingstone',period);
  strmatch('Gujarat',period);
  strmatch('Gupta',period);
  strmatch('Hakra Wares',period);
  strmatch('Harappan',period);
  strmatch('Haryana',period);
  strmatch('Historic',period);
  strmatch('Iron Age',period);
  strmatch('Islamic',period);
  strmatch('Jhangar',period);
  strmatch('Jhukar',period);
  strmatch('Jodhpura',period);
  strmatch('Kaisaria',period);
  strmatch('Kechi',period);
  strmatch('Kerman',period);
  strmatch('Kili',period);
  strmatch('Kingrali',period);
  strmatch('Kirana',period);
  strmatch('Kot Diji',period);
  strmatch('Kulli',period);
  strmatch('Kushan',period);
  strmatch('Late',period);
  strmatch('Londo',period);
  strmatch('Lustrous Red Ware',period);
  strmatch('Madhya Preadesh',period);
  strmatch('Maharashtra',period);
  strmatch('Malwa',period);
  strmatch('Mature and Late Harappan',period);
  strmatch('Medieval',period);
  strmatch('Mehrgarh',period);
  strmatch('Microliths',period);
  strmatch('NBP',period);
  strmatch('Nal',period);
  strmatch('Northern Neolithic',period);
  strmatch('OCP',period);
  strmatch('Orissa',period);
  strmatch('PGW',period);
  strmatch('Palaeo / Mesolithic',period);
  strmatch('Partho',period);
  strmatch('Pirak',period);
  strmatch('Post',period);
  strmatch('Prabhas',period);
  strmatch('Pre-',period);
  strmatch('Quetta',period);
  strmatch('Rajasthan',period);
  strmatch('Rang Mahal',period);
  strmatch('Rangpur',period);
  strmatch('Ravi',period);
  strmatch('Red Polished Ware',period);
  strmatch('SKT',period);
  strmatch('Shahi Tump',period);
  strmatch('Shinkai',period);
  strmatch('Sistan',period);
  strmatch('Sorath',period);
  strmatch('Sothi-Siswal',period);
  strmatch('Sulaiman',period);
  strmatch('Sunga-Kushan',period);
  strmatch('Swat',period);
  %strmatch('TERIA',period);
  strmatch('Thari',period);
  strmatch('Togau',period);
  strmatch('Uttarpradesh',period);
  strmatch('Waziri',period);
  strmatch('Zangian',period);
];
nall=length(period);
narch=length(im);
period=period(im);
rlat=data.latitude(im);
rlon=data.longitude(im);

ikili=strmatch('Kili',data.period(im));
imehr=strmatch('Mehrga',data.period(im));
iburj=vertcat(strmatch('Burj',data.period(im)),strmatch('Bhurj',data.period(im)))
itogau=strmatch('Togau',data.period(im));
iskt=strmatch('SKT',data.period(im));
ihakra=strmatch('Hakra',data.period(im));
ikechi=strmatch('Kechi',data.period(im));
ianarta=strmatch('Anarta',data.period(im));
ineo=vertcat(ikili,imehr,iburj,itogau,iskt,ihakra,ikechi,ianarta);

randall=cl_randall_periods;
info={'Kili','Mehrgarh','Burj','Bhurj','Togau','SKT','Hakra','Kechi','Anarta'};
fprintf('Randall''s data set contains %d data, of these %d archaeological.\n',nall,narch);
for i=1:length(info)
  im=strmatch(info{i},data.period);
  fprintf('Period: %s \n',char(unique(data.period(im))));
  fprintf('  there are %d artifacts at %d sites \n',...
    length(im),length(unique(data.sitename(im))));
  usitenames=unique(data.sitename(im));
  fprintf('  %s \n',usitenames{:});
  fprintf('  spanning %.1f-%.1f E and %.1f-%.1f N\n\n',...
    min(data.longitude(im)),max(data.longitude(im)),...
    min(data.latitude(im)),max(data.latitude(im)));

end



% From Harappan-sites.kml
% Early Harappa 5000-2600 BC: Ravi + Hakra + Amri-Nal + Sothi-Siswal 
% + Kot Diji 
% Harappan: 2600-1900 BC: Harappa + Cities + Jhukar + Jhangar 
% + Late Sorath 
% Post-Urban: Post-Urban + Late harappan + Cemetery H

timelim=[[-9000 p_Helvetica]' , [p_Helvetica -1000]'];
timelim=cell2mat(timelim);
tlim=[min(min(timelim)) max(max(timelim))];


%% Load simulation data
file='../../eurolbk_events.nc';
ncid=netcdf.open(file,'NOWRITE');
varid=netcdf.inqVarID(ncid,'region'); region=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'longitude'); longitude=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'latitude'); latitude=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'time'); time=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'area'); area=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'population_density'); pdensity=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'technology'); technology=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'farming'); farming=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'natural_fertility'); natfert=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'temperature_limitation'); templim=netcdf.getVar(ncid,varid);
netcdf.close(ncid);

%% Prepare gridded file of farming
gridfile=strrep(file,'.nc','_0.5x0.5.nc');
if ~exist(gridfile,'file')
  cl_glues2grid('timelim',tlim,'variables',{'farming','region'},'latlim',latlim,'lonlim',lonlim,'file',file)
end

% minmax timing in this area is -6160:3810
%% Do plots
global naturalearth
fs=15;

% Figure 1 b
%clp_ivc_geography; 

% Figure 1 c
hold off;
clp_ivc_period;
pkili=m_plot(rlon([ikili;imehr]),rlat([ikili;imehr]),'k^','MarkerFaceColor','k','MarkerSize',7,'MarkerEdgeColor','k'); 
cities = {'Mehrgarh','Kili Ghul Mohammad'}
for i=1:length(cities)
  icity=strmatch(cities{i},data.sitename);
  if isempty(icity) continue; end
  pc(i)=m_plot(data.longitude(icity(1)),data.latitude(icity(1)),'k^',...
  'MarkerFaceColor','w','MarkerSize',7,'markerEdgeColor','k','tag',[cities{i} '/' data.period{icity(1)}]);
end
cl_print('name','../plots/map/ivc_period_kili','ext','pdf');
fprintf('For Kili period, there are %d sites\n',length([ikili;imehr]));


% Figure 1 d
delete([pkili,pc]);
pburj=m_plot(rlon(iburj),rlat(iburj),'k^','MarkerFaceColor','k','MarkerSize',7,'MarkerEdgeColor','k'); 
cl_print('name','../plots/map/ivc_period_burj','ext','pdf');
fprintf('For Burj period, there are %d sites\n',length([iburj]));

% Figure 1 e
delete([pburj]);
ptogau=m_plot(rlon([itogau;iskt]),rlat([itogau;iskt]),'k^','MarkerFaceColor','k','MarkerSize',7,'MarkerEdgeColor','k'); 
cities = {'Togau','Sheri Khan Tarakai'}
for i=1:length(cities)
  icity=strmatch(cities{i},data.sitename);
  if isempty(icity) continue; end
  pc(i)=m_plot(data.longitude(icity(1)),data.latitude(icity(1)),'k^',...
  'MarkerFaceColor','w','MarkerSize',7,'MarkerEdgeColor','k','tag',[cities{i} '/' data.period{icity(1)}]);
end
cl_print('name','../plots/map/ivc_period_togau','ext','pdf');
fprintf('For Togau period, there are %d sites\n',length([itogau;iskt]));

% Figure 1 f
delete([ptogau,pc]);
phakra=m_plot(rlon(ihakra),rlat(ihakra),'k^','MarkerFaceColor','k','MarkerSize',7,'MarkerEdgeColor','k'); 
pkechi=m_plot(rlon(ikechi),rlat(ikechi),'k^','MarkerFaceColor','k','MarkerSize',7,'MarkerEdgeColor','k'); 
panarta=m_plot(rlon(ianarta),rlat(ianarta),'k^','MarkerFaceColor','k','MarkerSize',7,'MarkerEdgeColor','k'); 
cities = {'Kechi Beg','Harappa'}
for i=1:length(cities)
  icity=strmatch(cities{i},data.sitename);
  if isempty(icity) continue; end
  pc(i)=m_plot(data.longitude(icity(1)),data.latitude(icity(1)),'k^',...
  'MarkerFaceColor','w','MarkerSize',7,'tag',[cities{i} '/' data.period{icity(1)}]);
end
cl_print('name','../plots/map/ivc_period_hakra','ext','pdf');
fprintf('For Hakra period, there are %d sites\n',length([itogau;iskt]));

















[ifound,nfound,lonlim,latlim]=find_region_numbers('lat',latlim,'lon',lonlim);    
rarea=repmat(area,1,length(time));
natfertmax=repmat(max(natfert,[],2),1,length(time));
itime=find(time>=-7000 & time<=-2666);
climdist=natfert(ifound,itime)./natfertmax(ifound,itime);



threshold=0.5;
ntime=1;
  
timing=(farming>=threshold)*1.0;
izero=find(timing==0);
timing(izero)=NaN;
timing=timing.*repmat(time',size(farming,1),1);
timing(isnan(timing))=inf;
timing=min(timing,[],2);
timing(isinf(timing))=NaN;


 ctimelim=[
    [-7000,-6300,-5600];
    [-5000,-4700,-4500];
    [-4300,-4100,-3900];
    [-3800,-3600,-3400];
    [-3200,inf,inf]]';

  plim=[1 4];
  nplim=range(plim)+1;
  nsub=size(ctimelim,1);
  %hue=(([1:nplim]+1)/(nplim+3.0));
  hue=[0.6 0.45 0.25 0.1];
  sat=([nplim-1:-1:1]+1)/(nsub+3.0);
  val=repmat(1,[1,nplim]);
  cmap=zeros(nplim*nplim,3);
  for i=1:nplim
     cmap((i-1)*nsub+1:i*nsub,1)=hue(i);  
     cmap((i-1)*nsub+1:i*nsub,2)=sat;  
     %cmap(i:nsub:end,2)=sat(i);
     cmap(i:nsub:end,3)=val(i);
  end
  
  cmap=hsv2rgb(cmap);
  %colormap(cmap);
  


if any(plots==3)
 
  cbar=colorbar;
  
  ax=gca;
  cbar=cl_colorbar('cbar',cbar,'val',ctimelim(1:nplim*size(ctimelim,1)+1),'cmap',cmap);
  axes(ax);
  
  for i=nplim*nsub:-1:1
    iperiod=find(timing(ifound)<=ctimelim(i+1) & timing(ifound)>=ctimelim(i) & hp'>0);
    if ~isempty(iperiod)   
       set(hp(iperiod),'FaceColor',cmap(i,:),'FaceAlpha',.5);
       fprintf('%2d (%5d-%5d)',i,ctimelim(i),ctimelim(i+1));
       fprintf(' %5d',timing(ifound(iperiod)));
       fprintf('\n');
       hdlp{i}=hp(iperiod);
    else hdlp{i}=NaN;
    end
  end
  
  % for results section description
  for i=1:nplim*nsub
    if i>1 & isfinite(hdlp{i-1}) set(hdlp{i-1},'EdgeColor','none'); end
    if isnan(hdlp{i}) continue; end
    set(hdlp{i},'EdgeColor','r','LineWidth',4);
  end
  
  
  for i=max(plim)+1:-1:min(plim)+1    
     if (i>1 && i<7)
       ps(i)=m_plot(data.longitude(p_index{i-1}),data.latitude(p_index{i-1}),...
         'ko','MarkerFaceColor',cmap((i-1)*nsub-1,:),'MarkerSize',18-2*i);
       uistack(ps(i),'top');
     end
   end
  
  ct=get(cbar,'title');
  ytl=get(cbar,'YTickLabel');
  set(cbar,'YTickLabel',num2str(abs(str2num(ytl))));
  
  set(ct,'string','cal BC');
  tt=title(' Indus valley neolithization and site chronology');
  hdlt=findobj(gcf,'-property','FontName');
  set([hdlt;ct],'FontSize',15,'FontName','Helvetica');
  cl_print('name','../plots/map/pakistan_farming_threshold_fine','ext','png');

  ax=gca;
  cbar=cl_colorbar('cbar',cbar,'val',ctimelim(1,:),'cmap',cmap(2:nsub:end,:));
  axes(ax);
  cl_print('name','../plots/map/pakistan_farming_threshold_coarse','ext','png');

  %% do only transparent map
  %set(cbar,'visible','off');
  %set(ps(ps>0),'visible','off');
  %set(gca,'XTick',[]);
  
end


if any(plots==4)
  figure(4); clf reset;
  
  plot(mean(climdist),time(itime),'k-','LineWidth',4);
  set(gca,'box','off','color','none');
  hdlt=findobj(gcf,'-property','FontName');
  set(hdlt,'FontSize',15,'FontName','Helvetica');
  cl_print('name','../plots/harappa_resource_depletion','ext','pdf');
  
end

  gridfile='../../data/glues_map.nc';
  ncid=netcdf.open(gridfile,'NOWRITE');
  varid=netcdf.inqVarID(ncid,'region'); grid.region=netcdf.getVar(ncid,varid);
  varid=netcdf.inqVarID(ncid,'lon'); grid.longitude=netcdf.getVar(ncid,varid);
  varid=netcdf.inqVarID(ncid,'lat'); grid.latitude=netcdf.getVar(ncid,varid);
  netcdf.close(ncid);
  
  ilon=find(grid.longitude>=lonlim(1) & grid.longitude<=lonlim(2));
  ilat=find(grid.latitude>=latlim(1) & grid.latitude<=latlim(2));
  gtiming=zeros(length(ilon),length(ilat))-NaN;
  gregion=grid.region(ilon,ilat);
  
  for i=1:nfound
    ir=find(gregion==ifound(i));
    gtiming(ir)=timing(ifound(i));  
  end
  lat2=repmat(grid.latitude(ilat),1,length(ilon))';
  lon2=repmat(grid.longitude(ilon),1,length(ilat));
  n2=numel(lon2);
  lat2=reshape(lat2,n2,1);
  lon2=reshape(lon2,n2,1);
  gti2=reshape(gtiming,n2,1);
  gri2=reshape(gregion,n2,1);

  ineo=vertcat(ikili,imehr,iburj,itogau,iskt,ihakra,ikechi,ianarta);
  lon1=rlon(ineo);
  lat1=rlat(ineo)
  n1=length(lat1);
  igrid=[];
  for j=1:n1
      la1=repmat(lat1(j),n2,1); 
      lo1=repmat(lon1(j),n2,1); 
      dist=m_lldist(reshape([lo1,lon2]',2*n2,1),reshape([la1,lat2]',2*n2,1));
      dist=dist(1:2:end);
      radius=100;
      idist=find(dist<=radius);
      if isempty(idist) continue; end
      igrid=vertcat(igrid,idist);
  end
 
  
  
if any(plots==6)
  
  timepoints=mean(timelim,2);
  %n=10;
  for i=1:length(p_index) 
    n(i)=length(p_index{i}); 
    nsites(i)=length(unique(data.sitename(p_index{i})));
  end
  
  igrid=unique(igrid);
  igrid=igrid(gri2(igrid)>0);
  sa=repmat(calc_gridcell_area(lat2(igrid)),1,length(time));
  sas=min(sum(sa)); % should be near 796095 km2
  
  s=sum(pdensity(gri2(igrid),:).*sa,1);
  
  %pa=m_plot(lon2(igrid),lat2(igrid),'ks','MarkerSize',5);
  % Surovell (2009) taphonomic correction based
  % on volcanic ash deposits
  nt=flipud(5.73E6*(2176.4+1950-timepoints(2:end-1)).^-1.39);
  %yi=interp1(timepoints(1:end-1),nt.*n',time,'pchip');
  
  tlim=[-7300 -3100];
  itime=find(time>tlim(1) & time<tlim(2));
  scalefactor=max(s(itime))/max(nt'.*n);
  
  ns=n*scalefactor;
  nts=double(n.*nt'*scalefactor);
  
  % Scale the number of sites
  scalefactor=max(s(itime))/max(nt'.*nsites);
  nssites=double(nsites.*nt'*scalefactor);
 
  figure(6); clf reset;
  hold on; 

  for i=2:5
    ppnt(i)=patch([timelim(i,:),fliplr(timelim(i,:))],...
      [0 0 nts(i-1) nts(i-1)],'b','FaceColor',repmat(0.82,1,3));
    ppn(i)=patch([timelim(i,:),fliplr(timelim(i,:))],...
      [0 0 ns(i-1) ns(i-1)],'b','FaceColor',repmat(0.7,1,3));
    xt(i)=mean(timelim(i,:));
    yt(i)=1.1*nts(i-1);
    ppt(i)=text(xt(i),yt(i),sprintf('%d x %d',n(i-1),round(nt(i-1))),...
        'Vert','bottom','horiz','center','FontSize',fs,'FontName','Helvetica');
  end
  set(gca,'Xlim',[tlim],'Ylim',[0 1.2*max(s(itime))]);

  ppnth=plot(time(itime),s(itime),'k-','LineWidth',10,'Color',repmat(0.82,1,3),'visible','off');
  ppnh=plot(time(itime),s(itime),'k-','LineWidth',10,'Color',repmat(0.7,1,3),'visible','off');
  pg=plot(time(itime),s(itime),'k-','LineWidth',4)
  
  cl=legend([ppnth,ppnh,pg],' Number of artifacts',' Artifacts (uncorrected)',' Simulated population size','location','NorthWest')
  set(cl,'FontSize',fs);
  ylabel('Population size','FontSize',fs,'FontName','Helvetica');
  xlabel('Time (cal BC)','FontSize',fs,'FontName','Helvetica');
  hdlt=findobj(gcf,'-property','FontName');
  set(hdlt,'FontSize',15,'FontName','Helvetica');
  cl_print('name','../plots/map/pakistan_population_size','ext','pdf');

 
  for i=2:5
    it=find(time>=timelim(i,1) & time<=timelim(i,2));     
    ys(i)=mean(s(it));
    %plot(timelim(i,:),repmat(ys(i),1,2),'r-');
    %plot(timelim(i,:),2*repmat(nssites(i-1),1,2),'m-','LineWidth',3);
  end
  
  c=polyfit(log(0.9*yt(2:5)),log(ys(2:5)),1);
  
end

figure(1);
%set([pct,pc,pcb],'visible','on');
%set(hp(ival),'EdgeColor','none','FaceColor','none');
%ipsval=find(ps>0);
%set(ps(ipsval),'MarkerFaceColor',repmat(0.7,1,3));

pa=m_plot(lon2(igrid),lat2(igrid),'ks','MarkerSize',5);  
cl_print('name','../plots/map/pakistan_farming_threshold_grid','ext','png');



return  
  
if any(plots==7)
  
  
  for i=nplim*nplim:-1:1
    [iglo,igla]=find(gtiming<=ctimelim(i+1) & gtiming>=ctimelim(i));
    if ~isempty(iglo)
      iperiod=find(gtiming<=ctimelim(i+1) & gtiming>=ctimelim(i));
      ptg(i)=m_plot(grid.longitude(ilon(iglo)),grid.latitude(ilat(igla)),'ks','MarkerFaceColor',cmap(i,:),...
         'MarkerSize',4);
    end
  end
  
  figure(5); clf reset; hold on;
   
  
  for i=max(plim)+1:-1:min(plim)+1    
    lon1=data.longitude(p_index{i-1});
    lat1=data.latitude(p_index{i-1});
    n1=length(lat1);
    for j=1:n1
      la1=repmat(lat1(j),n2,1); 
      lo1=repmat(lon1(j),n2,1); 
      dist=m_lldist(reshape([lo1,lon2]',2*n2,1),reshape([la1,lat2]',2*n2,1));
      dist=dist(1:2:end);
      radius=250;
      idist=find(dist<=radius);
      if isempty(idist) continue; end
      plot((p_Helvetica{i+1}-p_Helvetica{i})/2.0+p_Helvetica{i},unique(gti2(idist)),'ko')
    end
  end

  
  
end

  

if any(plots==6)
  % Find pakistan regions
  %[d,b]=clp_nc_variable('var','region','showstat',0,...
  %'noprint',1,'latlim',latlim+5*[-1 1],'lonlim',lonlim+5*[-1 1],'showvalue',1,...
  %'file','../../eurolbk_events.nc');
  %pakreg=[368 375 360 346 337 328 317 308];
  allindex=[];
  for i=1:3 allindex=vertcat(allindex,p_index{i}); end
  pakreg=cl_regionfind(d.lon,d.lat,data.longitude(allindex),data.latitude(allindex),500);
  

  timepoints=mean(timelim,2);
  n=10;
  for i=1:length(p_index) n(i+1)=length(p_index{i}); end
  
  figure(6); clf reset;
  hold on;
  %plot(timepoints,n,'b.','Marker','o');
  set(gca,'xlim',tlim,'ylim',[0 4E5]);
  
  % Surovell (2009) taphonomic correction based
  % on volcanic ash deposits
  nt=flipud(5.73E6*(2176.4+1950-timepoints).^-1.39);
  %plot(timepoints,nt.*n','r.','Marker','o');
  
  yi=interp1(timepoints,nt.*n',time,'spline');
  %plot(time,yi,'r-','Linewidth',4);

  s=sum(psize(d.region(pakreg),:));
  %plot(time,s,'r-');
  
  ax=plotyy(time,yi,time,s);
  set(ax,'Xlim',[-8000 -2000]);
  set(ax(1),'YLim',[0 5E4]);
  legend('Number of artifacts','location','NorthWest');
  axes(ax(2));
  legend('Population of Neolithic Indus valley','location','NorthEast');
 
end



return;
end

function index=cl_regionfind(lon1,lat1,lon2,lat2,rmax)

  if ~exist('rmax','var') rmax=500; end

  if size(lon1,1)==1 lon1=lon1'; end
  if size(lon2,1)==1 lon2=lon2'; end
  if size(lat1,1)==1 lat1=lat1'; end
  if size(lat2,1)==1 lat2=lat2'; end
  
  n1=length(lon1);
  n2=length(lon2);
  
  index=[];
  for i=1:n1
     lo1=repmat(lon1(i),n2,1);
     la1=repmat(lat1(i),n2,1);
     
     lo2=reshape([lo1,lon2]',2*n2,1);
     la2=reshape([la1,lat2]',2*n2,1);
     
     dist=m_lldist(lo2,la2);
     dist=dist(1:2:2*n2-1);
     [mindist,imindist]=min(dist);
     if mindist<=rmax index=vertcat(index,i); end
  end


return;
end














function none
%% Finds correlation between CRU and Indus varves
crufile='data/tyn_cru2.0_bycountry_pakistan.txt';
varvefile='data/indus_varves.mat';

cru=load(crufile,'-ascii');
varve=load(varvefile);
icru=find (cru(:,1)<1980 & cru(:,1)>1901);
ivarve=find (varve.year<1980 & varve.year>1901);

figure(1); clf reset;
plot(varve.year(ivarve),cl_normalize(varve.thick(ivarve)),'r-','Linewidth',3);

ropt=0
for i=2:18
  for j=30:80
    c=movavg(cru(icru,1),cru(icru,i),j);
    for k=-10:10
      v=varve.thick(ivarve+k);
      r=corrcoef(v,c);
      if abs(r(1,2))>abs(ropt)
        ropt=r(1,2); kopt=k; jopt=j; iopt=i;
        fprintf('%f %d %d %d\n',ropt,k,i,j);
      end
    end
  end
end
 
c=cl_normalize(movavg(cru(icru,1),cru(icru,iopt),jopt));
v=cl_normalize(varve.thick(ivarve+kopt));

hold off;
plot(varve.year(ivarve),v,'r-','Linewidth',3);
hold on;
p(i)=plot(cru(icru,1),c,'b-');
  
return

lonlim=[60,80];
latlim=[22 38];
clp_topography('latlim',latlim,'lonlim',lonlim);
m_proj('equidistant','lat',latlim,'lon',lonlim);

%%
file='data/plasim_11k.nc';
ncid=netcdf.open(file,'NOWRITE');
varid=netcdf.inqVarID(ncid,'lat'); lat=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'lon'); lon=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'time'); time=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'lsp'); prec=netcdf.getVar(ncid,varid);
netcdf.close(ncid);

halflat=mean([lat(2:end)';lat(1:end-1)']);
halflon=mean([lon(2:end)';lon(1:end-1)']);
lon(lon>180)=lon(lon>180)-360;
halflon(halflon>180)=halflon(halflon>180)-360;

ilat=find(halflat>=latlim(1) & halflat<=latlim(2));
ilon=find(halflon>=lonlim(1) & halflon<=lonlim(2));

for i=1:length(ilat)
  m_plot(lonlim,repmat(halflat(ilat(i)),1,2),'w-');
end
for i=1:length(ilon)
  m_plot(repmat(halflon(ilon(i)),1,2),latlim,'w-');
end

ilat=find(lat>=latlim(1) & lat<=latlim(2));
ilon=find(lon>=lonlim(1) & lon<=lonlim(2));

prec=prec(ilon,ilat,:,:);

p=reshape(prec,[length(ilon) length(ilat) 12 220]);
ap=sum(p,3);
figure(2);
plot(1:220,squeeze(ap(3,3,:)),'b-');


%%
return



clp_single_redfit('file','data/indus_varves_red.mat','lim',[-50,30],'freqlim',[1/5000 1/5],'xticks',30);
plot_multi_format(1,'../plots/indus_varves_red');

clp_single_redfit('file','data/indus_varves_red.mat','lim',[-50,30],'freqlim',[1/5000 1/30]);
plot_multi_format(1,'../plots/indus_varves_red_centennial');
clp_single_redfit('file','data/indus_varves_red.mat','lim',[-50,30],'freqlim',[1/30 1/5]);
plot_multi_format(1,'../plots/indus_varves_red_decadal');
 
return

%clp_nc_Helveticaeries('file','../../src/test/plasim_11k.nc','latlim',[24,37],'lonlim',[67,76],'variable','lsp');
 

%return
v=clp_varves('timelim',[1901,2010]);
r=clp_cru_bycountry('timelim',[1901,2010]);

figure(5); clf reset;
v.year=flipud(v.year);
v.thick=flipud(v.thick);
plot(v.year,v.thick*100,'r-','Linewidth',4);

hold on;
plot(r.year,r.wetseason,'c-','LineWidth',1);
plot(r.year,movavg(r.year,r.wetseason,3),'b-','LineWidth',2);
legend('Varve thickness','Wet season rain','3-year running');

iyear=1:length(v.year);
[s,p]=corrcoef([v.thick(iyear),r.wetseason(iyear),r.annual(iyear)]);
[i,j]=find(p<0.05);

plot([1964:2010],repmat(60,47,1),'y-','LineWidth',10);
text(1980,60,'Dams','Color','k','FontSize',15,'FontName','Helvetica');


title('Indus varve thickness and Pakistan rainfall');
plot_multi_format(5,'varves_and_rainfall');

return

% Plot SWAT valley data
variables='pre';
nosum=1;
file='data/cru_ts_3_00.1901.2006.pre.nc';
mult=0.1;
lim=[0 600];
clp_nc_Helveticaeries('nosum',nosum,'mult',mult,'lim',lim,'latlim',[35,35.3],'lonlim',[71.7,71.8],'file',file,'variables',variables,'figoffset',0,'Helveticatep',12,'timelim',[31*12+7,141*12+7]);
title('August precip 35.25N 71.75W from CRU TS3.0');
plot(datenum(now),217,'md','MarkerSize',20,'MarkerFaceColor','m');
plot_multi_format(3,'precipitation_dir');


figure(1);
clf reset;
m_proj('equidistant','lat',[23 38],'lon',[60 78]);
m_coast('patch',[1 .80 .7]);
m_elev('contourf',[250:250:8000]);
m_grid('box','fancy','tickdir','in');
colormap(flipud(bone));
m_gshhs('ib','color','red','linewidth',1.5,'linestyle',':'); % plot boundaries in high resolution
m_gshhs('hr'); % plot boundaries in high resolution
m_plot(71+52/60.+29.72/3600.,35+11/60.+51.58/3600.,'ro','MarkerFaceColor','r','MarkerEdgeColor','k','MarkerSize',10); % Dir, PK
m_text(72.5,35+11/60.+51.58/3600.,'Dir','Color','r','FontSize',14,'FontName','Helvetica');
m_plot(68+52/60.+1.57/3600,27+41/60.+19.03/3600.,'ro','MarkerFaceColor','r','MarkerEdgeColor','k','MarkerSize',10); % Sukkur, PK
m_text(68,28.3,'Sukkur','Color','r','FontSize',14,'FontName','Helvetica');

plot_multi_format(1,'map_of_pakistan')


% Plots CRU TS 3.0 Helveticaeries of precipitation in various areas of Pakistan
variables='pre';
nosum=1;
file='data/cru_ts_3_00.1901.2006.pre.nc';
mult=0.1;
lim=[0 1000];
clp_nc_Helveticaeries('nosum',nosum,'mult',mult,'lim',lim,'latlim',[33,37],'lonlim',[70,76],'file',file,'variables',variables,'figoffset',0);
title('Hindukush rainfall from CRU TS3.0');
plot_multi_format(gcf,'precipitation_hindukush');

clp_nc_Helveticaeries('nosum',nosum,'mult',mult,'lim',lim,'latlim',[30,33],'lonlim',[70,77],'file',file,'variables',variables,'figoffset',1);
title('Punjab rainfall from CRU TS3.0');
plot_multi_format(gcf,'precipitation_punjab');

clp_nc_Helveticaeries('nosum',nosum,'mult',mult,'lim',lim,'latlim',[24,30],'lonlim',[67,72],'file',file,'variables',variables,'figoffset',2);
title('Sindh rainfall from CRU TS3.0');
plot_multi_format(gcf,'precipitation_sindh');


clp_ncep_Helveticaeries('latlim',[24,30],'lonlim',[67,72],'lim',[0 200]);
clp_ncep_Helveticaeries('latlim',[30,33],'lonlim',[70,77],'lim',[0 200]);
clp_ncep_Helveticaeries('latlim',[33,37],'lonlim',[70,76],'lim',[0 200]);

end