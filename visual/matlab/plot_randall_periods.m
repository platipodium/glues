function clp_harappa_chronology
% the function plots Randel Law's data according to phase and site
% geolocation in different symbols
% Authors: Aurangzeb Khan & Carsten Lemmen

%% Main function which calls other functions if required
% Plots the geographic area and the river

load('../../data/naturalearth/10m_admin_0_countries.mat');
data=load('../../data/randall_ivc_data.mat');

for i=1:length(shape)
  if strmatch(shape(i).SOVEREIGNT,'Pakistan') ipak=i; break; end
end
plat=shape(ipak).Y;
plon=shape(ipak).X;
latlim=[min(plat) max(plat)] + 2*[-1 1];
lonlim=[min(plon) max(plon)] + 2*[-1 1];


figure(1); clf reset;
m_proj('miller','lat',latlim,'lon',lonlim);
m_coast;
hold on;
m_grid;

m_patch(plon,plat,'k','FaceAlpha',0.3,'EdgeColor','none');

title('Protohistoric sites of South Asia');   % may be changed  depending on the functions selection


%7 periods: pre7k,7k-5k, 5k-4.3k,4.3-3.8,3.8-3.2,3.2-2.6,post2.6
cmap=[[0.5 0 0.5,
       0.5 0 1;
       0   0 1;
       0 0.5 1;
       0 1 1;
       ]];


%% Define times for relevant periods
% Pre harappan/Early Neolithic
kilitime=[-7000 -5000];
bbmtime=[-5000 -4300];

% Developed neolithic
togautime=[-4300 -3800];
kbtime=[-3800 -3200];
hwtime=[-3800 -3200];

% Stage three: Early harappan
ehtime=[-3200 -2600];

% Stage five: Mature harappan
mhtime=[-3200 -2600];

% Stage six: Late harappan
posttime=[-1900 -1300];

%% Define indices for relevant periods
% Stage one: Pre harappan
kili=strmatch('Kili Ghul Mohammad',data.period);
bbm=[
 strmatch('Burj Basket-marked',data.period);
 strmatch('Bhurj',data.period);
 strmatch('Mehrgarh',data.period);
]
 
%en=vertcat(kili,bbm)

% Developed Neolithic
togau=[strmatch('Togau',data.period);
    strmatch('SKT',data.period)];
kb=strmatch('Kechi Beg',data.period); 
hw=strmatch('Hakra Wares',data.period);
anarta=strmatch('Hakra Wares',data.period);

% Early Harappa
ahar=strmatch('Ahar',data.period);
amri=strmatch('Amri*',data.period);
kot=strmatch('Kot Dij*',data.period); 
ss=strmatch('Sothi-Siswal',data.period);
ds=strmatch('Damb Sadaat',data.period);
rav=strmatch('Ravi',data.period);
erhar=strmatch('Early Harappan',data.period);
%eh=vertcat(amri,kot,ss,ds,erhar);


% Stage five: Mature harappan
Kulli=strmatch('Kulli*',data.period);
Sorath=strmatch('Sorath*',data.period);  
matur=strmatch('Harappan (Mature)',data.period);
achhar=strmatch('Accharwala',data.period);
mh=vertcat(Kulli,Sorath,matur,achhar,ahar);

% Stage six: Late harappan
post=strmatch('Post-urban',data.period);
Jhukar=strmatch('Jhukar',data.period); 
Pirak=strmatch('Pirak*',data.period); 
lsorath=strmatch('Late Sorath*',data.period); 
lrw=strmatch('Lustrous Red Ware',data.period); 
cem=strmatch('Cem*',data.period);
lhr=strmatch('Late Harappan*',data.period); %Late Harappan
lhpgw=strmatch('Late Harappan and PGW',data.period);
swat=strmatch('Swat*',data.period);
lh=vertcat(post,Jhukar,Pirak,lsorath,lrw,cem,swat,lhpgw,lhr);

all=vertcat(ahar,kili,bbm,togau,kb,hw,amri,kot,ss,ds,erhar,mh);
p(10)=m_plot(data.longitude(all),data.latitude(all),'k.');

p_index={kili,bbm,togau,vertcat(kb,hw,anarta),vertcat(ahar,amri,kot,ss,ds,erhar,rav),mh,lh};
p_times={-7000,-5000,-4300,-3800,-3200,-2600,-1900,-1300};
save('randall_ivc_data_periods.mat','p_index','p_times');

for i=5:-1:1
  p(i)=m_plot(data.longitude(p_index{i}),data.latitude(p_index{i}),'ko','MarkerFaceColor',cmap(i,:),'MarkerEdgeColor','none');
end

return;
