function retdata=clp_spread_mechanism_bar(varargin)

arguments = {...
  {'hreg',[271 255  211 183 178 170 146 142 123 122]},...
};

cl_register_function;

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length 
  eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); 
end

nhreg=length(hreg);
letters='ABCDEFGHIJKLMNOPQRSTUVW';
letters=letters(1:nhreg);


%% Read results file with .log extension
% If these files don't exist, run clp_spread_mechanism
base=load('spread_mechanism_eurolbk_base');
cult=load('spread_mechanism_eurolbk_cultural');
demic=load('spread_mechanism_eurolbk_demic');

% Calculate percentiles
pcv=[0.05 0.1:0.1:0.9 0.95 0.99];
npc=length(pcv);
pc=zeros(nhreg,npc,3);
for ir=1:3 for i=1:nhreg for ip=1:npc
  switch (ir)
    case 1, farming=demic.farming;
    case 2, farming=base.farming;
    case 3, farming=cult.farming;
  end
  im=find(farming(i,:)>=pcv(ip));
  if isempty(im) 
    pc(i,ip,ir)=inf;
    pci(i,ip,ir)=[];
  else
    pc(i,ip,ir)=base.rtime(min(im));
    pci(i,ip,ir)=min(im);
  end   
end,end,end

%Feature regions 3,6,8

for ir=2:nhreg
  figure(20+ir); clf reset; hold on;
  ip=10;
  %for ip=[510 12]
    %subplot(3,1,ip);
    it=(pci(ir,ip,:));
    Qp=[demic.reldQp(ir,it(1)),base.reldQp(ir,it(2)),cult.reldQp(ir,it(3))]';
    Tp=[demic.reldTp(ir,it(1)),base.reldTp(ir,it(2)),cult.reldTp(ir,it(3))]';
    Ti=[demic.reldTi(ir,it(1)),base.reldTi(ir,it(2)),cult.reldTi(ir,it(3))]';
    Np=[demic.reldNp(ir,it(1)),base.reldNp(ir,it(2)),cult.reldNp(ir,it(3))]';
    Ni=[demic.reldNi(ir,it(1)),base.reldNi(ir,it(2)),cult.reldNi(ir,it(3))]';
  
    A=ones(3,1);  
    bw=0.8;
    
    
    dcolor=[0.5 0.5 1];
    icolor=[1 0.5 0.5];
    darkgray=ones(1,3)*0.4;
    
    p1a=bar(1:3,A,0.9,'k');
    set(p1a,'FaceColor','none','EdgeColor',darkgray,'LineWidth',2);
    p1=bar(1:3,Qp,bw,'b');
    set(p1,'FaceColor',dcolor);
    p1a=bar(5:7,A,0.9,'k');
    set(p1a,'FaceColor','none','EdgeColor',darkgray,'LineWidth',2);
    p2p=bar(5:7,Tp+Ti,bw,'m');
    set(p2p,'FaceColor',dcolor);
    p2i=bar(5:7,Ti,bw,'m');
    set(p2i,'FaceColor',icolor);
    p1a=bar(9:11,A,0.9,'k');
    set(p1a,'FaceColor','none','EdgeColor',darkgray,'LineWidth',2);
    p3p=bar(9:11,Np+Ni,bw,'m');
    set(p3p,'FaceColor',dcolor);
    p3i=bar(9:11,Ni,bw,'r');
    set(p3i,'FaceColor',icolor);
    set(gca,'Ylim',[-0.2 1.2]);
    set([p1 p2p p2i p3p p3i],'ShowBaseLine','off','EdgeColor','none');
    pos=get(gcf,'Position');
    set(gcf,'Position',pos.*[1 1 1 0.5]);
    title([letters(ir) ' ' num2str(100*pcv(ip)) '%' ]);
    
    fprintf('%s Qp=%d/%d/%d Tp=%d/%d/%d Ti=%d/%d/%d\n',letters(ir),...
        round(Qp*100),round(Tp*100),round(Ti*100));
  %end
  cl_print('name',['clp_spread_mechanism_bar_' letters(ir)],'ext','pdf');
end

figure(29); clf reset; hold on;

ip=10;
for ir=1:nhreg
  it=(pci(ir,ip,:));
  Qp(:,ir)=[demic.reldQp(ir,it(1)),base.reldQp(ir,it(2)),cult.reldQp(ir,it(3))]';
  Tp(:,ir)=[demic.reldTp(ir,it(1)),base.reldTp(ir,it(2)),cult.reldTp(ir,it(3))]';
  Ti(:,ir)=[demic.reldTi(ir,it(1)),base.reldTi(ir,it(2)),cult.reldTi(ir,it(3))]';
  Np(:,ir)=[demic.reldNp(ir,it(1)),base.reldNp(ir,it(2)),cult.reldNp(ir,it(3))]';
  Ni(:,ir)=[demic.reldNi(ir,it(1)),base.reldNi(ir,it(2)),cult.reldNi(ir,it(3))]';
end

plot(Qp','b-');
plot(Tp','g-');
plot(Ti','g--');
plot(Np','r-');
plot(Ni','r--');

return;

cmap=clc_eurolbk(10);
figure(30); clf reset; hold on;
for ir=1:nhreg
  plot(pcv,demic.reldQp(ir,pci(ir,:,1)),'b-','Color',cmap(ir,:));
end
figure(31); clf reset; hold on;
for ir=1:nhreg
  plot(pcv,base.reldQp(ir,pci(ir,:,2)),'b-','Color',cmap(ir,:));
end

figure(32); clf reset; hold on;
for ir=1:nhreg
  plot(pcv,base.reldQp(ir,pci(ir,:,2))./demic.reldQp(ir,pci(ir,:,1)),'b-','Color',cmap(ir,:));
end



