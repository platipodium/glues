function retdata=clp_spread_mechanism(varargin)

arguments = {...
  {'file','../../eurolbk_base.log '},...
  {'timelim',[-8000 -3500]},...
  {'retdata',NaN},...
  {'hreg',[271 255  211 183 178 170 146 142 123 122]},...
};

%{'file','../../../../Downloads/eurolbk_0.0160000_0000001.56_000.025000_.log'},...


area=[47328 45356 61132 86768 51272 59160 106488 114376 59160 132124]';

cl_register_function;

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length 
  eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); 
end

hreg='all';


%% Read results file with .log extension
[fp fn fe]=fileparts(file);
file=fullfile(fp,[fn '.log']);
if ~exist(file,'file') warning('File does not exist'); return; end
d=load(file,'-ascii');
if (numel(d)==0)
  warning('File empty, skipped');
  return;
end
% time import_id export_id import_tech_i import_tech_p
% import_ndom_i import_ndom_p import_qfarm_p import_pop_p export_pop_p
time=d(:,1)-2*9500;
iid=d(:,2);
eid=d(:,3);

if ischar(hreg)
  hreg=unique([iid,eid]);
end
nhreg=length(hreg);

letters='ABCDEFGHIJKLMNOPQRSTUVW';
if length(letters)>=nhreg
  letters=letters(1:nhreg);
end




%% Read netCF file
[fp fn fe]=fileparts(file);
file=fullfile(fp,[fn '.nc']);
if ~exist(file,'file') error('File does not exist'); end
ncid=netcdf.open(file,'NOWRITE');
varid=netcdf.inqVarID(ncid,'region');
region=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'time');
rtime=netcdf.getVar(ncid,varid);
itime=find(rtime>=timelim(1) & rtime<=timelim(2));
rtime=rtime(itime);
varid=netcdf.inqVarID(ncid,'farming');
farming=netcdf.getVar(ncid,varid);
population=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'population_density'));
technology=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'technology'));
economies=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'economies'));
netcdf.close(ncid);
nreg=length(region);
threshold=0.5;

farming=farming(hreg+1,itime);
technology=technology(hreg+1,itime);
economies=economies(hreg+1,itime);
population=population(hreg+1,itime);
%area=repmat(area,1,length(itime));
%popsize=population.*area;
for i=1:nhreg
    im=find(farming(i,:)>=threshold);
    if isempty(im) timing(i)=inf;
    else timing(i)=rtime(min(im));
    end
end

% Calculate percentiles
pcv=[0.1:0.1:0.9];
npc=length(pcv);
pc=zeros(nhreg,npc);
for i=1:nhreg for ip=1:npc
  im=find(farming(i,:)>=pcv(ip));
  if isempty(im) pc(i,ip)=inf;
  else pc(i,ip)=rtime(min(im));
  end   
end,end


C=textscan(fn,'%s%f%f%f','Delimiter','_');


if (1==0)
figure(10); clf reset; hold on;
for i=2:nhreg
  subplot(3,3,i-1);
  ir=find(iid==hreg(i) & time<=-timelim(2) & time>=timelim(1));
  plot(time(ir),cumsum(d(ir,4)),'r-');
  hold on;
  plot(time(ir),cumsum(d(ir,5)),'b-');
  plot(time(ir),cumsum(d(ir,4)+d(ir,5)),'g-');
  plot(time(ir),cumsum(d(ir,6)),'r--');
  plot(time(ir),cumsum(d(ir,7)),'b--');
  plot(time(ir),cumsum(d(ir,8)),'b:');
  plot(time(ir),cumsum(d(ir,9)),'m-');
  plot(time(ir),-cumsum(d(ir,10)),'m--');
  plot(rtime,farming(i,:),'k-');
  set(gca,'Xlim',timelim,'YLim',[-0.02 1.1]);
  title([letters(i) ' ' num2str(timing(i))]);
  if (i==nhreg) legend('T_i','T_p','T_{i+p}','N_i','N_p','q_p','p_i','p_e','Q','Location','NorthWest'); end

end

plot_multi_format(gcf,['spread_mechanism_ ' fn],'pdf');
end


for i=1:nhreg 
  fprintf('%d...\n',i);  
  for it=1:length(rtime)
  ir=find(iid'==hreg(i) & time'==rtime(it));
  dNi(i,it)=sum(d(ir,6));
  dNp(i,it)=sum(d(ir,7));
  dTi(i,it)=sum(d(ir,4));
  dTp(i,it)=sum(d(ir,5));
  dQp(i,it)=sum(d(ir,8));
  dPadd(i,it)=sum(d(ir,9));
  dPsub(i,it)=sum(d(ir,10));
end,end


