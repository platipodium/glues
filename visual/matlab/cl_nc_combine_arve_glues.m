function cl_nc_combine_arve_glues(varargin)
% This function takes glues results for glues regions, maps them to a 
% half-degree grid and aggregates over the ARVE population regions.

arguments = {...
  {'timelim',[-6000,2000]},...
  {'file','arveaggregate_eurolbk_events.mat'},...
};

cl_register_function;

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length 
  eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); 
end

glues=load(file);

file='../../data/Pop_estimates.nc';
ncid=netcdf.open(file,'NOWRITE');
varid=netcdf.inqVarID(ncid,'time');
time=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'regname');
regname=netcdf.getVar(ncid,varid);
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


%% GLUES and KK10 in contrast 
% This is a new GLUES simulation with corrected area (now computed from
% within GLUES, version is 1.1.16).  Uncertainty due to the different grid
% resolution and partial inclusion/exclusion of water areas in the coarser
% GLUES grid is less than 5% now.
%
% I've simulated until 1000 AD to have an overlap.  I interpolated the
% GLUES data on the ARVE grid and then onto the ARVE countries.  This is the same simulation as the
% one I use in my validation paper, but with added climate fluctuations.
%
% One can clearly see
% that GLUES does not capture the innovations which lead to population
% increase after 1000 BC in advanced regions. Don't
% believe GLUES for iron age societies! 
%
% There seems to be a small error in the calculation of the lower boundary
% in the ARVE data (ask Kristen, in Subsaharan part)
%
figure(1); clf reset;
hold on;

plot(time,sum(lower,1),'r--','LineWidth',1);
plot(time,sum(best,1),'r-','LineWidth',2);
plot(time,sum(upper,1),'r--','LineWidth',1);

