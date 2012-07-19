function cl_arvesuperregions

arve=load('arveaggregate');

%% From Kristen's population paper super regions
Afghanistan=1;
Alabama=242;
Alaska=243;
Albania=2;
Alberta=230;
Algeria=3;
Argentina_lowland=318;
Arizona=244;
Arkansas=245;
Australia=10;
Austria=11;
Belgium_Luxembourg=15;
Bhutan=18;
British_Columbia=231;
Bulgaria=25;
USSR_Byelarus=204;
California=246;
Cambodia=27;
Canaries=221;
Cape_Verde=224;
Caribbean=43;
Central_America=129;
Ciscaucasia=31;
Colorado=247;
Comoros=40;
Connecticut=248;
Cyprus=44;
Czechoslovakia=45;
Delaware=249;
Denmark=46;
Washington_DC=250;
East_Prussia=201;
Egypt=51;
England_Wales=53;
Equatoria_Zaire_Angola=28;
Ethiopia=56;
Finland=61;
Florida=251;
France=62;
Georgia=252;
Germany=66;
Greece=69;
Greenland=70;
Persian_Gulf=76;
Hungary=82;
Iceland=83;
Idaho=253;
Illinois=254;
Indiana=255;
Indonesia=84;
Iowa=256;
Iran=86;
Iraq=87;
Ireland=88;
Palestine_Jordan=89;
Italy=90;
Japan=93;
Kansas=257;
Kentucky=258;
Kenya=98;
Korea=99;
Laos=100;
Libya=102;
Louisiana=259;
Madagascar=105;
Madeira=222;
Maine=260;
Malaysia_Singapore=107;
Malta=109;
Manitoba=232;
Maryland=261;
Massachusetts=262;
Mauritius=112;
Melanesia=114;
Michigan=263;
Minnesota=264;
Mississippi=265;
Missouri=266;
USSR_Moldova=205;
Mongolia=118;
Montana=267;
Morocco=120;
Mozambique=121;
Burma=122;
Nebraska=268;
Nepal=125;
Netherlands=126;
Nevada=269;
New_Brunswick=233;
New_Hampshire=270;
New_Jersey=271;
New_Mexico=272;
New_York=273;
New_Zealand=128;
Newfoundland=234;
North_Carolina=274;
North_Dakota=275;
Northwest_Territories=235;
Norway=133;
Nova_Scotia=236;
Ohio=276;
Oklahoma=277;
Oman=134;
Ontario=237;
Oregon=278;
Pakistan_India_Bangladesh=136;
Paraguay=139;
Pennsylvania=279;
Philippines=141;
Poland=143;
Polynesia=223;
Portugal=145;
Prince_Edward_Island=238;
Quebec=239;
Reunion=147;
Rhode_Island=280;
Romania=148;
Russian_Turkestan=149;
Rwanda_Burundi=26;
SW_Africa_Botswana=123;
Sahel_States=151;
Sao_Tome_Principe=153;
Saskatchewan=240;
Saudi_Arabia=154;
Scotland=155;
Somalia=158;
South_Carolina=281;
South_Dakota=282;
South_Central_Africa=198;
Southern_Africa=159;
Spain=161;
Sri_Lanka=163;
Sudan=169;
Sweden=173;
Switzerland=174;
Syria_Lebanon=175;
Taiwan=176;
Tanzania=177;
Tennessee=283;
Texas=284;
Thailand=178;
Transcaucasia=200;
Tunisia=180;
Turkey_in_Asia=181;
Turkey_in_Europe=182;
USSR_Central=57;
USSR_Central_Chernozem=214;
USSR_Donetsk_Dnepr=206;
USSR_East_Siberia=216;
USSR_Far_East=217;
USSR_Northwest=209;
USSR_South=207;
USSR_Southwest=208;
USSR_Ural=211;
USSR_Volga=212;
USSR_Volgo_Viatsk=210;
USSR_West=157;
USSR_West_Siberia=215;
Uganda=185;
Uruguay=187;
Utah=285;
Vermont=286;
Vietnam=189;
Virginia=287;
Washington=288;
West_Africa=193;
West_Virginia=289;
Wisconsin=290;
Wyoming=291;
Yemen=195;
Yugoslavia=196;
Yukon_Territory=241;
Anhui=292;
Fujian=293;
Gansu=294;
Guangdong=295;
Guangxi=296;
Guizhou=297;
Hebei=298;
Heilongjiang=299;
Henan=300;
Hubei=301;
Hunan=302;
Jiangsu=303;
Jiangxi=304;
Jilin=305;
Liaoning=306;
Neimenggu=307;
Ningxia=308;
Qinghai=309;
Shaanxi=310;
Shandong=311;
Shanxi=312;
Sichuan=313;
Xinjiang=314;
Xizang=315;
Yunnan=316;
Zhejiang=317;
Amazon=22;
NE_Brazil=50;
North_coast_Brazil=77;
Central_coast_Brazil=19;
South_coast_Brazil=140;
Northern_South_America=188;
Andes=39;
Central_Brazil=319;
Aridoamerica=115;
Central_Mexico=320;
Mayan_America=321;

