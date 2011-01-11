function cl_nc_combine_arve_glues

file='../../data/Pop_estimates.nc';
ncid=netcdf.open(file,'NOWRITE');
varid=netcdf.inqVarID(ncid,'time');
time=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'regname');
[varname,xtype,dimids,natts] = netcdf.inqVar(ncid,varid)
%regname=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'regnum');
regnum=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'population');
best=netcdf.getVar(ncid,varid);
netcdf.close(ncid);
ncid=netcdf.open('../../data/Lower_bound_pop_data.nc','NOWRITE');
varid=netcdf.inqVarID(ncid,'population');
lower=netcdf.getVar(ncid,varid);
netcdf.close(ncid);
ncid=netcdf.open('../../data/Upper_bound_pop_data.nc','NOWRITE');
varid=netcdf.inqVarID(ncid,'population');
upper=netcdf.getVar(ncid,varid);
netcdf.close(ncid);

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
    Tennessee Texas Utah Vermont Virginia Washington West_Virginia Wisconsin Wyoming]

continental_canada=[Alberta British_Columbia Manitoba New_Brunswick Newfoundland Northwest_Territories ...
    Nova_Scotia Ontario Prince_Edward_Island Quebec Saskatchewan Yukon_Territory];
namerica=[continental_usa continental_canada Greenland];

samerica=[Uruguay Northern_South_America Mayan_America Central_Mexico Central_Brazil Argentina_lowland ...
Caribbean North_coast_Brazil Aridoamerica Central_America Central_coast_Brazil NE_Brazil South_coast_Brazil Andes ...
Paraguay Amazon];

% Europe: Azores missing
europe=[Albania Austria Belgium_Luxembourg Bulgaria Canaries Czechoslovakia Denmark East_Prussia ...
    England_Wales Finland France Germany Greece Hungary Iceland Ireland Italy Madeira Malta Netherlands Norway ...
    Poland Portugal Romania Scotland Spain Sweden Switzerland Turkey_in_Europe Yugoslavia];

fsu=[204:212 214:217 Russian_Turkestan Ciscaucasia USSR_Central USSR_West Transcaucasia];

swasia=[Afghanistan Cyprus Iran Iraq Oman Palestine_Jordan Persian_Gulf Saudi_Arabia Syria_Lebanon ...
    Turkey_in_Asia Yemen];


nafrica=[Morocco Algeria Tunisia Libya  Egypt Cape_Verde];
%Subsaharan Africa: Seychelles missing,  Atlantic_Islands?
safrica=[Comoros,Equatoria_Zaire_Angola Ethiopia Kenya Madagascar Mauritius Mozambique Reunion ...
    Rwanda_Burundi Sahel_States  Somalia Southern_Africa South_Central_Africa Sudan SW_Africa_Botswana ...
    Tanzania Uganda West_Africa Sao_Tome_Principe];

india=[Pakistan_India_Bangladesh Nepal Bhutan];

china=[292:317 Mongolia Taiwan ];
japan=[Japan];
seasia=[Vietnam Thailand Sri_Lanka Philippines Malaysia_Singapore Laos Korea Indonesia Cambodia Burma];
oceania=[Australia Melanesia New_Zealand Polynesia];
world=[namerica samerica europe fsu swasia nafrica safrica india china japan seasia oceania];

% Manually read from previous plots by Kristen
arvedata(1,:)=[0.3 3 2.5];
arvedata(2,:)=[3 21 14];
arvedata(3,:)=[12.5 14 12.5];
arvedata(4,:)=[2 9.4 2];
arvedata(5,:)=[10 32 10];
arvedata(6,:)=[4 9.5 4];
arvedata(7,:)=[4 4 4];
arvedata(8,:)=[17 17 17];
arvedata(9,:)=[10 20 20 ];
arvedata(10,:)=[0.01 1 0.01];
arvedata(11,:)=[2.2 2.2 2.2];
arvedata(12,:)=[0.6 0.8 0.6];
arvedata(13,:)=sum(arvedata(1:12,:),1);