if (2==0)
%for i=2:nhreg
for i=8:8
  tlim=timing(i)+[-850 850];
  tlim(1)=max([timelim(1) tlim(1)]);
  tlim(2)=min([timelim(2) tlim(2)]);
  if (i==8) tlim=[-6250,-4750]; end
  %tlim=timelim;
  figure(10+i); clf reset; hold on;
  ir=find(iid==hreg(i) & time<=-tlim(2) & time>=tlim(1));
  plot(rtime,cumsum(dNi(i,:)),'r-','lineWidth',2);
  hold on;
  %plot(rtime,cumsum(dTi(i,:)),'r--','lineWidth',4);
  %plot(rtime,cumsum(dNp(i,:)),'b-','lineWidth',2);
  %plot(rtime,cumsum(dTp(i,:)),'b--','lineWidth',4);
  %plot(rtime,cumsum(dQp(i,:)),'g-','lineWidth',2);
  plot(rtime,cumsum(dTi(i,:)./technology(i,:)),'r--','lineWidth',4);
  plot(rtime,cumsum(dNp(i,:)./economies(i,:)),'b-','lineWidth',2);
  plot(rtime,cumsum(dTp(i,:)./technology(i,:)),'b--','lineWidth',4);
  plot(rtime,cumsum(dQp(i,:)./farming(i,:)),'g-','lineWidth',2);
  %plot(time(ir),(d(ir,4)+d(ir,5)),'g-');
  %plot(time(ir),cumsum(d(ir,8)),'b:');
  %plot(time(ir),cumsum(d(ir,9)),'m-');
  %plot(time(ir),-cumsum(d(ir,10)),'m--');
  plot(rtime,farming(i,:),'k-','lineWidth',2);
  %plot(rtime,cumsum(dPadd(i,:))./popsize(i,:)*10000,'g-','LineWidth',4);
  xlabel('Time (year BC)','Fontsize',15);
  set(gca,'Xlim',tlim,'YLim',[0.0 1.1],'FontSize',15);
  pos=get(gca,'Position');
  set(gca,'Position',pos.*[1 1 0.5 1]);
  xtl=get(gca,'XTickLabel');
  set(gca,'XTickLabel',xtl(:,2:end));
  ytl=get(gca,'YTickLabel');
  set(gca,'YTickLabel',num2str(str2num(ytl)*100));
  title([letters(i) ' ' num2str(timing(i))]);
  l=legend('\Delta N_i','\Delta T_i','\Delta N_p','\Delta T_p','\Delta Q_p','Q','Location','NorthEastOutside');
  set(l,'FontSize',15);
  cl_print('name',['spread_mechanism_' letters(i) '_' fn],'ext','pdf');
  fprintf('%s %3d %5d %5d-%5d (%5d)\n',letters(i),hreg(i),pc(i,5),...
      pc(i,1),pc(i,9),pc(i,9)-pc(i,1));
end
end
    
spreadname=strrep(['spread_mechanism_all_' fn],'.log','.mat');
reldNi=cumsum(dNi./economies,2);
reldNp=cumsum(dNp./economies,2);
reldQp=cumsum(dQp./farming,2);
reldTi=cumsum(dTi./technology,2);
reldTp=cumsum(dTp./technology,2);
save(spreadname,'-v6','hreg','rtime','reldNi','reldNp','reldTi',...
    'reldTp','reldQp','farming');

if (0==2)
for i=2:nhreg
%for i=8:8
  tlim=timing(i)+[-1250 1250];
  tlim(1)=max([timelim(1) tlim(1)]);
  tlim(2)=min([timelim(2) tlim(2)]);
  
  figure(10+i); clf reset; hold on;
  plot(rtime,(dNi(i,:)./economies(i,:)),'r-','lineWidth',4);
  hold on;
  plot(rtime,(dTi(i,:)./technology(i,:)),'r--','lineWidth',2);
  plot(rtime,(dNp(i,:)./economies(i,:)),'b-','lineWidth',4);
  plot(rtime,(dTp(i,:)./technology(i,:)),'b--','lineWidth',2);
  %plot(time(ir),(d(ir,4)+d(ir,5)),'g-');
  %plot(time(ir),cumsum(d(ir,8)),'b:');
  %plot(time(ir),cumsum(d(ir,9)),'m-');
  %plot(time(ir),-cumsum(d(ir,10)),'m--');
  plot(rtime,farming(i,:)*100,'k-','lineWidth',2);
  xlabel('Time (year BC)','Fontsize',15);
  set(gca,'Xlim',tlim,'FontSize',15);
  set(gca,'YLim',[0.0 11]);
  pos=get(gca,'Position');
  %set(gca,'Position',pos.*[1 1 0.5 1]);
  xtl=get(gca,'XTickLabel');
  set(gca,'XTickLabel',xtl(:,2:end));
  title([letters(i) ' ' num2str(timing(i))]);
  l=legend('N_i','T_i','N_p','T_p','Q','Location','NorthEastOutside');
  set(l,'FontSize',15);
  cl_print('name',['spread_mechanism_percent_' letters(i) '_' fn],'ext','pdf');
end
end
    




if nargout>0
  retdata=double([C{2:4} timing]);
end


return;
end