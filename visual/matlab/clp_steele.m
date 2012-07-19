function data=clp_steele(varargin)

% Spatial and Chronological Patterns in the Neolithisation of Europe
% James Steele, Stephen J. Shennan, 2000
% http://archaeologydataservice.ac.uk/archives/view/c14_meso/overview.cfm

%cl_register_function;

variables = {'period','long_decimal','lat_decimal','Cultural_Id','Sigma1_earliest','Sigma1_latest','Country'};

D=cl_query_steele('var',variables);
lon=D{2};
lat=D{3};
smin=D{5};
smax=D{6};
period=D{1};
smean=(smax+smin)/2;

figure(1); clf reset;
latlim=cl_minmax(lat); latlim=[50 60];
lonlim=cl_minmax(lon); lonlim=[5 20];
m_proj('equidistant','lon',lonlim,'lat',latlim);
hold on;
m_grid;
m_coast;

iv=find(lon>=lonlim(1) & lon<=lonlim(2) & lat>=latlim(1) & lat<=latlim(2));

m_plot(lon(iv),lat(iv),'k.');

figure(2); clf reset; hold on;

uperiod=unique(period);
timelim=cl_minmax(smean(iv));
edges=floor(timelim(1)/100)*100:100:ceil(timelim(2)/100)*100;

for i=1:length(uperiod);
  if isempty(uperiod{i}) continue; end
  j=strmatch(uperiod{i},period(iv));
  [n,bin] = histc(smean(iv(j)),edges);
  m(i)=median(smean(iv(j)));
  if isnan(m(i)) continue; end
  p(i)=bar(edges,n,'histc');
end

[msort,isort]=sort(m);
psort=p(isort);
ip=find(psort>0 & isfinite(msort));
nip=length(ip)
cmap=jet(nip);

ic=1;
for i=1:length(psort)
  if (psort(i)<=0 | isnan(msort(i))) continue; end
  set(psort(i),'FaceColor',cmap(ic,:),'FaceAlpha',0.3);
  ic=ic+1;
end

legend(psort(ip),uperiod(isort(ip)));
set(psort(ip(1:end)),'visible','off')


return
end