glues.value=glues.arvedensity;
ntime=size(glues.value,2);
area=repmat(glues.garea',1,ntime);

plot(glues.time,sum(area.*glues.value/1E6,1),'b-','LineWidth',2);
legend('KK10 lower','KK10','KK10 upper','GLUES','location','NorthWest');
xlabel('Time (year AD)');
ylabel('Population size (1E6)'); 

%%

% From Kristen's population paper super regions
file='../../data/pop_region_key2.txt';
fid=fopen(file,'r');
keys=textscan(fid,'%d %s');
fclose(fid);
for i=1:length(keys{1})
  eval([strrep(char(keys{2}(i)),'-','_') ' = ' num2str(keys{1}(i)) ';']);
end



% Now group these
continental_usa=[242:291];
continental_canada=[230:241];
namerica=[continental_usa continental_canada Greenland];

samerica=[Uruguay Northern_South_America Mayan_America Central_Mexico Central_Brazil Argentina_lowland ...
Caribbean North_coast_Brazil Aridoamerica Central_America Central_coast_Brazil NE_Brazil South_coast_Brazil Andes ...
Paraguay Amazon];

% Europe: Azores missing
europe=[Albania Austria Belgium_Luxembourg Bulgaria Canaries Czechoslovakia Denmark East_Prussia ...
    England_Wales Finland France Germany Greece Hungary Iceland Ireland Italy Madeira Malta Netherlands Norway ...
    Poland Portugal Romania Scotland Spain Sweden Switzerland Turkey_in_Europe Yugoslavia];

% FSU west of Ural
fsu_west=[USSR_Byelarus USSR_Moldova USSR_Donetsk_Dnepr USSR_South USSR_Southwest USSR_Northwest ...
    USSR_Volgo_Viatsk USSR_Volga USSR_Ural USSR_West USSR_Central  Ciscaucasia Transcaucasia];

fsu_east= [USSR_Central_Chernozem USSR_West_Siberia USSR_East_Siberia USSR_Far_East ...
    Russian_Turkestan];

fsu=[fsu_west fsu_east];

% Europe + fsu west of Ural europe=[europe fsu_west];

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

nar=max(glues.index);
for i=1:nar
  ia=find(glues.index==i);
  if ~isempty(ia) 
      aindex(i)=ia; 
  else aindex(i)=NaN; 
  end
end

area=glues.garea;

% calculate total area of superreigions
ar(1)=sum(area(aindex(namerica)));
ar(2)=sum(area(aindex(samerica)));
ar(3)=sum(area(aindex(europe)));
ar(4)=sum(area(aindex(fsu)));
ar(5)=sum(area(aindex(swasia)));
ar(6)=sum(area(aindex(nafrica)));
ar(7)=sum(area(aindex(safrica)));
ar(8)=sum(area(aindex(india)));
ar(9)=sum(area(aindex(china)));
ar(10)=sum(area(aindex(japan)));
ar(11)=sum(area(aindex(seasia)));
ar(12)=sum(area(aindex(oceania)));

area=glues.garea;

% Remove countries for which we don't have numbers in GLUES (area=inf)
namerica=namerica(isfinite(area(aindex(namerica))));
samerica=samerica(isfinite(area(aindex(samerica))));
europe=europe(isfinite(area(aindex(europe))));
fsu=fsu(isfinite(area(aindex(fsu))));
swasia=swasia(isfinite(area(aindex(swasia))));
nafrica=nafrica(isfinite(area(aindex(nafrica))));
safrica=safrica(isfinite(area(aindex(safrica))));
india=india(isfinite(area(aindex(india))));
china=china(isfinite(area(aindex(china))));
japan=japan(isfinite(area(aindex(japan))));
seasia=seasia(isfinite(area(aindex(seasia))));
oceania=oceania(isfinite(area(aindex(oceania))));

arc(1)=sum(area(aindex(namerica)));
arc(2)=sum(area(aindex(samerica)));
arc(3)=sum(area(aindex(europe)));
arc(4)=sum(area(aindex(fsu)));
arc(5)=sum(area(aindex(swasia)));
arc(6)=sum(area(aindex(nafrica)));
arc(7)=sum(area(aindex(safrica)));
arc(8)=sum(area(aindex(india)));
arc(9)=sum(area(aindex(china)));
arc(10)=sum(area(aindex(japan)));
arc(11)=sum(area(aindex(seasia)));
arc(12)=sum(area(aindex(oceania)));
arc(13)=sum(arc(1:12));
arc(:)=1;
ar(:)=1;


glues.value=glues.arvedensity;
ntime=size(glues.value,2);
area=repmat(glues.garea',1,ntime);

s(1,:)=sum(area(aindex(namerica),:).*glues.value(aindex(namerica),:)).*ar(1)./arc(1);
s(2,:)=sum(area(aindex(samerica),:).*glues.value(aindex(samerica),:)).*ar(2)./arc(2);
s(3,:)=sum(area(aindex(europe),:).*glues.value(aindex(europe),:)).*ar(3)./arc(3);
s(4,:)=sum(area(aindex(fsu),:).*glues.value(aindex(fsu),:)).*ar(4)./arc(4);
s(5,:)=sum(area(aindex(swasia),:).*glues.value(aindex(swasia),:)).*ar(5)./arc(5);
s(6,:)=sum(area(aindex(nafrica),:).*glues.value(aindex(nafrica),:)).*ar(6)./arc(6);
s(7,:)=sum(area(aindex(safrica),:).*glues.value(aindex(safrica),:)).*ar(7)./arc(7);
s(8,:)=sum(area(aindex(india),:).*glues.value(aindex(india),:)).*ar(8)./arc(8);
s(9,:)=sum(area(aindex(china),:).*glues.value(aindex(china),:)).*ar(9)./arc(9);
s(10,:)=(area(aindex(japan),:).*glues.value(aindex(japan),:)).*ar(10)./arc(10);
s(11,:)=sum(area(aindex(seasia),:).*glues.value(aindex(seasia),:)).*ar(11)./arc(11);
s(12,:)=sum(area(aindex(oceania),:).*glues.value(aindex(oceania),:)).*ar(12)./arc(12);
s(13,:)=sum(s(1:12,:),1);
s=s/1E6;



%% Context with published estimates
% At http://www.census.gov/ipc/www/worldhis.html different data on global
% population are given which are here added to the GLUES and KK10
% estimates. Also, the figure is converted to log scale
%
% GLUES shows a more rapid population rise than the collected data 
% around 5000-4000 BC, the period
% of the European Neolithic.  In our validation paper, however, we show
% that this period is realistically simulated in GLUES.
%
% Note the equilibration of Mesolithic population in GLUES near the
% upper boundary of the historic estimates around 9k.  

figure(2); clf reset; hold on;

h=[-10000 1 10; -8000 5 10; -6500 5 10 ; -5000 5 20; ...
    -4000 7 NaN; -3000 14  NaN ; -2000 27 NaN ; -1000 50 NaN; ...
    -500 100 NaN; -400 162 NaN ; -200 150 231 ; 0 170 400;];
p=polyfit(h([4,10],1),log(h([4,11],3)),1);
inan=find(isnan(h(:,3)));
h(inan,3)=exp(p(1).*h(inan,1)+p(2));

set(gca,'YScale','log');
patch([h(:,1);flipud(h(:,1))],[h(:,2);flipud(h(:,3))],'y','edgecolor','none');

plot(time,sum(lower,1),'r--','Linewidth',1);
plot(time,sum(best,1),'r-','Linewidth',2);
plot(time,sum(upper,1),'r--','Linewidth',1);
plot(glues.time,s(13,:),'b-','Linewidth',2);

set(gca,'Xlim',[min(glues.time),1000]);
set(gca,'Ylim',[1 1000]);
xlabel('Time (year AD)');
ylabel('Population size (1E6)'); 
legend('census.gov','lower','KK10','upper','GLUES','location','northwest');
title('Global population');

%% Supra regional level
% The GLUES data in ARVE regions were summed according to the procedure
% outlined in Kristen's report.  below, these cumulated supraregional
% estimates are shown to contrast the simulation and the KK10 data with
% lower and upper bounds. 

figure(3); clf reset;

c='rgbcmkrgbcmkr';
ls='------::::::-';
sregions={'NAM','SAM','Europe','FSU','SW Asia','N Afr','Subsah Afr','India',...
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


for i=1:12 
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
  kk10(i,:)=sum(best(idx,:),1);
  kk10upper(i,:)=sum(upper(idx,:),1);
  kk10lower(i,:)=sum(lower(idx,:),1);
end
  
itime=find(time>=timelim(1) & time<=timelim(2));

for i=1:12 
  %figure(i+2); clf reset; hold on;
  subplot(4,3,i)
  plot(glues.time,s(i,:),'b-','LineWidth',3); hold on;
  
  plot(time(itime),kk10(i,itime),'r-','LineWidth',3);
  plot(time(itime),kk10lower(i,itime),'r--');
  plot(time(itime),kk10upper(i,itime),'r--');
  set(gca,'XLim',[-6500,1900],'YLim',[0 ceil(max(kk10upper(i,itime)/10))*10],'YScale','linear');
  title(sregions{i});
  %xlabel('Time (year AD)');
  %ylabel('Population size (1E6)'); 
end
orient('landscape');



%% Individual continents: North America
% The historic estimates vary greatly.  the GLUES simulation is close to
% the maximum estimate by Kristen. Between -1000 and 1000 AD, both GLUES
% and KK10 are parallel with a difference of 2 million people.
%
% (1) trust GLUES before 0 AD
% (2) trust KK10 after 1500 minimum
% (3) increase KK10 max before 1500 by 2 million
% (4) interpolate between 0 and <1500 maximum
% (5) interpolate between <1500 max and >1500 min
f=4; i=1;
figure(f+0); clf reset;
plot(glues.time,s(i,:),'b-','LineWidth',2); hold on;
plot(time(itime),kk10(i,itime),'r-','LineWidth',2);
plot(time(itime),kk10lower(i,itime),'r--');
plot(time(itime),kk10upper(i,itime),'r--');
set(gca,'XLim',[-6500,1900],'YLim',[0 ceil(max(kk10upper(i,itime)/10))*10],'YScale','linear');
title(sregions{i});
xlabel('Time (year AD)');
ylabel('Population size (1E6)'); 

[a1 i1]=max(kk10(i,find(time<1500)));
[a2 i2]=min(kk10(i,find(time>1500)));
i2=i2+min(find(time>1500));
i0=find(time==0);

kk=kk10(i,:);
kk(i0:i2)=kk(i0:i2)+2;

ntime=min(glues.time):1:max(time);

l1=find(ntime==time(i1));
l2=find(ntime==time(i2));
l0=find(ntime==time(i0));

% Assing GLUES to whole new time series
lkk(i,:)=spline(glues.time,s(1,:),ntime);
% Assign KK10 from minimum
lkk(i,l2:end)=kk10(i,i2:end);
% Assign linear weighting between 0 and 1500 betwwen GLUES and KK10+2 mill
w=[0:l1-l0];
w=w./max(w);
lkk(i,l0:l1)=lkk(i,l0:l1).*(1-w)+kk(i0:i1).*w;


p=plot(ntime,lkk(i,:),'k--','LineWidth',2);
legend('GLUES','KK10','LKK11');


%% South America
% Data for South america is not well constrained, and the GLUES simulation
% ends in the lower interval of historic estimates. 
% The estimates in the data are on the high side, thus we proceed analogous
% to NAM, but with a reduction before 1500 of the KK10 scenario by 10
% million
%
% 1) trust GLUES before -1000 AD
% 2) trust KK10 after 1500 minimum
% 3) decrease KK10 max before 1500 by 10 million
% 4) interpolate between 0 and <1500 maximum
% 5) interpolate between <1500 max and >1500 min

