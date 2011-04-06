% Routines for plots for the worldpop paper by Lemmen, Kaplan, Krumhardt

cl_register_function;

%% Read results file
file='lkk11_0.1_20110105.nc';
if ~exist(file,'file') error('File does not exist'); end
ncid=netcdf.open(file,'NC_NOWRITE');

[ndim nvar natt udimid] = netcdf.inq(ncid); 
for varid=0:nvar-1
  [varname,xtype,dimids,natts]=netcdf.inqVar(ncid,varid);
  if strcmp(varname,'time') time=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'population_size_glues') glues=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'population_size_kk10') kk10=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'population_size_kk10lower') kk10l=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'population_size_kk10upper') kk10u=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'population_size_lkk11') lkk11=netcdf.getVar(ncid,varid); end
end
netcdf.close(ncid);

% Read region names
fid=fopen(strrep(file,'.nc','_key.txt'),'r');
contkeys=textscan(fid,'%d %s');
fclose(fid);
for i=1:length(contkeys{1}) contname{i}=contkeys{2}(i); end


% Gather historic estimates
h=[-10000 1 10; -8000 5 10; -6500 5 10 ; -5000 5 20; ...
    -4000 7 NaN; -3000 14  NaN ; -2000 27 NaN ; -1000 50 NaN; ...
    -500 100 NaN; -400 162 NaN ; -200 150 231 ; 1 170 400; ...
    200 190 256 ; 400 190 206; 500 190 206; 600 200 206;  ...
    700 207 210; 800 220 224; 900 226 240; 900 226 240; ...
    1000 254 345 ; 1100 301 320; 1200 360 450; 1250 400 416; ...
    1300 360 432; 1340 443 NaN; 1400 350 374; 1500 425 540; ...
    1600 545 479; 1650 470 545; 1700 600 679; 1750 629 961; ...
    ];
p=polyfit(h([4,10],1),log(h([4,11],3)),1);
inan=find(isnan(h(:,3)));
h(inan,3)=exp(p(1).*h(inan,1)+p(2));

kl=load('../../data/lower_bound.dat','-ascii');
ku=load('../../data/upper_bound.dat','-ascii');
km=load('../../data/Global_pop_8k.dat','-ascii');
hl=load('../../data/low_bound_hyde.dat','-ascii');
hm=load('../../data/hyde_world_pop_2.dat','-ascii');
hu=load('../../data/up_bound_hyde.dat','-ascii');



%% Create maps of regions (9 colors) and add bar at appropriate position
% From Kristen's population paper super regions
file='../../data/pop_region_key2.txt';
fid=fopen(file,'r');
keys=textscan(fid,'%d %s');
fclose(fid);
for i=1:length(keys{1})
  eval([strrep(char(keys{2}(i)),'-','_') ' = ' sprintf('int32(%d)',keys{1}(i)) ';']);
end
% Now group these
continental_usa=[Alabama Alaska Arizona Arkansas California Colorado Connecticut Delaware Washington_DC Florida ...
    Georgia Idaho Illinois Indiana Iowa Kansas Kentucky Louisiana Maine Maryland Massachusetts Michigan ...
    Minnesota  Mississippi Missouri Montana Nebraska Nevada New_Hampshire New_Jersey New_Mexico New_York ...
    North_Carolina North_Dakota Ohio Oklahoma Oregon Pennsylvania Rhode_Island South_Carolina South_Dakota ...
    Tennessee Texas Utah Vermont Virginia Washington West_Virginia Wisconsin Wyoming];

continental_canada=[Alberta British_Columbia Manitoba New_Brunswick Newfoundland Northwest_Territories ...
    Nova_Scotia Ontario Prince_Edward_Island Quebec Saskatchewan Yukon_Territory];
NAM=[continental_usa continental_canada Greenland];

SAM=[Uruguay Northern_South_America Mayan_America Central_Mexico Central_Brazil Argentina_lowland ...
Caribbean North_coast_Brazil Aridoamerica Central_America Central_coast_Brazil NE_Brazil South_coast_Brazil Andes ...
Paraguay Amazon];

% Europe: Azores missing
Europe=[Albania Austria Belgium_Luxembourg Bulgaria Canaries Czechoslovakia Denmark East_Prussia ...
    England_Wales Finland France Germany Greece Hungary Iceland Ireland Italy Madeira Malta Netherlands Norway ...
    Poland Portugal Romania Scotland Spain Sweden Switzerland Turkey_in_Europe Yugoslavia];

FSU=[204:212 214:217 Russian_Turkestan Ciscaucasia USSR_Central USSR_West Transcaucasia];

SW_Asia=[Afghanistan Cyprus Iran Iraq Oman Palestine_Jordan Persian_Gulf Saudi_Arabia Syria_Lebanon ...
    Turkey_in_Asia Yemen];


N_Afr=[Morocco Algeria Tunisia Libya  Egypt Cape_Verde];
%Subsaharan Africa: Seychelles missing,  Atlantic_Islands?
Subsah_Afr=[Comoros,Equatoria_Zaire_Angola Ethiopia Kenya Madagascar Mauritius Mozambique Reunion ...
    Rwanda_Burundi Sahel_States  Somalia Southern_Africa South_Central_Africa Sudan SW_Africa_Botswana ...
    Tanzania Uganda West_Africa Sao_Tome_Principe];

India=[Pakistan_India_Bangladesh Nepal Bhutan];

