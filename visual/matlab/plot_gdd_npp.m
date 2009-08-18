function plot_gdd_npp(regs)
%  Reads the mat binary $(map).mat and
%  displays the regions within geographical limits or
%  as indexed by index

cl_register_function();

[d,f]=get_files;

if ~exist('regionpath.mat','file')
    fprintf('Required file regionpath.mat not found, please run calc_regionmap_outline.\n');
    return
end

load('regionpath');

nppfile=fullfile(d.setup,'reg_npp_80_686.dat');
if ~exist(nppfile,'file')
    fprintf('Required file nppfile not found, please contact distributor.\n');
    return
end
npp=load(nppfile,'-ascii')';

gddfile=fullfile(d.setup,'reg_gdd_80_686.dat');
if ~exist(gddfile,'file')
    fprintf('Required file gddfile not found, please contact distributor.\n');
    return
end
gdd=load(gddfile,'-ascii')';

time=12000-500.*[0:22];

regs=find_region_numbers('med');

if nargin==1
  if all(isletter(varargin{1})) var=varargin{1};
  else regs=varargin{1};
  end
elseif nargin>1
  for iarg=1:2:nargin
    switch lower(varargin{iarg}(1:3))
      case 'reg' 
        regs=varargin{iarg+1};
      case 'var'
        variable=varargin{iarg+1};
    end
  end
end

npp=npp(regs,:);
gdd=gdd(regs,:);
nfig=4;
ncol=64;
  
for ireg=1:length(regs)
    reg=regs(ireg);
    valid=find(isfinite(regionpath(regs(ireg),:,1)) & regionpath(regs(ireg),:,1)>-199);
    regioncenter(ireg,1:2)=mean([regionpath(regs(ireg),valid,1)+0.5;regionpath(regs(ireg),valid,2)+1]',1);
end

regioncenter=regioncenter(1:length(regs),:);

data=zeros([nfig,size(npp)]);
ranges=zeros(nfig,2);
color=zeros(nfig,length(regs));

ndommaxlae=550;
fep=hyper(1.5*ndommaxlae,npp,2);
icefrac=repmat(icefraction(regioncenter(:,1),regioncenter(:,2)),1,23);
lae=hyper(ndommaxlae,icefrac.*npp,4);

data(1,:,:)=npp;
data(2,:,:)=gdd;
data(3,:,:)=fep;
data(4,:,:)=lae;

titles={'Net primary production (g m^{-2} a^{-1})',
    'Growing days above zero degrees (d a^{-1})',
    'Natural fertility (FEP)'
    'Local potential for agricultural economies (LAE)'};

shortnames={'npp','gdd','fep','lae'};

cmap=colormap(rainbow(ncol));

for ifig=1:nfig
    ranges(ifig,:)=[min(min(data(ifig,:,:))),max(max(data(ifig,:,:)))];
end

nt=1;

latlim=[27,55];
lonlim=[-15,42];

for it=1:nt

for ifig=1:nfig
    color(ifig,:)=round((data(ifig,:,it)-ranges(ifig,1))/(ranges(ifig,2)-ranges(ifig,1))*63)+1;
end

for ifig=1:nfig
    
  figure(ifig);
  if ~ishold 
    set(gcf,'PaperOrientation','landscape');
    clf reset;
    m_proj('Miller','lon',lonlim,'lat',latlim);
    m_grid; 
    hold on;
  end
  
  for ireg=1:length(regs)
    reg=regs(ireg);
    valid=find(isfinite(regionpath(regs(ireg),:,1)) & regionpath(regs(ireg),:,1)>-199);
    hdl(ifig,ireg)=m_patch(regionpath(regs(ireg),valid,1)+0.5,regionpath(regs(ireg),valid,2)+1,cmap(color(ifig,ireg,it),:));
    h=hdl(ifig,ireg);
    set(h,'ButtonDownFcn',@onclick,'UserData',squeeze(data(ifig,ireg,:)));
  end
  
  cb=colorbar;
  colormap(cmap);
  ytl=str2num(get(cb,'YTickLabel'));
  if ifig<3
   ytv=10*round((ytl*(ranges(ifig,2)-ranges(ifig,1))+ranges(ifig,1))/10);
  else
   ytv=(ytl*(ranges(ifig,2)-ranges(ifig,1))+ranges(ifig,1));
  end   
  set(cb,'YTickLabel',num2str(ytv));
  tnpp=title(titles{ifig});
  plot_multi_format(1,fullfile(d.plot,['gdd_npp_' shortnames{ifig}]));
end
end  

npp=[0:1400];
icefrac=1.0;
fep=hyper(1.5*ndommaxlae,npp,2);
lae=hyper(ndommaxlae,icefrac.*npp,4);

figure(nfig+1);
clf reset;
hold on;
plot(npp,fep,'r.');
plot([ndommaxlae,ndommaxlae]*1.5,[0,1],'k--','color',[0.5 0.5 0.5],'Linewidth',4);
xlabel('Net primary production (g m^{-2} a^{-1})');
ylabel('Farming exploitation potential');
t=text(ndommaxlae*1.5-20,0.1,'Climate where agricultural yield is maximal','Horizontalalignment','right');
plot_multi_format(gcf,fullfile(d.plot,['gdd_npp_vs_fep']));

figure(nfig+2);
colors='rgbcm';
clf reset;
hold on;
plot([ndommaxlae,ndommaxlae],[0,1],'k--','color',[0.5 0.5 0.5],'Linewidth',4);
for i=1:5
  icefrac=i*0.2;
  p(i)=plot(npp,hyper(ndommaxlae,icefrac.*npp,4),'r-','color',colors(i),'LineWidth',2);
  xlabel('Net primary production (g m^{-2} a^{-1})');
  ylabel('Local agricultural economies');
end;
set(p(5),'LineWidth',4);
t=text(ndommaxlae+20,0.1,'Optimal domesticable plant/animal diversity','Horizontalalignment','left');
%legs=num2str([1:5]'*0.2);
%legend(p(i),legs);
plot_multi_format(gcf,fullfile(d.plot,['gdd_npp_vs_lae']));


figure(11); clf reset;
   
hold on;
set(gca,'XDir','reverse');
set(gca,'YLim',[ranges(1,1) ranges(1,2)]);

for ireg=1:length(regs)
    reg=regs(ireg);
    plot(time,squeeze(data(1,ireg,:)),'k-','color',cmap(color(ifig,ireg),:));
end

p1=plot(time,squeeze(data(1,1,:)));
set(p1,'Tag','timeseries','LineWidth',4);
hold off;
  

return
end

function offclick(gcbo,eventdata,handles)
set(gcbo,'ButtonDownFcn',@onclick);
return;
end

function onclick(gcbo,eventdata,handles)
uf=gcf;
ud=get(gcbo,'UserData');
figure(11);
children=get(gca,'Children');
c=get(children,'Tag');
ic=strmatch('timeseries',c);
pr=children(ic);
set(pr,'YData',ud);
set(gcbo,'ButtonDownFcn',@offclick);
figure(uf);
return;
end

function ifrac=icefraction(lon,lat)
  iceextent=[50,80,80,45];
  lat0=50;
  lat2=75;
  
  fac2=sqrt((iceextent(3)-lat).^2+(iceextent(4)+lon).^2)/iceextent(2);
  fac=(90-lat)/iceextent(1);
  ile=find(fac2<fac);
  fac(ile)=fac2(ile);
  ile=find(fac>1);
  fac(ile)=90+lat(ile)/iceextent(1);
  ile=find(fac>1);
  fac(ile)=1;
  
  ifrac=fac;
  return;
end
  