figure(f+1); clf reset;
i=2;
plot(glues.time,s(i,:),'b-','LineWidth',2); hold on;
plot(time(itime),kk10(i,itime),'r-','LineWidth',2);
plot(time(itime),kk10lower(i,itime),'r--');
plot(time(itime),kk10upper(i,itime),'r--');
set(gca,'XLim',[-6500,1900],'YLim',[0 ceil(max(kk10upper(i,itime)/10))*10],'YScale','linear');
title(sregions{i});
xlabel('Time (year AD)');
ylabel('Population size (1E6)'); 


[a1 i1]=max(kk10(i,find(time<1500)));
[a2 i2]=min(kk10(i,find(time>1500)));
i2=i2+min(find(time>1500));
l1=find(ntime==time(i1));
l2=find(ntime==time(i2));

kk=kk10(i,:);
kk(i0:i1)=kk(i0:i1)-10;

% Assing GLUES to whole new time series
lkk(i,:)=spline(glues.time,s(i,:),ntime);
% Assign KK10 from minimum
lkk(i,l2:end)=kk10(i,i2:end);
% Assign linear weighting between 0 and 1500 betwwen GLUES and KK10-10 mill
w=[0:l1-l0];
w=w./max(w);
lkk(i,l0:l1)=lkk(i,l0:l1).*(1-w)+kk(i0:i1).*w;

