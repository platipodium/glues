function cl_calc_cluster(varargin)

cl_register_function;

% program switches
png=1;
avi=0;
ngoal=10;
fig=2;
latlim=[-65,85]; lonlim=[-180,180]; % World
%latlim=[27,55]; lonlim=[-15,42]; % Europe
%latlim=[-57,-45];lonlim=[-80,-55]; % Southamerica
dloncrit=0.5;
dlatcrit=0.5;

%refine=sprintf('cluster_%03d_%03d_%04d_%04d_02125.mat',latlim,lonlim);

if ~exist('refine','var')
  load('clustervalue');
  
  ivalid=find(lon<lonlim(2) & lon>lonlim(1) & lat<latlim(2) & lat>latlim(1));
  if isempty(ivalid) return; end
  nvalid=length(ivalid);

  lon=lon(ivalid);
  lat=lat(ivalid);
  value=value(ivalid);
  
  % normalize variables
  val=value./max(value);

  id=[1:nvalid]';
  csize(id,1)=1;
  cid(id,1)=id;
  clon(id,1)=lon(id);
  clat(id,1)=lat(id);

  nc=nvalid;
  nleft=nvalid;
  ndone=0;
  ileft=id;
  idone=[];
  neigh=zeros(nvalid,8)+NaN;
  simil=zeros(nvalid,8);
  weights=neigh;
else

% Load a file here
  if ~exist(refine,'file') return; end
  load(refine);

  nvalid=cluster.nvalid;
  lat=cluster.lat;
  lon=cluster.lon;
  ileft=cluster.ileft;
  nleft=length(ileft);
  idone=cluster.idone;
  ndone=length(idone);
  cid=cluster.cid;
  clon=cluster.clon;
  clat=cluster.clat;
  nvalid=length(cid);
  nc=length(unique(cid));
  weights=cluster.weights;
  itop=cluster.itop;
  val=cluster.val;
  csize=cluster.csize;
  id=[1:nvalid]'; 
  simil=cluster.simil;
  neigh=cluster.neigh;
  ivalid=cluster.ivalid;
end

optsize=100;
distcrit=200;

distweight=simil;
sizeweight=simil;
cidweight=ones(nvalid,8);

