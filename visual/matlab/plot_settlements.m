function plot_settlements

cl_register_function();

load('neolithicsites');

lat=Forenbaher.Latitude;
lon=Forenbaher.Long;
period=Forenbaher.Period;
site=Forenbaher.Site_name;
age=Forenbaher.Median_age;

n=length(lon);
latlim=[min(lat)-1,max(lat)+1];
lonlim=[min(lon)-1,max(lon)-1];

for i=1:n
  period{i}=strrep(period{i},' ','');
  period{i}=strrep(period{i},'?','');
  period{i}=strrep(period{i},'II','I');
%  period{i}=strrep(period{i},'I','');
  period{i}=strrep(period{i},'.','');
  period{i}=strrep(period{i},'-','');
  period{i}=strrep(period{i},'1','');
  period{i}=strrep(period{i},'3','');
  period{i}=strrep(period{i},'4','');
  period{i}=strrep(period{i},'Cypro','');
  period{i}=strrep(period{i},'Krs','Koros');
 %period(i)=strrep(period(i),'_E','');
  period{i}=strrep(period{i},'_East','');
  period{i}=strrep(period{i},'_West','');
  period{i}=strrep(period{i},'_North','');
  period{i}=strrep(period{i},'Western','');
  period{i}=strrep(period{i},'Struma','');
  period{i}=strrep(period{i},'Stichbandkeramik','SBK');
  period{i}=strrep(period{i},'AceramicNeolithic','Aceramic');
  period{i}=strrep(period{i},'/SBK','');
  period{i}=strrep(period{i},'StGerm','');
  period{i}=strrep(period{i},'group','');
  period{i}=strrep(period{i},'Group','');
  period{i}=strrep(period{i},'StGe','');
  period{i}=strrep(period{i},'EPPNB','PPNB');
  period{i}=strrep(period{i},'LPPNB','PPNB');
  period{i}=strrep(period{i},'MPPNB','PPNB');
  period{i}=strrep(period{i},'Körös','Koros');
  period{i}=strrep(period{i},'PPNC','PPN');
  period{i}=strrep(period{i},'EarlyL','L');
  period{i}=strrep(period{i},'Early/Middle','');
  period{i}=strrep(period{i},'EarlyC','C');
  period{i}=strrep(period{i},'EarlyR','R');
  period{i}=strrep(period{i},'EarlyV','V');
  period{i}=strrep(period{i},'EarlypaintedWare','PaintedWare');
 period{i}=strrep(period{i},'postCardial','Cardial');
 period{i}=strrep(period{i},'PeriCardial','Cardial');
 period{i}=strrep(period{i},'PeriEpiCardial','EpiCardial');
 period{i}=strrep(period{i},'postEpicardial','EpiCardial');
 period{i}=strrep(period{i},'MiddleCardial','Cardial');
 period{i}=strrep(period{i},'MiddleCardial/Impres','Cardial');
 period{i}=strrep(period{i},'KaranovoI','Karanovo');
 period{i}=strrep(period{i},'PotteryNeolithic','Neolithic');
 period{i}=strrep(period{i},'Initial','Early');
 period{i}=strrep(period{i},'Epicardial','EpiCardial');
 period{i}=strrep(period{i},'/Impres','');
 period{i}=strrep(period{i},'LateV','V');



end


culture=unique(period);
nculture=length(culture);
nlegend=0;
clf reset;
m_proj('Mercator','lon',lonlim,'lat',latlim);
m_grid;
m_coast;

cmap=colormap;
imap=0;
cleg=[]

m_line(lon,lat,'LineStyle','none','Marker','.','color',[0.8 0.8 0.8]);

for iculture=1:nculture 
  %switch culture(iculture)
  %  case   ['PPNB','EPPNP','PPN','PPNA'] continue; 
  % end
  switch(lower(culture{iculture}(1:3)))
    case 'neo'
    case 'trb'
    case 'sta'
    case 'lbk'
 % otherwise continue
  end
  
  isite=strmatch(culture(iculture),period);
  nsite=length(isite);
  if isempty(isite) continue; end
  
  fprintf('%s: %d sites\n',culture{iculture},length(isite));
  
  col=cmap(iculture,:);
  
  imap=imap+1;
  m_line(lon(isite),lat(isite),'LineStyle','none','Marker','.','MarkerEdgeColor',col);
  if (nsite>9) 
    nlegend=nlegend+1;
    text(-0.58,0.2+nlegend*0.05,culture{iculture},'Color',col);
  
  end

end