w=[0:i2-i1]; w=w./max(w);
%lkk(i,l1:l2)=kk(i1:i2).*(1-w)+kk10(i1:i2).*w;


p=plot(ntime,lkk(i,:),'k--','LineWidth',3);
legend('GLUES','KK10','LKK11');

%% Europe
% For Europe, trust the data (which have low uncertainty, only adust the
% data between -1000 and -1500 in a gradual transition, assume data constant
% before -1000

figure(f+2); clf reset;
i=3;
plot(glues.time,s(i,:),'b-','LineWidth',2); hold on;
plot(time(itime),kk10(i,itime),'r-','LineWidth',2);
plot(time(itime),kk10lower(i,itime),'r--');
plot(time(itime),kk10upper(i,itime),'r--');
set(gca,'XLim',[-6500,1900],'YLim',[0 ceil(max(kk10upper(i,itime)/10))*10],'YScale','linear');
title(sregions{i});
xlabel('Time (year AD)');
ylabel('Population size (1E6)'); 

i1=find(time==-1000);
l1=find(ntime==time(i1));
l2=find(ntime==-1500);

% Assing GLUES to whole new time series
lkk(i,:)=spline(glues.time,s(i,:),ntime);
% Assign KK10 from minimum
lkk(i,l1:end)=kk10(i,i1:end);
% Assign linear weighting between 0-1500 and -1000 betwwen GLUES and KK10
w=[0:l1-l2];
w=w./max(w);
lkk(i,l2:l1)=lkk(i,l2:l1).*(1-w)+kk10(i,i1).*w;

p=plot(ntime,lkk(i,:),'k--','LineWidth',3);
legend('GLUES','KK10','LKK11');

%% FSU
% There is large gap betwwen simulated and historical data.  At the same
% time, the historical data is not well constrained.  Interestingly, both
% simulateted and (upper) historical data show a similar decline at 700 AD
% and both lines run in parallel from -100 to 1000
% 
% 1) Trust upper data estimates from -1000
% 2) gradually interpolate GLUES between -4000 and -1000 to this data

figure(f+3); clf reset;
i=4;
p1=plot(glues.time,s(i,:),'b-','LineWidth',2); hold on;
p2=plot(time(itime),kk10(i,itime),'r-','LineWidth',2);
plot(time(itime),kk10lower(i,itime),'r--');
plot(time(itime),kk10upper(i,itime),'r--');
set(gca,'XLim',[-6500,1900],'YLim',[0 ceil(max(kk10upper(i,itime)/10))*10],'YScale','linear');
title(sregions{i});
xlabel('Time (year AD)');
ylabel('Population size (1E6)'); 


i1=find(time==-1000);
l1=find(ntime==time(i1));
l2=find(ntime==-1500);
i3=find(time==1300);
l3=find(ntime==time(i3));
l4=find(ntime==-6000);
i5=find(time==700);
l5=find(ntime==time(i5));

% Assing GLUES to whole new time series
lkk(i,:)=spline(glues.time,s(i,:),ntime);
% Assign KK10 from minimum
lkk(i,l3:end)=kk10(i,i3:end);
% Assign linear weighting between -400 and -1000 betwwen GLUES and KK10
% upper
w=[0:l1-l4];
w=w./max(w);
lkk(i,l4:l1)=lkk(i,l4:l1).*(1-w)+kk10upper(i,i1).*w;
lkk(i,l1:l5)=kk10upper(i,i1:i5);

w=[0:l3-l5]; w=w./max(w);
lkk(i,l5:l3)=kk10upper(i,i5:i3).*(1-w)+kk10(i,i5:i3).*w;

p3=plot(ntime,lkk(i,:),'k--','LineWidth',3);
legend([p1,p2,p3],'GLUES','KK10','LKK11');

%% SW Asia
% Data are very uncertain, the KK10 on the lower side of values and GLUES
% falling inbetween KK10 and upper estimate.  
% The higher historic estimate takes into account the Mesopotamian
% civilzations, if we want to account for this, we should correct the
% historic data towards the upper boundary before 1000 AD
%
% 1) move KK10 up half the distance to upper estimate before AD700
% 2) gradually adjust from GLUES to KK10 coorected before AD0


figure(f+4); clf reset;
i=5;
p1=plot(glues.time,s(i,:),'b-','LineWidth',2); hold on;
p2=plot(time(itime),kk10(i,itime),'r-','LineWidth',2);
plot(time(itime),kk10lower(i,itime),'r--');
plot(time(itime),kk10upper(i,itime),'r--');
set(gca,'XLim',[-6500,1900],'YLim',[0 ceil(max(kk10upper(i,itime)/10))*10],'YScale','linear');
title(sregions{i});
xlabel('Time (year AD)');
ylabel('Population size (1E6)'); 


