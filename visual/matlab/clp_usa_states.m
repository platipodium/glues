function clp_usa_states(varargin)

arguments = {...
  {'lonlim',[-125 -60]},...
  {'latlim',[28 52]},...
  {'seacolor',0.7*ones(1,3)},...
  {'landcolor',.8*ones(1,3)}
};

cl_register_function;

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); end


fid = fopen('data/states.csv');
d = textscan(fid, '%s%s%s%f%f','Delimiter',';');
fclose(fid);


fid = fopen('/h/lemmen/projects/glues/tex/2010/saa/card/cultures.tsv');
cultures = textscan(fid,'%s','Delimiter',';');
fclose(fid);


figure(1);
clf reset;

clp_basemap('lonlim',lonlim,'latlim',latlim);

a1=gca;
p1=m_text(d{5},d{4},d{1});
title('States of the USA');
plot_multi_format(gcf,'usa_states');

delete(p1);


np=length(cultures{1});
for c=1:np

  if exist('p2','var') 
    if ishandle(p2) 
      delete(p2); 
    end
  end
     
  if exist('a2','var') 
    if ishandle(a2) 
      delete(a2); 
    end
  end
  
  period=strrep(char(cultures{1}(c)),' ','%20');


  file=['/h/lemmen/projects/glues/tex/2010/saa/card/table_' period '.csv'];
  if ~exist(file,'file') continue; end
  
  fid = fopen(file);
  site = textscan(fid, '%s%s%s%s%s%f%f','Delimiter',';','HeaderLines',1,'CommentStyle','#');
  fclose(fid);

nsite=length(site{1});
d{6}=d{5}*0;
for i=1:nsite
  j=strmatch(site{1}(i),d{1});  
    
  if isempty(j)
      fprintf('%s not found\n',char(site{1}(i)));
      continue; 
  end;
  %fprintf('%d %s %d %s\n',i,char(site{3}(i)),j,char(d{1}(j)));
    site{8}(i)=d{5}(j);
    site{9}(i)=d{4}(j);
    d{6}(j)=d{6}(j)+1;
end

  pos=find(d{6}>0);
  if isempty(pos) continue; end

  age=site{6};
  
  q=cl_quantile(age,[0 0.05 0.5 0.95 1]);
  qr=round(q);
  age=age(age>q(2) & age < q(4));
  
  mi=min(age);
  ma=max(age);
  
  tt=sprintf(' stage (%d %d %d)',qr(2),qr(3),qr(4));
  
  title([num2str(sum(d{6}(pos))) ' dates assigned to ' strrep(period,'%20',' ') tt ]);
  p2=m_text(d{5}(pos),d{4}(pos),num2str(d{6}(pos)));
  
  if (ma>mi)
    
    p=get(a1,'position');
    a2=axes('position',[ p(3)-0.05 p(2)+0.17 p(1)+0.04 p(2)+0.02])
    set(a2,'FontSize',8);
    edges=mi+[-0.1:1:11.1]*(ma-mi)/10.0;
  
    [n,bin]=histc(age,edges);
    p3=bar(edges,n,'histc');
    set(a2,'color',[0.9 0.9 0.9],'XAxisLocation','top','Xlim',[min(edges),max(edges)],'Ylim',[0 max(n)+1]);

    %xtick=round(edges([2,5,8,11])/100.0)*100;
    xtick=round(edges([2,5,8,11]));
    set(a2,'XTick',xtick);
    set(a2,'XTickLabel',num2str(xtick'));
  end
  
  plot_multi_format(gcf,['stage_' strrep(period,'%20','_')]);

end
end

