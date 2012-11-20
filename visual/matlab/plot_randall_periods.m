function plot_randall_periods ()
% the function plots Randel Law's data according to phase and site
% geolocation in different symbols
% Authors: Aurangzeb Khan & Carsten Lemmen
%% Required if function IVC_sites is not used. 
% latlim=[20 36];
% lonlim=[60 80];
% figure(1); clf reset;
% m_proj('miller','lat',latlim,'lon',lonlim);
% m_grid('box','fancy','tickdir','in','xticklabels',[],'yticklabels',[],'linest','none','fontsize',18,'backcolor',[0.95 0.95 0.95]);
% hold on;
% m_coast();



%% Main function which calls other functions if required
% Plots the geographic area and the river
% Todo: make entire river blue
close all;
%[latlim, lonlim]=IVC_sites ;
title('Protohistoric sites of South Asia');   % may be changed  depending on the functions selection
colors=jet(10);
colors=colors(3:8,:);


% Load all data
data=load('randall_ivc_data.mat');

%% Define times for relevant periods
% Pre harappan / Early Neolithic
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
bbm=strmatch('Burj Basket-marked',data.period);
%en=vertcat(kili,bbm)

% Developed Neolithic
togau=strmatch('Togau',data.period);
kb=strmatch('Kechi Beg',data.period); 
hw=strmatch('Hakra Wares',data.period);

% Early Harappa
amri=strmatch('Amri',data.period);
kot=strmatch('Kot Dij',data.period); 
ss=strmatch('Sothi-Siswal',data.period);
ds=strmatch('Damb Sadaat',data.period);
erhar=strmatch('Early Harappan',data.period);
hakra=strmatch('Hakra',data.period);
ravi=strmatch('Ravi',data.period);
%eh=vertcat(amri,kot,ss,ds,erhar);


% Stage five: Mature harappan
Kulli=strmatch('Kulli',data.period);
Sorath=strmatch('Sorath',data.period);  
matur=strmatch('Harappan (Mature)',data.period);
mh=vertcat(Kulli,Sorath,matur);

% Stage six: Late harappan
post=strmatch('Post-urban',data.period);
Jhukar=strmatch('Jhukar',data.period); 
Pirak=strmatch('Pirak',data.period); 
lsorath=strmatch('Late Sorath',data.period); 
lrw=strmatch('Lustrous Red Ware',data.period); 
cem=strmatch('Cem',data.period);
lhr=strmatch('Late Harappan',data.period); %Late Harappan
lhpgw=strmatch('Late Harappan and PGW',data.period);
swat=strmatch('Swat',data.period);
lh=vertcat(post,Jhukar,Pirak,lsorath,lrw,cem,swat,lhpgw,lhr);
%% Old code Print sites
% % early neolithic
% i=1;
% figure(i); clf reset;
% IVC_sites;
% title('Pre-Harappans (Early Neolithic)')
% p(i)=plot_period(data,vertcat(kili,bbm),horzcat(kilitime,bbmtime),'ro');
% set(p(i),'Color',colors(i,:));
% legend(p(i),get(p(i),'tag'),'location','southeast');
% %pakistan;
% ak_pol_bndry(latlim,lonlim);% this function needs latlim & lonlim as variables
% %ak_disputed_bndry;
% %cl_print('name','U:\My Documents\MATLAB\plots\RL_Pre_Har(EN)','ext',{'pdf','png'},'res',600);
% % pre harappans
% i=2;
% figure(i); clf reset;
% IVC_sites;
% title('Pre-Harappans (Developed Neolithic)');   % may be changed  depending on the functions selection
% p(i)=plot_period(data,vertcat(togau,kb,hw),horzcat(togautime,kbtime,hwtime),'ro');
% set(p(i),'Color',colors(i,:));
% legend(p(i),get(p(i),'tag'),'location','southeast');
% ak_pol_bndry(latlim,lonlim);
% cl_print('name','U:\My Documents\MATLAB\plots\RL_Pre_Har(DN)','ext','png','res',600);
% % Early harappans
% i=3;
% figure(i); clf reset;
% IVC_sites;
% title('Early Harappans');   % may be changed  depending on the functions selection
% p(i)=plot_period(data,vertcat(amri,kot,ss,ds,erhar,hakra,ravi),ehtime,'go');
% set(p(i),'Color',colors(i,:));
% legend(p(i),get(p(i),'tag'),'location','southeast');
% ak_pol_bndry(latlim,lonlim);
% cl_print('name','U:\My Documents\MATLAB\plots\RL_Early_Har','ext','png','res',600);
% % Mature Harappans
% i=4;
% figure(i); clf reset;
% IVC_sites;
% title('Mature Harappans');   % may be changed  depending on the functions selection
% p(i)=plot_period(data,mh,mhtime,'bo');
% set(p(i),'Color',colors(i,:));
% legend(p(i),get(p(i),'tag'),'location','southeast');
% ak_pol_bndry(latlim,lonlim);
% cl_print('name','U:\My Documents\MATLAB\plots\RL_Mature_Har','ext','png','res',600);
% % Late Harappans
% i=5;
% figure(i); clf reset;
% IVC_sites;
% title('Late Harappans');     % may be changed  depending on the functions selection
% p(i)=plot_period(data,lh,posttime,'ko');
% set(p(i),'Color',colors(i,:));
% legend(p(i),get(p(i),'tag'),'location','southeast');
% ak_pol_bndry(latlim,lonlim);
% cl_print('name','U:\My Documents\MATLAB\plots\RL_Late_Har','ext','png','res',600);
%% Find Area by Possehl