i1=find(time==-1000);
l1=find(ntime==time(i1));
i5=find(time==700);
l5=find(ntime==time(i5));


% Assing GLUES to whole new time series
lkk(i,:)=spline(glues.time,s(i,:),ntime);
% Assign KK10 from AD700
lkk(i,l0:end)=kk10(i,i0:end);
% Assign linear weighting between -1000 and -700 betwwen KK10 and upper
w=[0:i5-i1];
w=w./max(w);
kk=kk10(i,:);
kk(i1:i5)=kk10(i,i1:i5)+0.5*(kk10upper(i,i1:i5)-kk10(i,i1:i5)).*(1-w);

lkk(i,l0:l5)=kk(i0:i5);


w=[0:l0-l1]; w=w./max(w);
lkk(i,l1:l0)=lkk(i,l1:l0).*(1-w)+kk(i1:i0).*w;

p3=plot(ntime,lkk(i,:),'k--','LineWidth',3);
legend([p1,p2,p3],'GLUES','KK10','LKK11');



%% North Africa

figure(f+5); clf reset;
i=6;
p1=plot(glues.time,s(i,:),'b-','LineWidth',2); hold on;
p2=plot(time(itime),kk10(i,itime),'r-','LineWidth',2);
plot(time(itime),kk10lower(i,itime),'r--');
plot(time(itime),kk10upper(i,itime),'r--');
set(gca,'XLim',[-6500,1900],'YLim',[0 ceil(max(kk10upper(i,itime)/10))*10],'YScale','linear');
title(sregions{i});
xlabel('Time (year AD)');
ylabel('Population size (1E6)'); 


i1=find(time==-1000);
l1=find(ntime==time(i1));


% Assing GLUES to whole new time series
lkk(i,:)=spline(glues.time,s(i,:),ntime);
% Assign KK10 from AD -1000
lkk(i,l1:end)=kk10(i,i1:end);

p3=plot(ntime,lkk(i,:),'k--','LineWidth',3);
legend([p1,p2,p3],'GLUES','KK10','LKK11');

%% Subsaharan Africa
% The historical estimates have a large uncertainty; GLUES predicts 10 mio
% more between -1000 and -500 than the largest historical estimates.
% This upper historical estimat is just a linear interpolation between -100
% and 1000
%
% 1) Reduce GLUES by 10 mio  at 1000 AD

figure(f+6); clf reset;
i=7;
p1=plot(glues.time,s(i,:),'b-','LineWidth',2); hold on;
p2=plot(time(itime),kk10(i,itime),'r-','LineWidth',2);
plot(time(itime),kk10lower(i,itime),'r--');
plot(time(itime),kk10upper(i,itime),'r--');
set(gca,'XLim',[-6500,1900],'YLim',[0 ceil(max(kk10upper(i,itime)/10))*10],'YScale','linear');
title(sregions{i});
xlabel('Time (year AD)');
ylabel('Population size (1E6)'); 


i1=find(time==1000);
l1=find(ntime==time(i1));
l2=find(ntime==-3000);
i5=find(time==700);
l5=find(ntime==time(i5));
i3=find(time==500);
l3=find(ntime==time(i3));
i4=find(time==-1000);
l4=find(ntime==time(i4));
i6=length(time);

% Assing GLUES to whole new time series
lkk(i,:)=spline(glues.time,s(i,:),ntime);

w=[0:l1-l2]; w=w./max(w);
lkk(i,l2:l1)=lkk(i,l2:l1).*(1-w)+(lkk(i,l2:l1)-10).*w;

w=[0:l3-l4]; w=w./max(w);
lkk(i,l4:l3)=lkk(i,l4:l3).*(1-w)+kk10upper(i,i4:i3).*w;

w=[0:i6-i3]; w=w./max(w);
lkk(i,l3:end)=kk10upper(i,i3:i6).*(1-w)+kk10(i,i3:i6).*w;

p3=plot(ntime,lkk(i,:),'k--','LineWidth',3);
legend([p1,p2,p3],'GLUES','KK10','LKK11');


%% India
% GLUES and KK10 match at -500, so a simple transition (between -1000 and
% 0) should be good
%
% 1) Trust GLUES before -500 AD and KK10 after -500 AD
% 2) Create gradual transition between -1000 and 0 AD

figure(f+7); clf reset;
i=8;
p1=plot(glues.time,s(i,:),'b-','LineWidth',2); hold on;
p2=plot(time(itime),kk10(i,itime),'r-','LineWidth',2);
plot(time(itime),kk10lower(i,itime),'r--');
plot(time(itime),kk10upper(i,itime),'r--');
set(gca,'XLim',[-6500,1900],'YLim',[0 ceil(max(kk10upper(i,itime)/10))*10],'YScale','linear');
title(sregions{i});
xlabel('Time (year AD)');
ylabel('Population size (1E6)'); 