China=[292:317 Mongolia Taiwan ];
Japan=[Japan];
SE_Asia=[Vietnam Thailand Sri_Lanka Philippines Malaysia_Singapore Laos Korea Indonesia Cambodia Burma];
Oceania=[Australia Melanesia New_Zealand Polynesia];

% file='../../data/popregions6.nc';
% ncid=netcdf.open(file,'NOWRITE');
% varid=netcdf.inqVarID(ncid,'z');
% regnum=netcdf.getVar(ncid,varid);
% lat=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'lat'));
% lon=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'lon'));
% netcdf.close(ncid);

rcol=jet(9);
gray=repmat(0.5,1,3);
fs=14;

%     NAM  SAM EUR FSU SWA NAf SAf IND CHI JAP SEA OCE
rlat=[30   -30 45  60   30  15 -30   5  15  35   5 -30]';
rlon=[-100 -60 0   60   40  10  25  80 110 135 110 165]';

[rx,ry]=m_ll2xy(rlon,rlat);

rtime=[-8000 -6000 -4000 -2000 -1000 0 1000 1490 1500 1750];
ntime=length(rtime);
for it=1:ntime itime(it)=find(time==rtime(it)); end

hmin=min(min(lkk11(:,itime)));
hmax=max(max(lkk11(:,itime)));


for it=1:-ntime
  yearstring=rtime(it);
  if yearstring==0 yearstring=yearstring+1; end
  if yearstring > 0 yearstring=sprintf('%4d AD',yearstring); else
    yearstring=sprintf('%4d BC',abs(yearstring)); 
  end
    
  figure(it); clf reset; hold on;
  m_proj('equidistant','lat',[-60 80],'lon',[-180 180]);
  m_coast('patch',gray);
  m_grid('box','fancy','linestyle','none');
  
  height=lkk11(:,itime(it))/hmax;
    m_text(-170,-50,yearstring,'fontsize',16,'fontweight','bold');

   clp_bar(rx,ry,height,'width',0.2,'barcolor','b');
  cl_print('name',['worldpop_' strrep(yearstring,' ','_')],'ext','png','res',300);
  %   rindex=eval([char(contname{ireg}) ';']);
%   for ri=1:length(rindex) ifound=[ifound; find(regnum==rindex(ri))];
%   end
%   [i,j]=ind2sub(size(regnum),ifound);  
%   p(ireg)=m_plot(lon(i),lat(j),'k'); 
%   set(p(ireg),'color',rcol(ireg,:),'linestyle','none','MarkerSize',0.5);
end


figure(1); clf reset; hold on;


censcol=[0.95 0.67 0.95];
hydecol=[0.95 0.95 0.67];
kk10col=[0.67 0.95 0.95];

phyde=patch([hl(:,1);flipud(hu(:,1))],[hl(:,2);flipud(hu(:,2))],hydecol,'edgecolor','none','visible','on');
%alpha(phyde,0.5);

pcensus=patch([h(:,1);flipud(h(:,1))],[h(:,2);flipud(h(:,3))],censcol,'edgecolor','none','visible','on');
%alpha(pcensus,0.5);

phydemean=plot(hm(:,1),hm(:,2),'g-','Linewidth',5,'Color',hydecol,'visible','off');

xlabel('Time (Year AD)','FontSize',fs);
ylabel('Population size (million)','FontSize',fs);
set(gca,'XLim',[-8000,1750],'FontSize',fs);
set(gca,'XLim',[-8000,1750],'YLim',[0,1000]);
set(gca,'color','none','xcolor',gray,'ycolor',gray);

p2k=plot(kl(:,1),kl(:,2),'r-.');
p3k=plot(km(:,1),km(:,2),'r-','Linewidth',5);
p4k=plot(ku(:,1),ku(:,2),'r-.');

i0=find(time==0);
p5=plot(time(1:i0),sum(glues(:,1:i0),1),'b-','LineWidth',5)

%skk=sum(kk10,1); sg=sum(glues,1);
%factor=skk(i0+1)./sg(i0+1);
%p6=plot(time(1:i0),sum(glues(:,1:i0),1)*factor,'b--','LineWidth',5)

p7=plot(time,sum(lkk11,1),'k-','LineWidth',5)
l=legend([phyde,pcensus,p3k,p5,p7],'Hyde','Census Bureau','KK10','GLUES','LKK11');
set(l,'Location','Northwest','color','w','FontSize',16);

cl_print('name','worldpop_global','ext','png','res',300);



for ireg=1:12 %[1 2 3]
figure(ireg); clf reset;
    
pkk10=patch([time;flipud(time)]',[kk10l(ireg,:) fliplr(kk10u(ireg,:))],'r','facecolor','r','edgecolor','r','visible','on');
hold on;

p7=plot(time,lkk11(ireg,:),'k-','LineWidth',4);
p8=plot(time(1:i0),glues(ireg,1:i0),'b-','LineWidth',5);

xlabel('Time (Year AD)','FontSize',fs);
ylabel('Population size (million)','FontSize',fs);
set(gca,'XLim',[-8000,1750],'FontSize',fs);
set(gca,'XLim',[-8000,1750]);
set(gca,'color','none','xcolor',gray,'ycolor',gray);
l=legend([p8,pkk10,p7],'GLUES','KK10','LKK11');
set(l,'Location','Northwest','color','w','FontSize',16);
title(contname{ireg},'FontSize',24,'FontWeight','bold');
cl_print('name',['worldpop_' char(contname{ireg})],'ext','png','res',300);

end

