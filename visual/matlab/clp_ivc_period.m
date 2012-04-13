function hdl = clp_ivc_period(varargin)


%% Load country boundaries
load('../../data/naturalearth/10m_admin_0_countries.mat');
for i=1:length(shape)
    if strmatch(shape(i).SOVEREIGNT,'Pakistan') ipak=i;  end
    if strmatch(shape(i).SOVEREIGNT,'Afghanistan') iafg=i;  end
    if strmatch(shape(i).SOVEREIGNT,'China') ichi=i;  end
    if strmatch(shape(i).SOVEREIGNT,'Tajikistan') itaj=i;  end
    if strmatch(shape(i).SOVEREIGNT,'India') iind=i;  end
    if strmatch(shape(i).SOVEREIGNT,'Iran') iira=i;  end
end
plat=shape(ipak).Y;
plon=shape(ipak).X;
latlim=[min(plat) max(plat)] + 0.5*[-1 1];
lonlim=[min(plon) max(plon)] + 0.5*[-1 1];

data=load('../../data/randall_ivc_data');

latlim=[22 35.5];
lonlim(2)=77.0;


clw=1;
figure(1);
if ~ishold(gca); clf reset;   
    
  m_proj('equidistant','lat',latlim,'lon',lonlim,'rot',30);
  pe=clp_naturalearth('lat',latlim,'lon',lonlim);
  cmap=gray.^(0.25);
  cmap(200:end,:)=1;
  %cmap=cmap(50:end,:);
  colormap(cmap);
  %m_gshhs('hr','color',repmat(0.7,1,3),'linewidth',1,'tag','river');
  mafg=m_patch(shape(iafg).X,shape(iafg).Y,'y','FaceAlpha',1.,'EdgeColor',repmat(0.6,1,3),'EdgeAlpha',1,'LineStyle','--','LineWidth',clw);
  mind=m_patch(shape(iind).X,shape(iind).Y,'y','FaceAlpha',1.,'EdgeColor',repmat(0.6,1,3),'EdgeAlpha',1,'LineStyle','--','LineWidth',clw);
  mira=m_patch(shape(iira).X,shape(iira).Y,'y','FaceAlpha',1.,'EdgeColor',repmat(0.6,1,3),'EdgeAlpha',1,'LineStyle','--','LineWidth',clw);
  %mchi=m_patch(shape(ichi).X,shape(ichi).Y,'y','FaceAlpha',0.,'EdgeColor',repmat(0.6,1,3),'EdgeAlpha',1,'LineStyle','-','LineWidth',clw);
  %mtaj=0;%m_patch(shape(itaj).X,shape(itaj).Y,'y','FaceAlpha',1.,'EdgeColor',repmat(0.6,1,3),'EdgeAlpha',1,'LineStyle','-','LineWidth',clw);
  mb=m_patch(plon,plat,'y','FaceAlpha',1.,'EdgeColor',repmat(0.6,1,3),'EdgeAlpha',1,'LineStyle','--','LineWidth',clw);
  mira=mira(mira>0);mafg=mafg(mafg>0);mind=mind(mind>0);%mtaj=mtaj(mtaj>0);
  mb=mb(mb>0);
  set([mb;mafg;mira;mind],'FaceColor','none');
  m_grid; hold on;


cities = {'Mehrgarh','Harappa','Kili Ghul Mohammad','Togau','Kechi Beg','Koldihwa','Mahagara','Sheri Khan Tarakai'}

%  latcorr=[-0.2 -0.5 +0.4 0 0.4 0 0.3];
for i=1:-length(cities)
  icity=strmatch(cities{i},data.sitename);
  if isempty(icity) continue; end
  pc(i)=m_plot(data.longitude(icity(1)),data.latitude(icity(1)),'ko',...
  'MarkerFaceColor',repmat(0.3,1,3),'MarkerSize',7,'tag',[cities{i} '/' data.period{icity(1)}]);
end
end 

 
end