i1=find(time==-1000);
l1=find(ntime==time(i1));

% Assing GLUES to whole new time series,
lkk(i,:)=spline(glues.time,s(i,:),ntime);
lkk(i,l0:end)=kk10(i,i0:end);

w=[0:i0-i1]; w=w./max(w);
lkk(i,l1:l0)=lkk(i,l1:l0).*(1-w)+kk10(i,i1:i0).*w;

p3=plot(ntime,lkk(i,:),'k--','LineWidth',3);
legend([p1,p2,p3],'GLUES','KK10','LKK11');

%% China
% The data on China is rather good, with some uncertainty of factor 2 at
% 1000 BC.  The GLUES data is too high, overall, so should be reduced
% gradually to match the 1000 BC historical estimate
%
% 1) Decrease 500 BC GLUES data by 15 mio (gradually from -6000)
% 2) smoothly adjust between KK10 and GLUES between -1000 and -500

figure(f+8); clf reset;
i=9;
p1=plot(glues.time,s(i,:),'b-','LineWidth',2); hold on;
p2=plot(time(itime),kk10(i,itime),'r-','LineWidth',2);
plot(time(itime),kk10lower(i,itime),'r--');
plot(time(itime),kk10upper(i,itime),'r--');
set(gca,'XLim',[-6500,1900],'YLim',[0 ceil(max(kk10upper(i,itime)/10))*10],'YScale','linear');
title(sregions{i});
xlabel('Time (year AD)');
ylabel('Population size (1E6)'); 

i1=find(time==-500);
l1=find(ntime==time(i1));
l2=find(ntime==-6000);
i3=find(time==-1000);
l3=find(ntime==time(i3));

% Assing GLUES to whole new time series,
lkk(i,:)=spline(glues.time,s(i,:),ntime);
lkk(i,l1:end)=kk10(i,i1:end);

w=[0:l1-l2]; w=w./max(w);
lkk(i,l2:l1)=lkk(i,l2:l1).*(1-w)+(lkk(i,l2:l1)-15).*w;

w=[0:l1-l3]; w=w./max(w);
lkk(i,l3:l1)=lkk(i,l3:l1).*(1-w)+kk10(i,i3:i1).*w;


p3=plot(ntime,lkk(i,:),'k--','LineWidth',3);
legend([p1,p2,p3],'GLUES','KK10','LKK11');

%% Japan
% Data for japan is very low, even the high estimate (of less than 2 mio
% before 0 AD.  GLUES is twice the historical estimate. As for China, GLUES
% should be decreased
%
% 1) Decrease 500 BC GLUES data by 1 mio (gradually from -6000) to match
% KK10upper at 500 BC
% 2) smoothly adjust between KK10 upper and KK10 from -500 to 500


i=10; figure(f+i); clf reset;
p1=plot(glues.time,s(i,:),'b-','LineWidth',2); hold on;
p2=plot(time(itime),kk10(i,itime),'r-','LineWidth',2);
plot(time(itime),kk10lower(i,itime),'r--');
plot(time(itime),kk10upper(i,itime),'r--');
set(gca,'XLim',[-6500,1900],'YLim',[0 ceil(max(kk10upper(i,itime)/10))*10],'YScale','linear');
title(sregions{i});
xlabel('Time (year AD)');
ylabel('Population size (1E6)'); 


i1=find(time==-500);
l1=find(ntime==time(i1));
l2=find(ntime==-6000);
i3=find(time==-1000);
l3=find(ntime==time(i3));
i4=find(time==500);
l4=find(ntime==time(i4));

lkk(i,:)=spline(glues.time,s(i,:),ntime);
lkk(i,l1:end)=kk10(i,i1:end);

w=[0:l1-l2]; w=w./max(w);
lkk(i,l2:l1)=lkk(i,l2:l1).*(1-w)+(lkk(i,l2:l1)-1).*w;

w=[0:l4-l1]; w=w./max(w);
lkk(i,l1:l4)=kk10upper(i,i1:i4).*(1-w)+kk10(i,i1:i4).*w;


p3=plot(ntime,lkk(i,:),'k--','LineWidth',3);
legend([p1,p2,p3],'GLUES','KK10','LKK11');


%% SE Asia
% Data for SE aAsia are highly uncertain before 1000 AD and even later.
% GLUES is twice as high as the highest estimate at 1000 BC and below the
% highest estimate at 1000 AD.
% Accordingly, the procedure should be similar to Japan with a decrease 
% of GLUES  results and then a smooth transition to upper estimate then to
% KK10
%
% 1) Decrease 500 BC GLUES data by 7 mio (gradually from -6000) to match
% KK10upper at 500 BC
% 2) smoothly adjust between KK10 upper and KK10 from -500 to 500

