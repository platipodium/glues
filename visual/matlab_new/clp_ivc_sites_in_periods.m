function hdl = clp_ivc_period(varargin)


%% Load country boundaries
load('../../data/naturalearth/10m_admin_0_countries.mat');
countries=shape;
for i=1:length(countries)
    if strmatch(countries(i).SOVEREIGNT,'Pakistan') ipak=i;  end
    if strmatch(countries(i).SOVEREIGNT,'Afghanistan') iafg=i;  end
    if strmatch(countries(i).SOVEREIGNT,'China') ichi=i;  end
    if strmatch(countries(i).SOVEREIGNT,'Tajikistan') itaj=i;  end
    if strmatch(countries(i).SOVEREIGNT,'India') iind=i;  end
    if strmatch(countries(i).SOVEREIGNT,'Iran') iira=i;  end
end
plat=shape(ipak).Y;
plon=shape(ipak).X;
latlim=[min(plat) max(plat)] + 0.5*[-1 1];
lonlim=[min(plon) max(plon)] + 0.5*[-1 1];


% Rivers
load('../../data/naturalearth/ne_10m_rivers_lake_centerlines.mat');
rivers=shape;
rivernames={''};
for i=1:length(rivers) rivernames{i}=rivers(i).NAME; end

% Sites (from phyton extraction)
sites=load('/Users/lemmen/projects/glues/tex/2013/indusreview/site_chronology.csv');
periods={
  {[5000 4300],'Burj Basked-Marked'},
  {[4300 3200],'Developed Neolithic'},
  {[7000 4300],'Early Neolithic'},
  {[3200 1300],'IVC'},
  {[7000 3200],'Neolithic'},
  {[7000 5000],'Kili Ghul Muhammad'},
  {[5000 4300],'Burj Basked Marked'},
  {[4300 3800],'Togau'},
  {[3800 3200],'Hakra / Kechi Beg'},
  {[3200 2600],'Early Harappan'},
  {[2600 1900],'Mature Harappan'},
  {[2600 2200],'early Mature'},
  {[2200 1900],'later Mature'},
  {[1900 1300],'Late Harappan'},
  {[1900 1600],'early Late'},
  {[1600 1300],'later Late'},
  {[1300 700],'post-Harappan'},
};


baked={
  {[2500,1800],'Harappa',[72.86450478,30.6253336]},
  {[2600,1800],'Mohenjodaro',[68.13661226,27.32517596]},
  {[2500,1700],'Chanhudaro',[68.3222222222222,26.1727777777778]},
  {[2600,1800],'Kot Diji',[75.3902777777778,29.5975]},
  {[2600,1800],'Kalibangan',[74.1308333333333,29.4741666666667]},
  {[2600,1800],'Banawali',[75.3902777777778,29.5975]},
  {[2200,1900],'Rakhigarhi',[76.11388889,29.29166667]},
  {[2500,1500],'Lothal',[72.2498,22.522567]},
  {[2800,1500],'Jalilpur',[72.1166666666667,30.5333333333333]},
};


latlim=[20 35];
lonlim(2)=79.5;

close all

cmap=gray(256).^(0.25);
cmap(200:end,:)=1;
clw=1.5;
rlw=2;
mg=repmat(0.5,1,3);
dg=repmat(0.3,1,3);
lg=repmat(0.7,1,3);

for iperiod=1:length(periods)

  figure(iperiod);
  %if ~ishold(gca); 
    clf reset;   
    m_proj('equidistant','lat',latlim,'lon',lonlim);
    pe=clp_naturalearth('lat',latlim,'lon',lonlim);
  %end
      
  colormap(cmap);
  
  mafg=m_patch(countries(iafg).X,countries(iafg).Y,'y','FaceAlpha',1.,'EdgeColor',repmat(0.6,1,3),'EdgeAlpha',1,'LineStyle','--','LineWidth',clw);
  mind=m_patch(countries(iind).X,countries(iind).Y,'y','FaceAlpha',1.,'EdgeColor',repmat(0.6,1,3),'EdgeAlpha',1,'LineStyle','--','LineWidth',clw);
  mira=m_patch(countries(iira).X,countries(iira).Y,'y','FaceAlpha',1.,'EdgeColor',repmat(0.6,1,3),'EdgeAlpha',1,'LineStyle','--','LineWidth',clw);
  %mchi=m_patch(countries(ichi).X,countries(ichi).Y,'y','FaceAlpha',0.,'EdgeColor',repmat(0.6,1,3),'EdgeAlpha',1,'LineStyle','-','LineWidth',clw);
  %mtaj=0;%m_patch(countries(itaj).X,countries(itaj).Y,'y','FaceAlpha',1.,'EdgeColor',repmat(0.6,1,3),'EdgeAlpha',1,'LineStyle','-','LineWidth',clw);
  mpak=m_patch(plon,plat,'y','FaceAlpha',1.,'EdgeColor',repmat(0.6,1,3),'EdgeAlpha',1,'LineStyle','--','LineWidth',clw);
  mira=mira(mira>0);mafg=mafg(mafg>0);mind=mind(mind>0);%mtaj=mtaj(mtaj>0);
  mpak=mpak(mpak>0);
  set([mpak;mafg;mira;mind],'FaceColor','none','LineStyle','-','EdgeColor',lg);
  set(mafg,'EdgeColor','none');
  m_grid('box','on','backcolor','none','linestyle','none','Xtick',[],'Ytick',[]); hold on;
  %m_coast('color',mg);;
  set(gca,'color','none','XTick',[]);
  
  for i=1:length(rivers)
    
    if strcmp('Indus',rivers(i).NAME) | strcmp('Ravi',rivers(i).NAME) ...
            | strcmp('Sutlej',rivers(i).NAME) | strcmp('Beas',rivers(i).NAME) ...
            | strcmp('Chenab',rivers(i).NAME)  | strcmp('Jhelum',rivers(i).NAME) ...
            | strcmp('Yamuna',rivers(i).NAME)  | strcmp('Ganges',rivers(i).NAME)
      x=rivers(i).X;
      y=rivers(i).Y;
    %if any(x>lonlim(1)) & any(x<lonlim(2)) & any(y>latlim(1)) & any(y<latlim(2))
      pr(i)=m_plot(rivers(i).X,rivers(i).Y,'k-','LineWidth',rlw,'color',mg);
      fprintf('%s\n',rivers(i).NAME);
    end
  end
  ind=find(sites(:,3)>periods{iperiod}{1}(2) & sites(:,4)<periods{iperiod}{1}(1));
  pc=m_plot(sites(ind,1),sites(ind,2),'ks','Markersize',3,'tag','place',...
    'MarkerFaceColor',mg,'MarkerEdgeColor',dg);

  for i=1:length(baked)
      if baked{i}{1}(1)>periods{iperiod}{1}(2) & baked{i}{1}(2)<periods{iperiod}{1}(1)
        pb(i)=m_plot(baked{i}{3}(1),baked{i}{3}(2),'ks','Markersize',8,'tag','place',...
        'MarkerFaceColor','w','MarkerEdgeColor','k','LineWidth',2);
      end
  end

  infix=sprintf('%d_%d_%s_%d',periods{iperiod}{1}(1),periods{iperiod}{1}(2),periods{iperiod}{2},length(ind));
  infix=strrep(infix,'/','_');
  infix=strrep(infix,' ','_');
  
  cl_print('name',sprintf('ivc_sites_in_periods_%s',infix),'exp','pdf');
  hold off;
 
  
end


 
end