% Now group these
continental_usa=[242:291];
continental_canada=[230:241];
north_america=[continental_usa continental_canada Greenland];

south_america=[Uruguay Northern_South_America Mayan_America Central_Mexico Central_Brazil Argentina_lowland ...
Caribbean North_coast_Brazil Aridoamerica Central_America Central_coast_Brazil NE_Brazil South_coast_Brazil Andes ...
Paraguay Amazon];

% Europe: Azores missing?
europe=[Albania Austria Belgium_Luxembourg Bulgaria Canaries Czechoslovakia Denmark East_Prussia ...
    England_Wales Finland France Germany Greece Hungary Iceland Ireland Italy Madeira Malta Netherlands Norway ...
    Poland Portugal Romania Scotland Spain Sweden Switzerland Turkey_in_Europe Yugoslavia];

fus=[204:212 214:217 Russian_Turkestan Ciscaucasia USSR_Central USSR_West Transcaucasia];

sw_asia=[Afghanistan Cyprus Iran Iraq Oman Palestine_Jordan Persian_Gulf Saudi_Arabia Syria_Lebanon ...
    Turkey_in_Asia Yemen];


north_africa=[Morocco Algeria Tunisia Libya  Egypt Cape_Verde];
%Subsaharan Africa: Seychelles missing,  Atlantic_Islands?
subsaharan_africa=[Comoros,Equatoria_Zaire_Angola Ethiopia Kenya Madagascar Mauritius Mozambique Reunion ...
    Rwanda_Burundi Sahel_States  Somalia Southern_Africa South_Central_Africa Sudan SW_Africa_Botswana ...
    Tanzania Uganda West_Africa Sao_Tome_Principe];

india=[Pakistan_India_Bangladesh Nepal Bhutan];

china=[292:317 Mongolia Taiwan ];
japan=[Japan];
se_asia=[Vietnam Thailand Sri_Lanka Philippines Malaysia_Singapore Laos Korea Indonesia Cambodia Burma];
oceania=[Australia Melanesia New_Zealand Polynesia];

nar=max(arve.index);
for i=1:nar
  ia=find(arve.index==i);
  if ~isempty(ia) 
      aindex(i)=ia; 
  else aindex(i)=NaN; 
  end
end

area=arve.gluesarea;

% calculate total area of superreigions
ar(1)=sum(area(aindex(north_america)));
ar(2)=sum(area(aindex(south_america)));
ar(3)=sum(area(aindex(europe)));
ar(4)=sum(area(aindex(fus)));
ar(5)=sum(area(aindex(sw_asia)));
ar(6)=sum(area(aindex(north_africa)));
ar(7)=sum(area(aindex(subsaharan_africa)));
ar(8)=sum(area(aindex(india)));
ar(9)=sum(area(aindex(china)));
ar(10)=sum(area(aindex(japan)));
ar(11)=sum(area(aindex(se_asia)));
ar(12)=sum(area(aindex(oceania)));

area=arve.garea;

% Remove countries for which we don't have numbers in GLUES (area=inf)
north_america=north_america(isfinite(area(aindex(north_america))));
south_america=south_america(isfinite(area(aindex(south_america))));
europe=europe(isfinite(area(aindex(europe))));
fus=fus(isfinite(area(aindex(fus))));
sw_asia=sw_asia(isfinite(area(aindex(sw_asia))));
north_africa=north_africa(isfinite(area(aindex(north_africa))));
subsaharan_africa=subsaharan_africa(isfinite(area(aindex(subsaharan_africa))));
india=india(isfinite(area(aindex(india))));
china=china(isfinite(area(aindex(china))));
japan=japan(isfinite(area(aindex(japan))));
se_asia=se_asia(isfinite(area(aindex(se_asia))));
oceania=oceania(isfinite(area(aindex(oceania))));

