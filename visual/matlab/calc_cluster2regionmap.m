function calc_cluster2regionmap(varargin)




% regionlength(nreg,1) number of cells in region
% regionnumber(nland,1) region id of cell
% regionarray(nreg,maxlength) geo id (1:nlat*nlon) of region and cell)
% regionindex(nland,1) geo id of cell
% regionmap(nlon,nlat) region id of cell

cl_register_function();


clusterfile='cluster_-65_085_-180_0180_0100_0200_02068_clean_9';

load(clusterfile);
nland=length(cluster.cid);

clat=cluster.lat;
clon=cluster.lon;

ucid=unique(cluster.cid);
nreg=length(ucid);
region.length=zeros(nreg,1);
land.region=zeros(nland,1);

iiasa=load('iiasa');
[t,r]=strtok(clusterfile,'_');
[t,r]=strtok(r,'_'); latlim(1)=str2num(t);
[t,r]=strtok(r,'_'); latlim(2)=str2num(t);
[t,r]=strtok(r,'_'); lonlim(1)=str2num(t);
[t,r]=strtok(r,'_'); lonlim(2)=str2num(t);
  ivalid=find(iiasa.lon<lonlim(2) & iiasa.lon>lonlim(1) & iiasa.lat<latlim(2) & iiasa.lat>latlim(1));
  if isempty(ivalid) error('No data in lat/lon range in IIASA database'); end
  nvalid=length(ivalid);

 prec=iiasa.prec(ivalid,:);
 tmean=iiasa.tmean(ivalid,:);
 gdd=sum(tmean>0,2)*30.;
 prec=sum(prec,2);
 tmean=mean(tmean,2);
 npp=cl_npp_lieth(tmean,prec);

 

for ireg=1:nreg
  inreg=find(cluster.cid==ucid(ireg));
  region.length(ireg)=length(inreg);
  land.region(inreg)=ireg;
end

maxlength=max(region.length);
region.land=zeros(nreg,maxlength)+NaN;

% Establish half-degree grid
nlat=360; nlon=720;
[latgrid,longrid]=calc_geogrid(nlat,nlon);

ilon=calc_lon2ilon(clon,nlon);
ilat=361-calc_lat2ilat(clat,nlat);

land.map=geoidx2regidx(ilon,ilat,nlon);
map.region=zeros(nlon,nlat);
map.region(land.map)=land.region;

for ireg=1:nreg
    inreg=find(land.region==ireg);
    region.land(ireg,1:region.length(ireg))=land.map(inreg);
    region.npp(ireg)=mean(cluster.val(inreg));
    w=cosd(cluster.lat(inreg));
    region.lat(ireg,1)=sum(cluster.lat(inreg).*w)/sum(w);
    region.lon(ireg,1)=mean(cluster.lon(inreg));
    region.tmean(ireg,1)=sum(tmean(inreg).*w)/sum(w);
    region.npp(ireg,1)=sum(npp(inreg).*w)/sum(w);
    region.prec(ireg,1)=sum(prec(inreg).*w)/sum(w);
    region.gdd(ireg,1)=sum(gdd(inreg).*w)/sum(w);
end

regionmapfile=sprintf('regionmap_%d.mat',nreg);

land.lat=clat;
land.lon=clon;
map.latgrid=latgrid;
map.longrid=longrid;
region.latlim=latlim;
region.lonlim=lonlim;

save('-v6',regionmapfile,'region','map','land');

return
end