% Stage One: Beginnings of Vii/age Farming Communities and Pastoral Camps
% Kili Ghul Mohammad 7000-5000 B.C. 
% Phase Burj Basket-marked 5000-4300 B.C.

% Stage Two: Developed Vii/age Farming Communities and Pastoral Societies
% Togau Phase 4300-3800 B.C. 
% Kechi Beg/Hakra Wares Phase 3800-3200 B.C.

% Stage Three: Early Harappan
% Four phases thought to have been generally contemporaneous Amri-Nal Phase
% Kot Diji Phase Sothi-Siswal Phase Damb Sadaat Phase
% 3200-2600 B.C. 3200-2600 B.C. 3200-2600 B.C. 3200-2600 B.C.

% Possehl, The Indus civilization: a contemporary perspective, 2002, Page 29
%% Start of code
possehl_indices={kili bbm togau kb hw amri kot ss ds mh lh };
phase_heading={'Kili Gul (7000 5000 BC)'; 'BBM (5000 4300 BC)'; 'Togau (5000 4300 BC)'; 'Kalibangan'; 'Hakra Wares'; 'Amri'; 'Kot Diji'; ...
    'Sothi Siswal'; 'Damb Salaat'; 'Mature Har (2600 1900 BC)'; 'Late Har (1900 1300 BC)'};
possehl_areas=[2.65 2.58 3.51 6.69 5.44 3.67 6.31 4.28 2.64 7.25 NaN];

possehl_time=[7000 5000 4300 3800 3200 2600 1900 1300];
possehl_merge={ 1; 2; 3; [4,5]; [6:9]; 10; 11};
possehl_headings={'Kili Gul (7000 5000 BC)'; 'BBM (5000 4300 BC)'; 'Togau (5000 4300 BC)'; ...
    'Pre-Harappan (3800 3200 BC)'; 'Early Har (3200 2600 BC)'; 'Mature Har (2600 1900 BC)'; 'Late (1900 1300 BC)'};

%data.hectares=log(data.hectares);