%% World population
% Put data into context with published estimates
% from http://www.census.gov/ipc/www/worldhis.html
% and convert to logscale.  
%

figure(1); clf reset;
hold on;

h=[-10000 1 10; -8000 5 10; -6500 5 10 ; -5000 5 20; ...
    -4000 7 NaN; -3000 14  NaN ; -2000 27 NaN ; -1000 50 NaN; ...
    -500 100 NaN; -400 162 NaN ; -200 150 231 ; 0 170 400;];
p=polyfit(h([4,10],1),log(h([4,11],3)),1);
inan=find(isnan(h(:,3)));
h(inan,3)=exp(p(1).*h(inan,1)+p(2));

%set(gca,'YScale','log');
patch([h(:,1);flipud(h(:,1))],[h(:,2);flipud(h(:,3))],'y','edgecolor','none');

plot(time,sum(lower,1),'k-','Linewidth',3);
plot(time,sum(best,1),'r-','Linewidth',3);
plot(time,sum(upper,1),'k-','Linewidth',2);
% Spot estimates form earthportal, Jackson, and Haub
plot([-8000 -500 -10000 -0 400 -8000 -0],[1 100 0.1 2.5 500 5 300],'m.');

plot(repmat(-1000,1,3),arvedata(13,:),'rd','linestyle','-','linewidth',3);

set(gca,'Xlim',[-8000,1000]);
set(gca,'Ylim',[0 600]);
xlabel('Time (year AD)');
ylabel('Population size (1E6)'); 
legend('census.gov','lower','KK10','upper','spot estimates','Kristen','location','northwest');
title('Global population');

%% Super region level


c='rgbcmkrgbcmkr';
ls='------::::::-';
sregions={'NAM','SAM','EUR','FSU','SW Asia','N Afr','Subsah Afr','India',...
    'China','Japan','SE Asia','Oceania'};

isnamerica=[];
issamerica=[];
iseurope=[];
isfsu=[];
isswasia=[];
isnafrica=[];
issafrica=[];
isindia=[];
ischina=[];
isjapan=[];
isseasia=[];
isoceania=[];


for i=namerica isnamerica=[isnamerica find(regnum==i)]; end
for i=samerica issamerica=[issamerica find(regnum==i)]; end
for i=europe iseurope=[iseurope find(regnum==i)]; end
for i=fsu isfsu=[isfsu find(regnum==i)]; end
for i=swasia isswasia=[isswasia find(regnum==i)]; end
for i=nafrica isnafrica=[isnafrica find(regnum==i)]; end
for i=safrica issafrica=[issafrica find(regnum==i)]; end
for i=india isindia=[isindia find(regnum==i)]; end
for i=china ischina=[ischina find(regnum==i)]; end
for i=japan isjapan=[isjapan find(regnum==i)]; end
for i=seasia isseasia=[isseasia find(regnum==i)]; end
for i=oceania isoceania=[isoceania find(regnum==i)]; end
 


for i=4:12 
  figure(i+1); clf reset; hold on;
  switch (i)
      case 1,idx=isnamerica;
      case 2,idx=issamerica;
      case 3,idx=iseurope;
      case 4,idx=isfsu;
      case 5,idx=isswasia;
      case 6,idx=isnafrica;
      case 7,idx=issafrica;
      case 8,idx=isindia;
      case 9,idx=ischina;
      case 10,idx=isjapan;
      case 11,idx=isseasia;
      case 12,idx=isoceania;      
  end
  
  plot(time,sum(best(idx,:),1),'r-');
  plot(time,sum(lower(idx,:),1),'r-');
  plot(time,sum(upper(idx,:),1),'r-');
  plot(repmat(-1000,1,3),arvedata(i,:),'rd','linestyle','-','linewidth',3);

  set(gca,'XLim',[-1200,1900],'YScale','linear');
  set(gca,'YLim',[0,max(sum(upper(idx,:),1))]);
  title(sregions{i});
  %xlabel('Time (year AD)');
  %ylabel('Population size (1E6)'); 
end



% From wikipedia 
%Surface area	510,072,000 km2[9][10][note 5]
%148,940,000 km2 land (29.2 %)


end