i=11; figure(f+i); clf reset;
p1=plot(glues.time,s(i,:),'b-','LineWidth',2); hold on;
p2=plot(time(itime),kk10(i,itime),'r-','LineWidth',2);
plot(time(itime),kk10lower(i,itime),'r--');
plot(time(itime),kk10upper(i,itime),'r--');
set(gca,'XLim',[-6500,1900],'YLim',[0 ceil(max(kk10upper(i,itime)/10))*10],'YScale','linear');
title(sregions{i});
xlabel('Time (year AD)');
ylabel('Population size (1E6)'); 

i1=find(time==-500);
l1=find(ntime==time(i1));
l2=find(ntime==-6000);
i3=find(time==-1000);
l3=find(ntime==time(i3));
i4=length(time);
l4=find(ntime==time(i4));

lkk(i,:)=spline(glues.time,s(i,:),ntime);
lkk(i,l1:end)=kk10(i,i1:end);

w=[0:l1-l2]; w=w./max(w);
lkk(i,l2:l1)=lkk(i,l2:l1).*(1-w)+(lkk(i,l2:l1)-7).*w;

w=[0:l4-l1]; w=w./max(w);
lkk(i,l1:l4)=(kk10upper(i,i1:i4)-0.5*kk10(i,i1:i4)).*(1-w)+kk10(i,i1:i4).*w;


p3=plot(ntime,lkk(i,:),'k--','LineWidth',3);
legend([p1,p2,p3],'GLUES','KK10','LKK11');


%% Oceania
% Data for Oceania is uncertain with factor 2, at most 1 Million people
% lived before -1000 AD, according to the estimates, while the KK10
% estimate is half this value.  GLUES consistently and without major
% dynamics simulates a sustainable population slightly above 1 million,
% which falls together with the upper historic estimate around -900 AD.
% GLUES simulates the maximum sustainable hunter-gatherer population.  This
% is an underprediction as many small islands are not simulated within
% GLUES, only the larger islands; this neglection of small islands might
% account for the many uninhabitat islands.  GLUES results should be
% reduced by 200k overall, and then smoothly adusted to the KK10 scenario
%
% 1) reduce GLUES by 100000 at 1000 AD.
% 2) rely on KK10 from 1000 AD

i=12; figure(f+i); clf reset;
p1=plot(glues.time,s(i,:),'b-','LineWidth',2); hold on;
p2=plot(time(itime),kk10(i,itime),'r-','LineWidth',2);
plot(time(itime),kk10lower(i,itime),'r--');
plot(time(itime),kk10upper(i,itime),'r--');
set(gca,'XLim',[-6500,1900],'YLim',[0 ceil(max(kk10upper(i,itime)/10))*10],'YScale','linear');
title(sregions{i});
xlabel('Time (year AD)');
ylabel('Population size (1E6)'); 

i1=find(time==1000);
l1=find(ntime==time(i1));
l2=find(ntime==-6000);
i3=find(time==-1000);
l3=find(ntime==time(i3));
i4=length(time);
l4=find(ntime==time(i4));

lkk(i,:)=spline(glues.time,s(i,:),ntime);
lkk(i,l1:end)=kk10(i,i1:end);


p3=plot(ntime,lkk(i,:),'k--','LineWidth',3);
legend([p1,p2,p3],'GLUES','KK10','LKK11');


%% Summary
% In summary, this shows the global picture again (cmp Figure 1 and 2), with the 
% newly synthesised dataset (preliminarily called LKK11 for Lemmen, Kaplan,
% Krumhard 2011).
%

figure(); clf reset;
hold on;


p1=patch([h(:,1);flipud(h(:,1))],[h(:,2);flipud(h(:,3))],'y','edgecolor','none');

plot(time,sum(lower,1),'r--','LineWidth',1);
p2=plot(time,sum(best,1),'r-','LineWidth',2);
plot(time,sum(upper,1),'r--','LineWidth',1);

p3=plot(glues.time,sum(area.*glues.value/1E6,1),'b-','LineWidth',1);
p4=plot(ntime,sum(lkk,1),'k-','LineWidth',3);
legend([p1 p2 p3 p4],'census.gov','KK10','GLUES','LKK11','location','NorthWest');
xlabel('Time (year AD)');
ylabel('Population size (1E6)'); 
set(gca,'XLim',[-8000 1850]);

%% Dissemination
% I propose to publish the data from 8000 BC (after GLUES has
% equilibrated). Then we have a 10000 year history of regional population
% size which could be a) useful for climate impact modeling and b) land use
% change modeling and c) stimulating research on early population
% estimates.


