% from show_map_event by Kai Wirtz

cl_register_function();

function plot_map_events(varargin)

if nargin==0 fignum=1; else fignum=varargin{1}; end;

cols=720;
rows=360;
figure(fignum);
%set(gcf,'Position',[50 500 2.5*cols 2.5*ceil(rows*0.9)]);
MaxEvSer = 8;
offs0=0;

[dir,files]=get_files;
[regionvector,regionlength]=get_regionvector;
n=length(regionlength);
holodata=get_holodata(fullfile('/',dir.proxies,'proxysites.csv')); 

sites2analyze=find(holodata.No_sort<500);

map = zeros(rows*cols,1)+n;
fname=['reg_events_' num2str(n)];

 for i=1+offs0:n  %n-1 last region combines islands
    map(regionvector(i,1:regionlength(i)))=1+i;
 end;
 map = reshape(map,cols,rows)';
jetnew=prism(n);
jetnew(n,:) = [1 1 1];
jetnew(1,:) = [0 0 0];
colormap(jetnew);

imagesc(map(ceil(rows*0.02):ceil(rows*0.9),:),[1 n]);
 for i=1+offs0:n
   ad=regionvector(i,1:regionlength(i));
   y=ceil(ad./cols);
   x=mod(ad,cols);
   y=round((ad-x)./cols)+1;
   xm(i)=mean(x); ym(i)=mean(y);
   rrad(i)=0.5*m_lldist(0.5*[max(x) min(x)],[90-0.5*max(y) 90-0.5*min(y)])*1E-3; 
   text(mean(x)-ceil(rows*0.02),mean(y),num2str(i-1));
 end;
 set(gca,'YTick',[],'XTick',[],'Visible','on');

hold on

lon =360+2*holodata.Longitude ;
lat= 180-2*holodata.Latitude;
lonlat=720*ceil(180-2*holodata.Latitude)+360+ceil(2*holodata.Longitude);

found=zeros(n,1);
EventInReg=zeros(n,10)-1;
RadInReg=zeros(n,10)-1;
for s = sites2analyze
  plot(lon(s),lat(s),'k+','MarkerSize',16);
  for i=1+offs0:-n
   if(ismember(lonlat(s),regionvector(i,1:regionlength(i))))
     %fprintf('site %d(%s) in region %d\n',s,holodata.Plotname{s},i-1);
     found(i)=found(i)+1;
     EventInReg(i,found(i))=s;
     RadInReg(i,found(i))=0;
   end;
 end
end;
radcrit=2500;

for(i=offs0+1:n) % groupid-1
  for s = sites2analyze
    rad(s)=m_lldist(0.5*[xm(i),lon(s)],90-0.5*[ym(i),lat(s)])*1E-3; % distance of proxy site from center
  end;
  [rads ind]=sort(rad); 	% sort distances
  inm=find(rads-rrad(i)<radcrit);	% find nearest proxy sites within critical distance
  if inm
    inm_max=length(inm);
    if(inm_max>MaxEvSer-found(i))
       fprintf('\tregion %d omitt radia',i);
       rads(MaxEvSer+1: inm_max);
       inm_max=MaxEvSer-found(i);
       inm=inm(1:inm_max);
    end;
        
    EventInReg(i,found(i)+(1:inm_max))=ind(inm);
    RadInReg(i,found(i)+(1:inm_max))=max(0,rads(inm)-rrad(i));
    found(i)=found(i)+inm_max;
    fprintf('region %d add %d sites %d(%s) \n',i,inm_max,ind(inm(1)),holodata.Plotname{ind(inm(1))});  
    fprintf('region %d add %d sites %d(%s) \n',i,inm_max,ind(inm(inm_max)),holodata.Plotname{ind(inm(inm_max))});  
  else
      fprintf('  region %d (%1.1f %1.1f): no records found dist=%1.1f(%d)\n',i,xm(i),ym(i),rads(1),ind(1));  

  end;
end;  

for(i=offs0+1:-n) % groupid-1
  if(found(i)==0)
    ll=regionvector(i,ceil(0.5*regionlength(i)));
    fprintf('\t region %d (%d:%d) lacks\n',i-1,ceil(ll/720),mod(ll,720));
   end;
end; 
 
EventInReg(1,MaxEvSer)=-1;

save([dir.setup '/EventInReg.mat'],'EventInReg','RadInReg','found'); 
fid=fopen([dir.setup '/EventInReg.dat'],'w');
fprintf(fid,'%d %d %d %d %d %d %d %d\n',EventInReg(:,1:MaxEvSer)')
fclose(fid);
fid=fopen([dir.setup '/EventInRad.dat'],'w');
fprintf(fid,'%d %d %d %d %d %d %d %d\n',round(RadInReg(:,1:MaxEvSer)'))
fclose(fid);

plot_multi_format(gcf,fullfile(dir.setup,fname));
%fnme=[fname '.fig']
%print(fnme);