for i=1:length(possehl_indices)
  sn(i)=length (possehl_indices{i}); % Site Numbers
  a=data.hectares(possehl_indices{i});
  i_have_area=find(a>0 & isfinite(a));
 % i_have_area=find(isfinite(a));
  
  if ~isempty(i_have_area)
        q=figure(2+i); clf reset;
        ahave=a(i_have_area);
        uhave=unique(ahave);
        uhave=uhave(isfinite(uhave));
        lhave=length(uhave);
        if lhave==1 
            fprintf('No histogram plotted\n'); 
            continue;
        end
        fprintf('There are %d unique area estimates in %s\n',lhave,phase_heading{i});
        %xer=min(a(i_have_area)):mean(a(i_have_area))/2:max(a(i_have_area));
        if lhave>30 lhave=20; end;
        xinterval=(max(ahave)-min(ahave))/(lhave+1);
        
        xer=[min(ahave):xinterval:max(ahave)];
        hist(a(i_have_area),xer);
         fs=18;
        xlabel('Site area (ha)','Fontsize',fs);
        ylabel('# of sites','Fontsize',fs);
        title(phase_heading{i},'Fontsize',fs);
  
        set(gca,'Fontsize',fs,'xlim',[.01 100]);
        set(gca,'Xscale','log');
        %cl_print('name',sprintf('U:\\My Documents\\MATLAB\\plots\\sitedist\\sites_dist_%d',q),'ext',{'pdf','png'},'res',600);
  end
  i_have_no_area=find(a==0 | isnan(a));
  known_area=sum(a(i_have_area));
  n_no_area=length(i_have_no_area);
  n_area=length(i_have_area);
  site_numbers=length (possehl_indices{i});

  if isnan(possehl_areas(i))
    a(i_have_no_area)=mean(a(i_have_area));
  else
    a(i_have_no_area)=possehl_areas(i);
  end
  
  %avgarea=known_area/i_have_area;
  ta(i)=sum(a); % total area   
end



