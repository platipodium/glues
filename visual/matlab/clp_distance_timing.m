function retdata=clp_distance_timing(varargin)

arguments = {...
  {'timelim',[-8000,-4000]},...
  {'file','../../eurolbk_base.nc'},...
  {'data','neolithicsites.mat'},...
  {'reg','lbk'},...
  {'retdata',NaN},...
};

cl_register_function;

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length 
  eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); 
end

%% Do Ammerman plot 
figure(1); clf reset; hold on;
set(gcf,'Units','centimeters','Position',[0 0 18 18]);
% Single column 90 mm 1063 1772 3543 
% 1.5 column 140 mm 1654 2756 5512
% Full width 190 mm 2244 3740 7480

ncid=netcdf.open(file,'NOWRITE');
varid=netcdf.inqVarID(ncid,'region');
region=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'time');
time=netcdf.getVar(ncid,varid);
itime=find(time>=timelim(1) & time<=timelim(2));
time=time(itime);
varid=netcdf.inqVarID(ncid,'farming');
farming=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'latitude');
lat=double(netcdf.getVar(ncid,varid));
varid=netcdf.inqVarID(ncid,'longitude');
lon=double(netcdf.getVar(ncid,varid));
netcdf.close(ncid);
nreg=length(region);

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
  


if ~exist('neolithicsites.mat','file')
    fprintf('Required file neolithicsites.mat not found, please contact distributor.\n');
    return
end


load('neolithicsites');
slat=Forenbaher.Latitude;
slon=Forenbaher.Long;
period=Forenbaher.Period;
site=Forenbaher.Site_name;
sage=Forenbaher.Median_age;
ns=length(sage);
dlat=[slat' repmat(lat(272),ns,1)];
dlat=reshape(dlat',2*ns,1);
dlon=[slon' repmat(lon(272),ns,1)];
dlon=reshape(dlon',2*ns,1);
sdists=m_lldist(dlon,dlat);
sdists=sdists(1:2:end);

[ifound,nfound,lonlim,latlim]=find_region_numbers(reg);
farming=farming(ifound,itime);

ncol=19;
cmap=flipud(jet(ncol));
stime=1950-sage;
sutime=stime+(Forenbaher.Lower_cal-Forenbaher.Median_age);
sltime=stime+(Forenbaher.Upper_cal_-Forenbaher.Median_age);
srange=sutime-sltime;
iscol=floor((stime-min(timelim))./(timelim(2)-timelim(1))*ncol)+1;
viscol=find(iscol>0 & iscol<=ncol & slat>=latlim(1) & slat<=latlim(2) ...
    & slon>=lonlim(1) & slon<=lonlim(2));
  



i272=find(ifound==272);

dlat=[lat repmat(lat(272),nreg,1)];
dlat=reshape(dlat',2*nreg,1);
dlon=[lon repmat(lon(272),nreg,1)];
dlon=reshape(dlon',2*nreg,1);
dists=m_lldist(dlon,dlat);
dists=dists(1:2:end);
dists=dists(ifound);
threshold=0.5;
it=(farming>=threshold).*repmat(1:length(itime),nfound,1);
it(it==0)=inf;
it=min(it,[],2);
itv=isfinite(it);
onset=zeros(nfound,1)+inf;
onset(itv)=time(min(it(itv),[],2));

gtime=timelim(1):200:timelim(2);

set(gca,'color','none','FontSize',14,'FontName','Times');
p1=plot(-stime,sdists,'bo','MarkerFaceColor','none','MarkerSize',2);
ylabel('Distance from Levante (km)');
xlabel('Time (year BC)'); 
set(gca,'Xlim',-fliplr([timelim]));
set(gca,'XDir','reverse');
p2=plot(-onset,dists,'rd','MarkerFaceColor','r','MarkerSize',5)
%plot(7500:-200:3500,0:200:4000,'k--');

pf1=polyfit(-onset(itv),dists(itv),1);
p4=plot(-gtime,-gtime*pf1(1)+pf1(2),'r-','LineWidth',2);
pf2=polyfit(-stime(viscol)',sdists(viscol),1);
% Indistiguishable, thus not shown
%plot(-gtime,-gtime*pf2(1)+pf2(2),'b--','MarkerSize',2);

[cr1,cp1]=corrcoef(onset(itv),dists(itv));
[cr2,cp2]=corrcoef(stime(viscol),sdists(viscol));

ytl=get(gca,'YTickLabel');
ytl(1,:)=' ';
set(gca,'YTickLabel',ytl);

l=legend([p1,p2],sprintf('Site data (n=%d, r^2=%.2f, v=%.2f km a^{-1})',length(viscol),cr2(2).^2,-pf2(1)),...
    sprintf('Simulation (n=%d, r^2=%.2f, v=%.2f km a^{-1})',length(itv),cr1(2).^2,-pf1(1)),...
    'location','NorthWest','FontSize',7);
%set(l,'color','none');

[fp fn fe]=fileparts(file);

plot_multi_format(1,['distance_timing_rgb_' fn],'pdf');


%% Do black and white version
%set([p2,p1,p4],'Color',repmat(0,3,1));
%set(p2,'MarkerFaceColor',repmat(0,3,1));
%plot_multi_format(1,'dinstance_timing_bw','pdf');
if nargout>0
   retdata=[cr1(2),cp1(2),-pf1(1)]
end

return
end