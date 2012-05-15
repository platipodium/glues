function cl_create_regions(varargin)
% cl_create_regions(varargin
%   keywords latlim, lonlim, res
%   depends on read_gluesclimate
%   requires cl_register_functino, clp_arguments, clp_valuestring

cl_register_function;

arguments = {...
  {'latlim',[-60 70]},...
  {'lonlim',[-180 180]},...
  {'res',0.5},...
};

[args,rargs]=clp_arguments(varargin,arguments);
for i=1:args.length   
  eval([ args.name{i} ' = ' clp_valuestring(args.value{i}) ';']); 
end


%[lon,lat,npp,gdd]=read_gluesclimate;




ivalid=find(lon>=lonlim(1) & lon<=lonlim(2) & lat>=latlim(1) & lat<=latlim(2));
if isempty(ivalid) 
  error('No values found in lat/lon range');
end

n=length(ivalid);
lon=lon(ivalid);
lat=lat(ivalid);

% Choose a year on which to calculate region distribution
iyear=11;
npp=npp(ivalid,iyear);
gdd=gdd(ivalid,iyear);

c=npp; % center
ww=zeros(n,1)+NaN;
ee=ww; nn=ww; ss=ww;
ne=ww; se=ww; nw=ww; sw=ww;

minlon=min(lon);
maxlon=max(lon);
minlat=min(lat);
maxlat=max(lat);
eps=res/10;



figure(1); clf reset;
m_proj('miller','lon',lonlim,'lat',latlim);
m_plot(lon,lat,'k.','MarkerSize',1);
m_coast;
hold on;


gridfile=sprintf('cellneighbours_%.0f_%.0f_%0.f_%0.f.mat',minlon,maxlon,minlat,maxlat);

if 0==1 & exist(gridfile,'file')
    load(gridfile);
else
    for i=1:n
        jn=find(abs(lat-lat(i))<=res+eps & abs(lon-lon(i))<=res+eps);
        if isempty(jn) continue; end;
        if length(jn)>1 error('Cell found multiple times'); end
        
        j=jn(find(abs(lat(jn)-lat(i))<eps & abs(lon(jn)-lon(i)+res)<eps));
        if  ~isempty(j) 
            ww(i)=j;
            ee(j)=i;
        end

        j=jn(find(abs(lat(jn)-lat(i)+res)<eps & abs(lon(jn)-lon(i)+res)<eps));
        if  ~isempty(j) 
            sw(i)=j;
            ne(j)=i;
        end

        j=jn(find(abs(lat(jn)-lat(i)-res)<eps & abs(lon(jn)-lon(i)+res)<eps));
        if  ~isempty(j) 
            nw(i)=j;
            se(j)=i;
        end

       j=jn(find(abs(lat(jn)-lat(i)-res)<eps & abs(lon(jn)-lon(i))<eps));
        if  ~isempty(j) 
            nn(i)=j;
            ss(j)=i;
        end
        
      
        if (mod(i,1000)==0) fprintf('.'); end
    end
     % treat edges here
    save(gridfile,'nn','ne','ee','se','ss','sw','ww','nw');
end
   
%neigh=[ww,nw,nn,ne,ee,se,ss,sw];
neigh=[nn,ee,ss,ww];
nneigh=length(neigh(1,:))
empire=[1:n];
regions=zeros(n,100);
regions(:,1)=[1:n];
nregions=ones(n,1);
sel=[1:n]+NaN;



for k=1:100
in=floor(random('unif',1,nneigh+1,[n,1]));
j=nn+NaN;
for p=1:nneigh
  pind=find(in==p & isfinite(neigh(:,p)));
  sel(pind)=neigh(pind,p);
end

tolerance=max([0.1,log(k*10)]);

ind=find(isfinite(sel));
diff=abs(npp(ind)-npp(sel(ind)));

isim=ind(find(diff<tolerance));
nsim=length(isim);

for l=1:nsim
  i=isim(l);
  j=sel(isim(l));
  if (nregions(i)>0)
    if (nregions(i)>=nregions(j))
    
      regions(i,1:nregions(i)+nregions(j))=[regions(i,1:nregions(i)),regions(j,1:nregions(j))];
      nregions(i)=nregions(i)+nregions(j);
      regions(j,:)=NaN;
      nregions(j)=0;
      empire(j)=empire(i);
    else
    end
      regions(j,1:nregions(i)+nregions(j))=[regions(j,1:nregions(j)),regions(i,1:nregions(i))];
      nregions(j)=nregions(i)+nregions(j);
      regions(i,:)=NaN;
      nregions(i)=0;
      empire(i)=empire(j);
   
  else continue
  end
end

fprintf('%d %d\n',k,length(unique(empire)));
end

color='cmybgr';
e=find(nregions>10);

for ie=1:length(e)
    c=color(mod(ie,6)+1);
    m_plot(lon(regions(e(ie))),lat(regions(e(ie))),[c '.']);
end
return
