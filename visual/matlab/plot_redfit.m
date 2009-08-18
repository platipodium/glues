 function plot_redfit(varargin)
 
cl_register_function();

 % Default values for variable argument list
 mask='*.red';
 scenario='o4n4w1';
 indir=fullfile('~/projects/glues/m/holocene/redfit/data/output',scenario);
 pausetime=0;
 
 if nargin>0
    if (rem(nargin,2)~=0) error('Wrong number of variable arguments'); end;
    for iargin=1:nargin
      if strcmp(varargin{iargin},'mask') mask=varargin{iargin+1}; end;
      if strcmp(varargin{iargin},'pause') pausetime=varargin{iargin+1}; end;
      if strcmp(varargin{iargin},'dir') indir=varargin{iargin+1}; end;
end;
 end;  
   
 
files=(dir(fullfile(indir,mask)));
dirs=get_files;

if ~exist('clplot') figure(1); clf; clplot=gcf; end;
if ~exist('files') files=['taylordome_d18O_tot.dat.red']; end;

%files=files,ymin=ymin,ymax=ymax,psflag=psflag,numin=numin,numax=numax,$
%plotfile=plotfile,append=append,logfile=logfile

numin=1.0/3250;
numax=1.0/250;
%if not keyword_set(logfile) then logfile='redfit_test.log'
%if not keyword_set(files) then files=['test.red']

% Sanity checks
nfiles=length(files);
if nfiles<0 
  fprintf('No files found %s. Aborted.',files);
  return;
end;

% 3x2 matrix
bands=[[1/1800.,1/800.];[1/650.,1/450.];[1/380.,1/280.]];

fid=fopen(['redfit_' scenario '.tsv'],'w');
fprintf(fid,'"dataset" "npoints"  "nuquist" "band11" "band12" "sig1" "band21" "band22" "sig2" "band31" "band32" "sig3"\n');