% Establish neighbour and similarity matrix
neighfile='clusterneighbours.mat';
if exist(neighfile) load(neighfile) 
else
  for i=1:-nvalid
    ineigh=find((abs(lon-lon(i))<=dloncrit |abs(abs(lon-lon(i))-360)<=dloncrit ) ...
            & abs(lat-lat(i))<=dlatcrit ...
            & cid~=cid(i));
    nneigh(i)=length(ineigh);
    neigh(i,1:nneigh(i))=ineigh;
    simil(i,1:nneigh(i))=1-abs(val(ineigh)'-val(i)); 
    if mod(i,1000)==0 fprintf('.'); end
  end
  save('-v6',neighfile,'nneigh','neigh','simil');
end

% neighbour statistics
for nn=0:8 nneighsum(nn+1)=sum(nneigh==nn); end;
fprintf('%6d: %6d %6d %6d %6d %6d %6d %6d %6d %6d\n',nvalid,[0:8]);
fprintf('%6d: %6d %6d %6d %6d %6d %6d %6d %6d %6d\n',sum(nneighsum),nneighsum);


colors='rgbcym';

if (fig>0) figure(1);
  clf reset;
  set(gcf,'DoubleBuffer','on');
  m_proj('miller','lat',latlim,'lon',lonlim);
  pk=m_plot(lon,lat,'k.');
  m_coast;
  m_grid;
  hold on;
end

if (fig>1) 
  figure(2);
  clf reset;
  set(gcf,'DoubleBuffer','on');
  m_proj('miller','lat',latlim,'lon',lonlim);
  m_coast;
  m_grid;
  hold on;
end

if (fig>0 & png) system('mkdir -p ../plots/calc_cluster/'); end

if avi
  if (fig>0) avir=avifile('../plots/calc_cluster_regions.avi'); end
  if (fig>1) avid=avifile('../plots/calc_cluster_diagnostic.avi'); end
  %aviv=avifile('../plots/calc_cluster_val.avi');
end

count=0;
while (nleft>0 && nc>ngoal)
    
  count=count+1;
    
  % Establish center-distance and size weights    
  for il=1:nleft
    i=ileft(il);
    if nneigh(i)<1 continue; end
    ineigh=neigh(i,1:nneigh(i));
    %distweight(i,1:nneigh(i))=...
    %  exp(-((clon(ineigh)-clon(i)).^2+(clat(ineigh)-clat(i)).^2)/10.);
    dlon=[repmat(clon(i),1,nneigh(i))',clon(ineigh)];
    dlon=reshape(dlon',nneigh(i)*2,1);
    dlat=[repmat(clat(i),1,nneigh(i))',clat(ineigh)];
    dlat=reshape(dlat',nneigh(i)*2,1);
    dist=m_lldist(dlon,dlat);
    dist=dist(1:2:end);%-100;
    %dist(dist<0)=0;
    distweight(i,1:nneigh(i))=min(1,exp(-((dist'-distcrit)/distcrit)));
    
    sizeweight(i,1:nneigh(i))=1;%...
      %exp(-(csize(i)-optsize).^2/optsize^2)...
      %*exp(-(csize(ineigh)-optsize).^2/optsize^2);
  end

  %[simsum,isim]=sort(sum(simil.*distweight.*repmat(sizeweight,1,8),2));

  weights(ileft,:)=simil(ileft,:).*distweight(ileft,:).*sizeweight(ileft,:).*cidweight(ileft,:);
  %weights(ileft,:)=simil(ileft,:).*cidweight(ileft,:).*sizeweight(ileft,:);

  weight(ileft)=max(weights(ileft,:),[],2);
  [simsum,isim]=sort(weight(ileft));

  itop=ileft(isim(end:-1:end-10));
  %fprintf('%6d ',itop);fprintf('\n');
  %fprintf('%6.3f ',weight(itop)); fprintf('\n');
  itop=ileft(isim(end:-1:round(nleft*0.9)));

if (fig>0) figure(1); end;
%if exist('pk') delete(pk); end
%pk=m_plot(lon,lat,'k.');
for ir=nleft:-1:round(nleft*0.9);
   i=ileft(isim(ir));
   %if csize(i)>1; continue; end
   [maxneigh,imaxneigh]=max(weights(i,:));
   in=neigh(i,imaxneigh);
   if cid(in)==cid(i) 
       %warning('something wrong here')
       cidweight(i,imaxneigh)=0;
       %fprintf('%d %d\n',i,in);
   
     continue; 
   end;
   %fprintf('%d %d\n',i,in);
   
   
   icn=find(cid==cid(in));
   cid(icn)=cid(i);
   
   ic=find(cid==cid(i));
   
   if (fig>0) m_plot(lon(ic),lat(ic),'k.','color',colors(mod(ir,6)+1)); end
   csize(ic)=length(ic);
   clon(ic)=mean(lon(ic));
   clat(ic)=mean(lat(ic));

   cidweight(i,imaxneigh)=0;
end;


% attach singular regions;
for nn=1:8
  in=find(nneigh==nn);
  nin=length(in);
  if nin==0 continue; end
  if nin>1
    ising=find(all(abs(cid(neigh(in,1:nn))-repmat(cid(neigh(in,1)),1,nn))==0,2)...
        & cid(neigh(in,1))~= cid(in));
  else
    ising=find(all(abs(cid(neigh(in,1:nn))-cid(neigh(in,1)))==0) & cid(neigh(in,1))~= cid(in));
  end
  nsing=length(ising);
  if nsing==0 continue; end

  cid(in(ising))=cid(neigh(in(ising),1));
  if (fig>1) figure(2); m_plot(lon(in(ising)),lat(in(ising)),'m.'); end;
  for is=1:length(ising)
     icid=in(ising(is));
   
     ic=find(cid==cid(icid));
     
     csize(ic)=length(ic);
     clon(ic)=mean(lon(ic));
     clat(ic)=mean(lat(ic));
   end
  
end

number=sprintf('%03d',count);
if (fig>0 & png) print('-dpng',['../plots/calc_cluster/' number '_region']); end

if (fig>1) figure(2); 
  ncol=20;
  cmap=colormap(rainbow(ncol));
  wcol=round((weight-min(weight))/(max(weight)-min(weight))*ncol)+1;

  if exist('pc') delete(pc); end
  if exist('pl') delete(pl); end
  if exist('pt') delete(pt); end
  %pw=m_plot(lon,lat,'k.','color',cmap(wcol,:));
  pc=m_plot(clon,clat,'ko','color',[0.5 0.5 0.5]);
  if nleft>0 pl=m_plot(lon(ileft),lat(ileft),'rd','MarkerSize',3); end;
  if ndone>0 pd=m_plot(lon(idone),lat(idone),'kd','MarkerSize',3); end;
  pt=m_plot(lon(itop),lat(itop),'ys','MarkerSize',5);
  %il=ileft(isim(round(nleft/(irep+1)):end))
  %pr=m_plot(lon(il),lat(il),'kd','color','b','MarkerSize',3);

  for icol=1:-ncol+1
    incol=find(wcol==icol);
    if isempty(incol) continue; end
    pl=m_plot(lon(incol),lat(incol),'k.','Color',cmap(icol,:));
  end
end

nc=length(unique(cid));

ileft=[];
idone=[];
for nn=1:8
  in=find(nneigh==nn);
  nin=length(in);
  if nin==0 continue; end;
  if nin>1
    iany=find(any(abs(cid(neigh(in,1:nn))-repmat(cid(in),1,nn))>0,2));
    iall=find(all(abs(cid(neigh(in,1:nn))-repmat(cid(in),1,nn))==0,2));
  else
    iall=find(all(abs(cid(neigh(in,1:nn))-cid(in))==0))   
    iany=find(any(abs(cid(neigh(in,1:nn))-cid(in))==0))   
    
  end
  ileft=[ileft,in(iany)];
  idone=[idone,in(iall)];
end
ileft=unique(ileft);
idone=unique(idone);
nleft=length(ileft);
ndone=length(idone);

if (fig>0 & png) print('-dpng',['../plots/calc_cluster/' number '_gradient']); end
   
fprintf('nleft/ndone=%d/%d nc=%d med(cs)=%d max(cs)=%d\n',nleft,ndone,nc,median(csize),max(csize));

if 1==0
figure(3);
ucid=unique(cid);
if exist('pu')
    for i=1:length(pu) delete(pu(i)); end
    clear('pu');
end
for i=1:nc
  ic=find(cid==ucid(i));
  pu(i)=m_plot(lon(ic),lat(ic),'k.','color',mean(val(ic))*0.8*[1,1,1]+0.1);
end
end;

if avi
  if (fig>0) avir=addframe(avir,1); end
  if (fig>1) avid=addframe(avid,2); end
  %aviv=addframe(aviv,3);
end
  

  %if nc<ngoal
cluster.nc=nc;
cluster.lat=lat;
cluster.lon=lon;
cluster.cid=cid;
cluster.clon=clon;
cluster.clat=clat;
cluster.csize=csize;
cluster.val=val;
cluster.weights=weights;
cluster.ileft=ileft;
cluster.itop=itop;
cluster.idone=idone;
cluster.lon=lon;
cluster.lat=lat;
cluster.nvalid=nvalid;
cluster.ivalid=ivalid;
cluster.nneigh=nneigh;
cluster.neigh=neigh;
cluster.simil=simil;
cluster.optsize=optsize;
cluster.distcrit=distcrit;

    clusterfile=sprintf('cluster_%03d_%03d_%04d_%04d_%04d_%04d_%05d.mat',latlim,lonlim,optsize,distcrit,nc);

    save('-v6',clusterfile,'cluster')
    %break; 
 % end
end

if avi
  if (fig>0) avir=close(avir); end
  if (fig>1) avir=close(avid); end
  %aviv=close(aviv);
end
return
end