for i=1:length(possehl_merge)
    if length(possehl_merge{i})==1 continue; end
    a=data.hectares(cell2mat(vertcat(possehl_indices(possehl_merge{i})')));
    i_have_area=find(a>0 & isfinite(a));
  
    if ~isempty(i_have_area)
        p=figure(14+i); clf reset;
        ahave=a(i_have_area);
        lhave=length(unique(ahave));
        fprintf('There are %d unique area estimates in %s\n',lhave,possehl_headings{i});
        %xer=min(a(i_have_area)):mean(a(i_have_area))/2:max(a(i_have_area));
        if lhave>30 lhave=20; end;
        xinterval=(max(ahave)-min(ahave))/(lhave+1);
        
        xer=[min(ahave):xinterval:max(ahave)];
        hist(a(i_have_area),xer);
        xlabel('Site area (ha)','Fontsize',fs);
        ylabel('# of sites','Fontsize',fs);
        title(possehl_headings{i},'Fontsize',fs);
        set(gca,'Fontsize',fs);
        set(gca,'Fontsize',fs,'xlim',[.01 100]);
        set(gca,'Xscale','log');
       cl_print('name',sprintf('U:\\My Documents\\MATLAB\\plots\\sitedist\\sites_dist_%d',p),'ext',{'pdf','png'},'res',600);

    end
end



 tar=[ta(1) ta(2) ta(3) sum(ta(4:5)) sum(ta(6:9)) ta(10) ta(11)]; % reduced area vector to match possehl chronology
 snr=[sn(1) sn(2) sn(3) sum(sn(4:5)) sum(sn(6:9)) sn(10) sn(11)]; % reduced site numbers vector to match possehl chronology
 avgarea=tar./snr;
 figure;
 plot(possehl_time(2:end),snr*10,'--r');
 hold on;
 plot(possehl_time(2:end),tar,'linewidth',2);
 plot(possehl_time(2:end),avgarea*5000,'--c','linewidth',2);
 fs=14;
 xlabel('Time in BCE','Fontsize',fs);
 ylabel('hectares and numbers','Fontsize',fs);
 legend('Site numbers * 10','Total area','avg area/site','location','northwest');
 ts=sum(sn);
 title(['Temporal Distribution of ',num2str(ts),' sites and area in IVC'],'Fontsize',fs); 
 set(gca,'XDir','reverse','Fontsize',fs);
 cl_print('name','U:\My Documents\MATLAB\plots\sites_area_ivc','ext',{'pdf','png'},'res',600);
 
 %% Carsten's Stair plot
 figure(9); clf reset; hold on;
 ptimestairs=[possehl_time(1) reshape(repmat(possehl_time(2:end-1),2,1),12,1)' possehl_time(end)]
 tarstairs=reshape(repmat(tar,2,1),14,1);
 snrstairs=reshape(repmat(snr,2,1),14,1);
 lw=4;
 fs=14;
 plot(ptimestairs,tarstairs,'r-','linewidth',lw);
 ax1=gca;
 ylabel('Total area of sites (ha)','Fontsize',fs);
 set(gca,'XDir','reverse','Fontsize',fs,'Box','off','YAxisLocation','left','color','none','YColor','r');
 
 
 ax2=axes;
 lw=2.5;
 plot(ptimestairs,snrstairs,'b-','linewidth',lw);
 xlabel('Time in BCE','Fontsize',fs);
 ylabel('Number of sites','Fontsize',fs);
 set(gca,'XDir','reverse','Fontsize',fs,'Box','off','YAxisLocation','right','color','none','YColor','b');
 set(ax2,'Position',get(ax1,'Position'));

 save('randall_periods_sites_areas','ptimestairs','snrstairs','tarstairs');
 
 %Legend('Site numbers * 10','Total area','location','northwest');
 ts=sum(sn);
 title(['Temporal Distribution of ',num2str(ts),' sites and area in IVC'],'Fontsize',fs); 
 set(gca,'XDir','reverse','Fontsize',fs);
 
 cl_print('name','U:\My Documents\MATLAB\plots\sites_area_ivc2','ext',{'pdf','png'},'res',600);

 
 
%% Print all sites in one picture
% Todo: nicer colors
figure(7); clf reset;
IVC_sites; 
hold on;
title('Protohistoric sites of South Asia');   % may be changed  depending on the functions selection

p(1)=plot_period(data,vertcat(kili,bbm),horzcat(kilitime,bbmtime),'ro');
set(p(1),'MarkerSize',12);
set(p(1),'Color',colors(1,:));

%%%%%%%%%%%%%%%%%%%
%% Make a function for this one
% ind=vertcat(kili,bbm);
% ar=data.hectares(ind);
% ar(ar<=0)=NaN;
% armin=min(ar);armax=max(ar);
% %if (armin==armax) ms=zeros(length(ar),1)+10;
% %else ms=5*ar;
% %end
% 
% for i=1:length(ar) 
%     if isnan(ar(i)) continue; end
%     p1(i)=plot_period(data,ind(i),horzcat(kilitime,bbmtime),'bo');
%     set(p1(i),'MarkerSize',5*ar(i));
%     set(p1(i),'MarkerFaceColor','r');
% end

%%%%%%%%%%%%%%%%%%%%%%%%

p(2)=plot_period(data,vertcat(togau,kb,hw),horzcat(togautime,kbtime,hwtime),'bo');
set(p(2),'MarkerSize',10);
set(p(2),'Color',colors(2,:));

p(3)=plot_period(data,vertcat(amri,kot,ss,ds,erhar,hakra,ravi),ehtime,'go');
set(p(3),'MarkerSize',8);
set(p(3),'Color',colors(3,:));

p(4)=plot_period(data,mh,mhtime,'ro');
set(p(4),'MarkerSize',6);
set(p(4),'Color',colors(4,:));

p(5)=plot_period(data,lh,posttime,'ko');
set(p(5),'MarkerSize',4);
set(p(5),'Color',colors(5,:));

ak_pol_bndry(latlim,lonlim);
%% with IVC area markers
% L=akp_googleplot;
% legend([p(1,:),L],[get(p(1,:),'tag')','Mature','Early'],'location','northwest');
%% 
legend(p(1,:),get(p(1,:),'tag'),'location','northwest');

%cl_print('name','U:\My Documents\MATLAB\plots\RL_all_phases','ext',{'pdf','png'},'res',600);

%m_plot(data.longitude(kili),data.latitude(kili),'ro','MarkerSize',16,'LineWidth',2);

%&[firstph,secondph]=early_neolithic(data);

%en=vertcat(kili,bbm);

% latlim=[min(latitude(en)) max(latitude(en))];
% lonlim=[min(longitude(en)) max(longitude(en))];
% m_proj('miller','lat',latlim+[-4 4],'lon',lonlim+[-4 4]);

return;



function hdl=plot_period(data,index,time,marker)
  hdl=m_plot(data.longitude(index),data.latitude(index),marker);
  timestring=sprintf('%4d-%4d BC',abs(min(time)),abs(max(time)));
  set(hdl,'tag',timestring);
return

