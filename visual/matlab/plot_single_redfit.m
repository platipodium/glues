function plot_single_redfit(varargin)
 
cl_register_function();

% Default values
fs=16; no_title=0; no_xticks=0; i=1; period='low'; fid=0;
scenario='o4n2w1';

if (nargin>0)
  i=varargin{1};
  period=varargin{2};
  for iargin=3:nargin
    if strcmp(varargin{iargin},'FontSize') fs=varargin{iargin+1}; iargin=iargin+1; end;
    if strcmp(varargin{iargin},'NoTitle') no_title=1; end;
    if strcmp(varargin{iargin},'NoXTicks') no_xticks=1; end;
    if strcmp(varargin{iargin},'Scenario') scenario=varargin{iargin+1}; iargin=iargin+1; end;
    if strcmp(varargin{iargin},'FileId') fid=varargin{iargin+1}; iargin=iargin+1; end;

  end;
end; 

[dirs,files]=get_files;
dirs.output='~/projects/glues/m/holocene/redfit/data/output';
if length(scenario)>0 dirs.output=fullfile(dirs.output,scenario); end

load('holodata.mat');


file=fullfile(dirs.output,strrep(holodata.Datafile{i},'.dat','_tot.red.mat'));
if ~exist(file,'file')
  fprintf('File %s does not exist, please create it first\n',file);
  return
end;
load(file);
tot=rec;


file=fullfile(dirs.output,strrep(holodata.Datafile{i},'.dat',['_' period '.red.mat']));
if ~exist(file,'file')
  fprintf('File %s does not exist, please create it first\n',file);
  return
end;
[fpe.path fpe.name fpe.ext fpe.version]=fileparts(file);
load(file);

numin=1.0/3250;
numax=1.0/250;
nurange=numax-numin;

bands=[[1/1800.,1/800.];[1/650.,1/450.];[1/380.,1/280.]];

nu=rec.Freq/1000.;
ndata=length(nu);

tot.CriChi2=rec.fcrit.*tot.Gred_th;

titles=['freq','raw','corrected','ar(1)','avg ar(1)','corr fac','80% X2','90% X2','95% X2','99% X2','Cri X2','80% MC','90% MC','95% MC','99% MC'];

colors='bgrcmykbgrcmyk';
styles=['-',':','-.','--'];
symbols='.ox+*s';

inrange=find(nu>=numin & nu<=numax);
if length(inrange)<2; 
  fprintf('Not enough data in range\n');
  return; 
end;
 
if ~all(rec.Gxx_corr(inrange)>0); 
  fprintf('Some data in range are negative\n');
  return; 
end;

gxxmax=max([db(rec.Gxx_corr(inrange)),mean(db(tot.CriChi2))]);
gxxmin=min([db(rec.Gxx_corr(inrange)),max(db(tot.Gred_th(inrange)))]);
if (gxxmax>0) dbymax=1.01*gxxmax; else dbymax=0.99*gxxmax; end;
if (gxxmin>0) dbymin=0.99*gxxmin; else dbymin=1.01*gxxmin; end;
dbyrange=dbymax-dbymin;
if any(isnan([dbymin,dbymax])); 
  fprintf('Some data in range are NaN\n');
  return; 
end;
oneover=repmat('1/',6,1);  

set(gca,'xlim',[numin,numax],'ylim',[dbymin,dbymax]);
if ~no_xticks set(gca,'xtick',reshape(bands',6,1));
else set(gca,'xtick',[]);
end
set(gca,'xticklabel',[oneover num2str(reshape(1./bands',6,1))]);
if ~no_xticks xlabel('Frequency (yr^{-1})'); end
ylabel('Spectral amplitude (dB)');

hold on;
 
bandsignif=[NaN,NaN,NaN];
nutot=tot.Freq/1000.;

plot(nutot,db(tot.Gred_th),'k-','LineWidth',1.5);
rec.Gxx_corr_tot=interp1(nu,rec.Gxx_corr,nutot);


for i=1:3
   valid=find(nutot>=bands(i,1) & nutot <= bands(i,2));
   nvalid=length(valid);
   if (nvalid>0) 
     if max(rec.Gxx_corr_tot(valid)-(tot.CriChi2(valid)))>0 
         bandsignif(i)=5;
     elseif max(rec.Gxx_corr_tot(valid)-(tot.x99Chi2(valid)))>0 
         bandsignif(i)=4;
     elseif max(rec.Gxx_corr_tot(valid)-(tot.x95Chi2(valid)))>0 
         bandsignif(i)=3;
     elseif max(rec.Gxx_corr_tot(valid)-(tot.x90Chi2(valid)))>0 
         bandsignif(i)=2;
     elseif max(rec.Gxx_corr_tot(valid)-(tot.x80Chi2(valid)))>0 bandsignif(i)=0;
     else bandsignif(i)=-1;
    end; 
   end;
 end;

 margin=0.01*dbyrange;
 for i=1:3 
   hdl=patch([bands(i,:),bands(i,2:-1:1)],[dbymin+margin,dbymin+margin,dbymax-margin,dbymax-margin],[1 1 0.8]);
   set(hdl,'EdgeColor','none');
   if (bandsignif(i)==5) set(hdl,'FaceColor',[0.7 1 0.7]); end;
 end;

 plot(nutot,db(tot.Gred_th),'k-','LineWidth',1.5);
 plot(nutot,db(tot.CriChi2),'b-','LineWidth',2.0);
 plot(nutot,db(tot.x90Chi2),'-.','LineWidth',1.0,'Color',[0.5 0.5 0.5]); 
 plot(nutot,db(tot.x95Chi2),'--','LineWidth',1.0,'Color',[0.5 0.5 0.5]); 
 plot(nutot,db(tot.x99Chi2),'-','LineWidth',1.0,'Color',[0.5 0.5 0.5]);


 plot(nutot,db(rec.Gxx_corr_tot),'Color','r','LineWidth',2.5,'LineStyle','-');
 plot(nu,db(rec.Gxx_corr),'Color','r','LineWidth',2.5,'LineStyle','-');
 nuquist=round(1/max(nu));
 nuorder=floor(log(max(nu)*1000)/log(10.));
 nutext=sprintf('f_{nyq}=1/%d yr^{-1}',nuquist);
 critext=sprintf('P_{cri}=%5.2f%',rec.pcrit);
 text(bands(1,1),dbymin+1,sprintf('%s / %s',nutext,critext),'FontSize',fs,'VerticalAlignment','bottom');
 text(bands(3,2),dbymax-1,period,'VerticalAlignment','top','FontSize',fs+1);
 text(numax,dbymin+0.5*(dbymax-dbymin),scenario,'HorizontalAlignment','right','FontSize',fs-2);
 
 hold off;

 if (fid>0) fprintf(fid,'"%s" %4d %d %4d %3d %1d %4d %3d %1d %4d %3d %1d \n',fpe.name,ndata,nuquist,round(1./bands(1,:)),bandsignif(1),round(1./bands(2,:)),bandsignif(2),round(1./bands(3,:)),bandsignif(3)); end;
 
return;