% Implementation
for ifile=1:nfiles
%ifile=1;
  clf;
  file=fullfile(indir,files(ifile).name);
  [fpe.path fpe.name fpe.ext fpe.version]=fileparts(file);
  [dummy fpe.name dummy2 dummy3]=fileparts(fpe.name);

  %fprintf('%d %s...\n',ifile,fpe.name);
  
  matfile=fullfile(fpe.path,[fpe.name '.red.mat']);
  if exist(matfile,'file') load(matfile);
  else 
      rec=read_textcsv(file,' ','"');
      line=grep(file,'Thomson');
      pcrit=str2num(line(49:end));
      line=grep(file,'corresponding');
      fcrit=str2num(line(54:end));
      rec.pcrit=pcrit;
      rec.fcrit=fcrit;
      rec.scenario=scenario;
      save(matfile,'rec');
  end

  
  nu=rec.Freq/1000.;
  ndata=length(nu);

 %  1: Freq     = frequency
 %  2: Gxx = spectrum of input data
 %  3: Gxx_corr = bias-corrected spectrum of input data
 %  4: Gred_th = theoretical AR(1) spectrum
 %  5: <Gred> = average spectrum of Nsim AR(1) time series (uncorrected)
 %  6: CorrFac = Gxx / Gxx_corr
 %  7: 80%-Chi2 = 80-% false-alarm level (Chi^2)
 %  8: 90%-Chi2 = 90-% false-alarm level (Chi^2)
 %  9: 95%-Chi2 = 95-% false-alarm level (Chi^2)
 % 10: 99%-Chi2 = 99-% false-alarm level (Chi^2)
 
 rec.CriChi2=rec.fcrit.*rec.Gred_th;
 
  titles=['freq','raw','corrected','ar(1)','avg ar(1)','corr fac','80% X2','90% X2','95% X2','99% X2','80% MC','90% MC','95% MC','99% MC'];

 %  linestyles=make_array(14,value=0B)
 % linestyles[6:9]=[1,0,3,4]
 %linestyles[10:13]=[1,0,3,4]

 colors='bgrcmykbgrcmyk';
 styles=['-',':','-.','--'];
 symbols='.ox+*s';

 if ~exist('numin') numin=min(nu); end;
 if ~exist('numax') numax=max(nu); end;
 nurange=numax-numin;

 inrange=find(nu>=numin & nu<=numax);
 if length(inrange)<2; continue ; end;
 
  %y=data(2:14,:);
  if ~all(rec.Gxx_corr(inrange)>0); continue; end;
  gxxmax=max([db(rec.Gxx_corr(inrange)),min(db(rec.CriChi2(inrange)))]);
  gxxmin=min([db(rec.Gxx_corr(inrange)),max(db(rec.Gred_th(inrange)))]);
  if (gxxmax>0) dbymax=1.01*gxxmax; else dbymax=0.99*gxxmax; end;
  if (gxxmin>0) dbymin=0.99*gxxmin; else dbymin=1.01*gxxmin; end;
  dbyrange=dbymax-dbymin;
  if any(isnan([dbymin,dbymax])); continue; end;

  oneover=repmat('1/',6,1);  
  
  set(gcf,'name','Redfit spectrum','color',[1 1 1],'units','centimeter');
  set(gca,'xlim',[numin,numax],'ylim',[dbymin,dbymax]);
  set(gca,'xtick',reshape(bands',6,1));
  set(gca,'xticklabel',[oneover num2str(reshape(1./bands',6,1))]);
  set(gcf,'Position',[2 15 16 6]);
  xlabel('Frequency (yr^{-1})');
  ylabel('Spectral amplitude (dB)');
  %title(strrep(fpe.name,'_','\_'));
  hold on;
 
  bandsignif=[NaN,NaN,NaN];

  for i=1:3
   valid=find(nu>=bands(i,1) & nu <= bands(i,2));
   nvalid=length(valid);
   if (nvalid>0) 
     if max(rec.Gxx_corr(valid)-(rec.CriChi2(valid)))>0 
         %hdl=patch([bands(i,:),bands(i,2:-1:1)],2+[dbymin,dbymin,dbymin+0.1*dbyrange,dbymin+0.1*dbyrange],[1 0 0]);
         bandsignif(i)=5;
     elseif max(rec.Gxx_corr(valid)-(rec.x99Chi2(valid)))>0 
         %hdl=patch([bands(i,:),bands(i,2:-1:1)],2+[dbymin,dbymin,dbymin+0.1*dbyrange,dbymin+0.1*dbyrange],[0.7 0 0]);
         bandsignif(i)=4;
     elseif max(rec.Gxx_corr(valid)-(rec.x95Chi2(valid)))>0 
         %hdl=patch([bands(i,:),bands(i,2:-1:1)],2+[dbymin,dbymin,dbymin+0.06*dbyrange,dbymin+0.06*dbyrange],[1 0.3 0.3]);
         bandsignif(i)=3;
     elseif max(rec.Gxx_corr(valid)-(rec.x90Chi2(valid)))>0 
         %hdl=patch([bands(i,:),bands(i,2:-1:1)],2+[dbymin,dbymin,dbymin+0.03*dbyrange,dbymin+0.03*dbyrange],[1 0.7 0.7]);
         bandsignif(i)=2;
     elseif max(rec.Gxx_corr(valid)-(rec.x80Chi2(valid)))>0 bandsignif(i)=0;
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

  plot(nu,db(rec.Gred_th),'k-','LineWidth',1.5);
  plot(nu,db(rec.CriChi2),'b-','LineWidth',2.0);
  plot(nu,db(rec.Gxx_corr),'Color','r','LineWidth',2.5,'LineStyle','-');
  
  nuquist=round(1/max(nu));
  fprintf('%s %4d %d %4d %3d %1d %4d %3d %1d %4d %3d %1d \n',fpe.name,ndata,nuquist,round(1./bands(1,:)),bandsignif(1),round(1./bands(2,:)),bandsignif(2),round(1./bands(3,:)),bandsignif(3));
  fprintf(fid,'"%s" %4d %d %4d %3d %1d %4d %3d %1d %4d %3d %1d \n',fpe.name,ndata,nuquist,round(1./bands(1,:)),bandsignif(1),round(1./bands(2,:)),bandsignif(2),round(1./bands(3,:)),bandsignif(3));
  
  nuorder=floor(log(max(nu)*1000)/log(10.));
  %  nutext=eval(['sprintf(''%s %' num2str(nuorder) '.1f %s%d %s'',''f_{nyq}='',max(nu)*1000,''kyr^{-1} (=1/'',nuquist,''yr^{-1})'')']);
  nutext=sprintf('f_{nyq}=1/%d yr^{-1}, p_{crit}=%5.2f',nuquist,rec.pcrit);
  
  %text(bands(1,1),dbymin+0.2*dbyrange,sprintf('%s %4.1f %s','f_{nyq}=',max(nu)*1000,'/kyr'));
  text(bands(1,1),dbymin+3*margin,nutext);
  hdl=text(bands(3,2),dbymax-3*margin,strrep(fpe.name,'_','\_'));
  set(hdl,'FontSize',16,'HorizontalAlignment','right','VerticalAlignment','top');

%  plot(nu,db(rec.x90Chi2),'Color',[0.9 0.9 0.9],'LineStyle','--');
%  plot(nu,db(rec.x95Chi2),'Color',[0.8 0.8 0.8],'LineStyle','--');
%  plot(nu,db(rec.x99Chi2),'Color',[0.7 0.7 0.7],'LineStyle','--');
%  plot(nu,db(rec.CriChi2),'Color',[0.5 0.5 0.9],'LineStyle','-'); 
  hold off;
  
  plot_multi_format(gcf,fullfile(dirs.plot,['redfit_' fpe.name])); 
end;
fclose(fid);

return;
