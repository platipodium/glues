function hdl = clp_ivc_indusreview(varargin)


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

latlim=[20 38];
lonlim(2)=79.5;

mg=repmat(0.6,1,3);

close all
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
  set([mb;mafg;mira;mind],'FaceColor','none','visible','off');
  m_grid; hold on;
  m_coast('line','color',mg,'Linestyle','-');

  
  %old=imread('/Users/lemmen/projects/glues/tex/2012/indusreview/grafik/schwartzberg_old_river_channels.png');
  %image(old);

  % Mark Inset picture
m_plot([69.5,77.5,77.5,69.5,69.5],[28.5 28.5 35.4 35.4 28.5],'k.-','color',repmat(0.7,1,3),'LineWidth',2);

  
cities = {'Mehrgarh','Harappa','Kili Ghul Mohammad','Togau','Kechi Beg','Koldihwa','Mahagara','Sheri Khan Tarakai'}; % for Chapman paper
cities = {'Mehrgarh','Amri','Kot Diji','Harappa','Mohenjo-Daro','Lothal','Dholavira',...
    'Kalibangan','Ganweriwala','Pirak','Nausharu','Surat'};%,'Bahawalpur','Multan'};

%  latcorr=[-0.2 -0.5 +0.4 0 0.4 0 0.3];
for i=1:length(cities)
  icity=strmatch(cities{i},data.sitename);
  if isempty(icity) fprintf('Did not find city %s. Skipped.\n',cities{i}); continue; end
  pc(i)=m_plot(data.longitude(icity(1)),data.latitude(icity(1)),'ko',...
  'MarkerFaceColor',repmat(0.5,1,3),'MarkerSize',7,'tag',[cities{i} '/' data.period{icity(1)}]);
end
end

% Additional cities
pc(i+1)=m_plot(67.799,29.315,'ko','MarkerFaceColor',repmat(0.5,1,3),...
    'MarkerSize',7,'tag','Pirak');
pc(i+2)=m_plot(71.467,30.208,'ko','MarkerFaceColor',repmat(0.5,1,3),...
    'MarkerSize',7,'tag','Multan');
pc(i+3)=m_plot(71.736603,29.796559,'ko','MarkerFaceColor',repmat(0.5,1,3),...
    'MarkerSize',7,'tag','Dunyapur');
pc(i+4)=m_plot(72.820129,21.199777,'ko','MarkerFaceColor',repmat(0.5,1,3),...
    'MarkerSize',7,'tag','Surat');


% Lakes
pl(1)=m_plot(74.575,27.430,'ks','MarkerFaceColor',repmat(0.8,1,3),...
    'MarkerSize',7,'tag','Didwana');
pl(2)=m_plot(73.184,28.0577,'ks','MarkerFaceColor',repmat(0.8,1,3),...
    'MarkerSize',7,'tag','Nal');
pl(3)=m_plot(73.7474,28.4877,'ks','MarkerFaceColor',repmat(0.8,1,3),...
    'MarkerSize',7,'tag','Lunkaransar');

% Core
pcore=m_plot( 65.916800,24.833300,'kh','MarkerFaceColor',repmat(0.8,1,3),...
    'MarkerSize',9,'tag','Core SO90-56KA');

% Passes
pp(1)=m_text(71.144,34.093,'=','Vertical','middle','horiz','center','color','k',...
    'tag','Khyber Pass','FontSize',14,'visible','off');


% Some markers
if 1==2
    m(1)=m_plot(70.683289,29.113775,'k+','MarkerSize',14); % Chenab-Indus confluence
  m(2)=m_plot(72.239914,33.920002,'k+','MarkerSize',14); % Kabul-Indus confluence
  m(3)=m_plot(74.972076,31.157584,'k+','MarkerSize',14); % Beas-Satluj confluence
  m(4)=m_plot(72.147217,31.169335,'k+','MarkerSize',14); % Jhelum-Chenab confluence
end

% Rivers
load('../../data/naturalearth/ne_10m_rivers_lake_centerlines.mat');
for i=1:length(rivers)
    
    if strcmp('Indus',rivers(i).NAME) | strcmp('Ravi',rivers(i).NAME) ...
            | strcmp('Sutlej',rivers(i).NAME) | strcmp('Beas',rivers(i).NAME) ...
            | strcmp('Chenab',rivers(i).NAME)  | strcmp('Jhelum',rivers(i).NAME) ...
            | strcmp('Yamuna',rivers(i).NAME)  | strcmp('Ganges',rivers(i).NAME) ...
            | strcmp('Kabul',rivers(i).NAME)  | strcmp('Swat',rivers(i).NAME) ...
      x=rivers(i).X;
      y=rivers(i).Y;
    %if any(x>lonlim(1)) & any(x<lonlim(2)) & any(y>latlim(1)) & any(y<latlim(2))
      pr(i)=m_plot(rivers(i).X,rivers(i).Y,'k-','LineWidth',1);
      fprintf('%s\n',rivers(i).NAME);
    end
end


cl_print('name','pakistan_map_with_cities','exp','pdf');
 
end