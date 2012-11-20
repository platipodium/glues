function hdl = clp_ivc_oldrivers(varargin)


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


latlim=[28.5 34.5];
lonlim=[69.5 77.5];

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
  %mafg=m_patch(shape(iafg).X,shape(iafg).Y,'y','FaceAlpha',1.,'EdgeColor',repmat(0.6,1,3),'EdgeAlpha',1,'LineStyle','--','LineWidth',clw);
  %mind=m_patch(shape(iind).X,shape(iind).Y,'y','FaceAlpha',1.,'EdgeColor',repmat(0.6,1,3),'EdgeAlpha',1,'LineStyle','--','LineWidth',clw);
  %mira=m_patch(shape(iira).X,shape(iira).Y,'y','FaceAlpha',1.,'EdgeColor',repmat(0.6,1,3),'EdgeAlpha',1,'LineStyle','--','LineWidth',clw);
  %mchi=m_patch(shape(ichi).X,shape(ichi).Y,'y','FaceAlpha',0.,'EdgeColor',repmat(0.6,1,3),'EdgeAlpha',1,'LineStyle','-','LineWidth',clw);
  %mtaj=0;%m_patch(shape(itaj).X,shape(itaj).Y,'y','FaceAlpha',1.,'EdgeColor',repmat(0.6,1,3),'EdgeAlpha',1,'LineStyle','-','LineWidth',clw);
  %mb=m_patch(plon,plat,'y','FaceAlpha',1.,'EdgeColor',repmat(0.6,1,3),'EdgeAlpha',1,'LineStyle','--','LineWidth',clw);
  %mira=mira(mira>0);mafg=mafg(mafg>0);mind=mind(mind>0);%mtaj=mtaj(mtaj>0);
  %mb=mb(mb>0);
  %set([mb;mafg;mira;mind],'FaceColor','none');
  m_grid; hold on;

  
  %old=imread('/Users/lemmen/projects/glues/tex/2012/indusreview/grafik/schwartzberg_old_river_channels.png');
  %image(old);

  % Mark Inset picture
  

% Rivers
load('../../data/naturalearth/ne_10m_rivers_lake_centerlines.mat');
for i=1:length(rivers)
    
    if strcmp('Indus',rivers(i).NAME) | strcmp('Ravi',rivers(i).NAME) ...
            | strcmp('Sutlej',rivers(i).NAME) | strcmp('Beas',rivers(i).NAME) ...
            | strcmp('Chenab',rivers(i).NAME)  | strcmp('Jhelum',rivers(i).NAME) ...
            | strcmp('Yamuna',rivers(i).NAME)  | strcmp('Ganges',rivers(i).NAME)
      x=rivers(i).X;
      y=rivers(i).Y;
    %if any(x>lonlim(1)) & any(x<lonlim(2)) & any(y>latlim(1)) & any(y<latlim(2))
      pr(i)=m_plot(rivers(i).X,rivers(i).Y,'k-','LineWidth',1,'visible','off');
      fprintf('%s\n',rivers(i).NAME);
    end
end


load 'randall_ivc_data_periods.mat';
  
% Load the whole data set
data=load('../../data/randall_ivc_data');
rlat=data.latitude;
rlon=data.longitude;
randall=cl_randall_periods;

cities = {'Mehrgarh','Amri','Kot Diji','Harappa','Mohenjo-Daro','Lothal','Dholavira',...
    'Kalibangan','Ganweriwala','Pirak','Nausharu','Surat','Bahawalpur','Multan'};

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
pc(i+5)=m_plot(84.540052,23.048065,'ko','MarkerFaceColor',repmat(0.5,1,3),...
    'MarkerSize',7,'tag','Gumla');

% Early, mature, late
for i=[8 6 7]
  iperiod=randall.index{i};
  im=find(rlat(iperiod)>latlim(1) & rlat(iperiod)<latlim(2) & rlon(iperiod)>lonlim(1) & rlon(iperiod)<lonlim(2));
  pp(i)=m_plot(rlon(iperiod(im)),rlat(iperiod(im)),'ks','MarkerEdgeColor',...
      repmat(0.5,1,3),'MarkerSize',6,'LineWidth',2,'MarkerFaceColor','none');
end

%set(pp(7),'MarkerFaceColor',repmat(0.55,1,3),'MarkerEdgeColor',repmat(0.55,1,3));
%set(pp(8),'MarkerFaceColor',repmat(0.25,1,3),'MarkerEdgeColor',repmat(0.1,1,3));
set(pp(6),'MarkerEdgeColor',repmat(0.75,1,3));
set(pp(7),'MarkerEdgeColor',repmat(0.55,1,3));
set(pp(8),'MarkerEdgeColor',repmat(0.1,1,3));


cl_print('name','ivc_oldrivers','exp','pdf');
 
end