arc(1)=sum(area(aindex(north_america)));
arc(2)=sum(area(aindex(south_america)));
arc(3)=sum(area(aindex(europe)));
arc(4)=sum(area(aindex(fus)));
arc(5)=sum(area(aindex(sw_asia)));
arc(6)=sum(area(aindex(north_africa)));
arc(7)=sum(area(aindex(subsaharan_africa)));
arc(8)=sum(area(aindex(india)));
arc(9)=sum(area(aindex(china)));
arc(10)=sum(area(aindex(japan)));
arc(11)=sum(area(aindex(se_asia)));
arc(12)=sum(area(aindex(oceania)));
arc(13)=sum(arc(1:12));
arc(:)=1;
ar(:)=1;


arve.value=arve.arvedensity;
ntime=size(arve.value,2);
area=repmat(arve.garea',1,ntime);

s(1,:)=sum(area(aindex(north_america),:).*arve.value(aindex(north_america),:)).*ar(1)./arc(1);
s(2,:)=sum(area(aindex(south_america),:).*arve.value(aindex(south_america),:)).*ar(2)./arc(2);
s(3,:)=mean(area(aindex(europe),:).*arve.value(aindex(europe),:)).*ar(3)./arc(3);
s(4,:)=sum(area(aindex(fus),:).*arve.value(aindex(fus),:)).*ar(4)./arc(4);
s(5,:)=sum(area(aindex(sw_asia),:).*arve.value(aindex(sw_asia),:)).*ar(5)./arc(5);
s(6,:)=sum(area(aindex(north_africa),:).*arve.value(aindex(north_africa),:)).*ar(6)./arc(6);
s(7,:)=sum(area(aindex(subsaharan_africa),:).*arve.value(aindex(subsaharan_africa),:)).*ar(7)./arc(7);
s(8,:)=sum(area(aindex(india),:).*arve.value(aindex(india),:)).*ar(8)./arc(8);
s(9,:)=sum(area(aindex(china),:).*arve.value(aindex(china),:)).*ar(9)./arc(9);
s(10,:)=(area(aindex(japan),:).*arve.value(aindex(japan),:)).*ar(10)./arc(10);
s(11,:)=sum(area(aindex(se_asia),:).*arve.value(aindex(se_asia),:)).*ar(11)./arc(11);
s(12,:)=sum(area(aindex(oceania),:).*arve.value(aindex(oceania),:)).*ar(12)./arc(12);
s(13,:)=sum(s(1:12,:),1);
s=s/1E6;

figure(1); clf reset;
hold on;


% historical estimates 
% from http://www.census.gov/ipc/www/worldhis.html

h=[-10000 1 10; -8000 5 10; -6500 5 10 ; -5000 5 20; ...
    -4000 7 NaN; -3000 14  NaN ; -2000 27 NaN ; -1000 50 NaN; ...
    -500 100 NaN; -400 162 NaN ; -200 150 231 ; 0 170 400;]


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


%plot(h(:,1),h(:,2),'k--');

p=polyfit(h([4,10],1),log(h([4,11],3)),1);
inan=find(isnan(h(:,3)));
h(inan,3)=exp(p(1).*h(inan,1)+p(2))
%plot(h(:,1),h(:,3),'k--');

set(gca,'YScale','log');
patch([h(:,1);flipud(h(:,1))],[h(:,2);flipud(h(:,3))],'y','edgecolor','none');
plot(arve.time,s(13,:),'b-','Linewidth',4);
i=13;
plot(repmat(-1000,1,3),arvedata(i,:),'rd','linestyle','-','linewidth',3);

set(gca,'Xlim',[min(arve.time),0]);
set(gca,'Ylim',[1 1000]);
xlabel('Time (year AD)');
ylabel('Population size (1E6)'); 
legend('Estimates','GLUES','Kristen','location','northwest');
title('Global population');

return;
figure(2);
c='rgbcmkrgbcmkr';
ls='------::::::-';
for i=1:12 
  plot(arve.time,s(i,:),'r-','color',c(i),'LineStyle',ls(i));
end
plot(arve.time,s(13,:),'r-','color',c(13),'LineStyle','--');
set(gca,'Xlim',[min(arve.time),0]);
set(gca,'Ylim',[0.01 15000]);
xlabel('Time (year AD)');
ylabel('Population size (1E6)'); 
legend('NAM','SAM','EUR','FUS','SW Asia','N Afr','Subsah Afr','India','China','Japan','SE Asia','Oceania','Location','northeastoutside');



ms='dddddd......s';
for i=1:13 
  plot(repmat(-940+40*i,1,3),arvedata(i,:),'r.','color',c(i),'LineStyle',ls(i),'Marker',ms(i));
end
set(gca,'YScale','log')




% From wikipedia 
%Surface area	510,072,000 km2[9][10][note 5]
%148,940,000 km2 land (29.2 %)


end