%% Discussion
% (1) Our result is higher between -600 and -1500 than prior sources, thus we
% are likely to overestimate land use.  Most of the historical estimates
% are very uncertain, however, and we have good reason to believe the -6000
% increase by relating that to the onset of agriculture in SE Europe/West Asi and China
%
% (2) Between -1000 and 500 AD the LKK11 is higher than KK10 but fits well within the uncertainty
% range given by Kristen for the historical data. 
%
% (3) From 500 AD we follow KK10, although, in several regions, even this
% estimate is uncertain as is shown by the upper/lower limits on these
% estimates
%
% (4) We have to discuss whether my subjective weighting for each region is
% okay or whether we need to have better evidence.  I am open to suggestions
%
% (5) I have tried to assess
% the uncertainty in GLUES, but there is really no easy way to contrain
% that.  If at all, I could give some parameter sensitivity, but even the
% natural uncertainty of the parameters is not know, so I don't think this
% makes sense either.

file='lkk11_0.1_20110105.nc'
if exist(file,'file') delete(file); end

ncid=netcdf.create(file,'NOCLOBBER');
nreg=size(s,1)-1;

timedim=netcdf.defDim(ncid,'time',length(ntime));
regdim=netcdf.defDim(ncid,'supraregion',nreg);
varid=netcdf.defVar(ncid,'time','NC_DOUBLE',timedim);
netcdf.putAtt(ncid,varid,'units','Year AD');
netcdf.putAtt(ncid,varid,'long_name','Time');
varid=netcdf.defVar(ncid,'supraregion','NC_INT',regdim);
netcdf.putAtt(ncid,varid,'units','');
netcdf.putAtt(ncid,varid,'long_name','Unique ID of supraregion');
varid=netcdf.defVar(ncid,'population_size_glues','NC_FLOAT',[regdim,timedim]);
netcdf.putAtt(ncid,varid,'units','');
netcdf.putAtt(ncid,varid,'long_name','Population size from GLUES');
varid=netcdf.defVar(ncid,'population_size_kk10','NC_FLOAT',[regdim,timedim]);
netcdf.putAtt(ncid,varid,'units','');
netcdf.putAtt(ncid,varid,'long_name','Population size from KK10');
varid=netcdf.defVar(ncid,'population_size_kk10lower','NC_FLOAT',[regdim,timedim]);
netcdf.putAtt(ncid,varid,'units','');
netcdf.putAtt(ncid,varid,'long_name','Lower estimate for population size from KK10');
varid=netcdf.defVar(ncid,'population_size_kk10upper','NC_FLOAT',[regdim,timedim]);
netcdf.putAtt(ncid,varid,'units','');
netcdf.putAtt(ncid,varid,'long_name','Upper estimate for population size from KK10');
varid=netcdf.defVar(ncid,'population_size_lkk11','NC_FLOAT',[regdim,timedim]);
netcdf.putAtt(ncid,varid,'units','');
netcdf.putAtt(ncid,varid,'long_name','Population size from LKK11');

varid=netcdf.getConstant('GLOBAL');
netcdf.putAtt(ncid,varid,'creation_date',datestr(now));
netcdf.putAtt(ncid,varid,'file_sources',['eurolbk_events.nc',', Pop_estimates.nc']);
netcdf.putAtt(ncid,varid,'user','lemmen');
netcdf.putAtt(ncid,varid,'program',struct2stringlines(cl_get_version));

l0=find(ntime==-1000);
l1=find(ntime==1000);
for i=1:nreg
  ikk10(i,:)=spline(time,kk10(i,:),ntime);
  ikk10l(i,:)=spline(time,kk10lower(i,:),ntime);
  ikk10u(i,:)=spline(time,kk10upper(i,:),ntime);
  ikk10(i,1:l0)=NaN;
  ikk10l(i,1:l0-1)=NaN;
  ikk10u(i,1:l0-1)=NaN;  
  glue(i,:)=spline(glues.time,s(i,:),ntime);
  glue(i,l1+1:end)=NaN;
end


netcdf.endDef(ncid);
varid=netcdf.inqVarID(ncid,'time');
netcdf.putVar(ncid,varid,ntime);
varid=netcdf.inqVarID(ncid,'supraregion');
netcdf.putVar(ncid,varid,1:nreg);
varid=netcdf.inqVarID(ncid,'population_size_lkk11');
netcdf.putVar(ncid,varid,lkk);
varid=netcdf.inqVarID(ncid,'population_size_kk10');
netcdf.putVar(ncid,varid,ikk10);
varid=netcdf.inqVarID(ncid,'population_size_kk10upper');
netcdf.putVar(ncid,varid,ikk10u);
varid=netcdf.inqVarID(ncid,'population_size_kk10lower');
netcdf.putVar(ncid,varid,ikk10l);
varid=netcdf.inqVarID(ncid,'population_size_glues');
netcdf.putVar(ncid,varid,glue);
netcdf.close(ncid);

file=strrep(file,'.nc','_key.txt');
fid=fopen(file,'w');
fprintf('# Supra region keys\n');
for i=1:nreg
  fprintf(fid,'%d %s\n',i,sregions{i});
end
fclose(fid);

return


% From wikipedia 
%Surface area	510,072,000 km2[9][10][note 5]
%148,940,000 km2 land (29.2 %)


end