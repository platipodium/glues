function clp_single_redfit(varargin)
 
cl_register_function();

arguments = {...
  {'freqlim',[1/5000. 2.0]},...
  {'lim',[-inf,inf]},...
  {'figoffset',0},...
  {'sce',''},...
  {'file','data/indus_varves_red.mat'},...
  {'nocolor',0},...
  {'notitle',0},...
  {'period','low'},...
  {'FontSize',16},...
  {'xticks',7} 
};

cl_register_function;

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); end

if ~exist(file,'file')
  fprintf('File %s does not exist, please create it first\n',file);
  return
end;
[fpe.path fpe.name fpe.ext]=fileparts(file);
load(file);


if isinf(freqlim(1)) freqlim(1)=min(freq); end
if isinf(freqlim(2)) freqlim(2)=max(freq); end

numax=min([freqlim(2),max(freq)]);
numin=max([freqlim(1),min(freq)]);

nurange=numax-numin;

bands=[[1/1800.,1/800.];[1/650.,1/450.];[1/380.,1/280.]];

nu=freq;
ndata=length(nu);

colors='bgrcmykbgrcmyk';
styles=['-',':','-.','--'];
symbols='.ox+*s';

inrange=find(nu>=numin & nu<=numax);
if length(inrange)<2; 
  fprintf('Not enough data in range\n');
  return; 
end;
 
if ~all(Gxx_corr(inrange)>0); 
  fprintf('Some data in range are negative\n');
  return; 
end;

if isinf(lim(1)) lim(1)=min(db(Gxx)); end
if isinf(lim(2)) lim(2)=max(db(Gxx)); end

dbymin=max([lim(1),min(db(Gxx))]); 
dbymax=min([lim(2),max(db(Gxx))]); 

dbyrange=dbymax-dbymin;
if any(isnan([dbymin,dbymax])); 
  fprintf('Some data in range are NaN\n');
  return; 
end;
oneover=repmat('1/',6,1);  

clf reset;

set(gca,'xlim',[numin,numax],'ylim',[dbymin,dbymax]);
%if ~no_xticks set(gca,'xtick',reshape(bands',6,1));
%else set(gca,'xtick',[]);
%end

nxt=xticks;
xt=linspace(numin,numax,nxt);
oneover='1/';
space=size(num2str(round(1./xt')),2);
xtl=repmat(' ',nxt,space+2);
for i=1:nxt
 xtli=[oneover  num2str(round(1./xt(i)))];
 xtl(i,1:length(xtli))=xtli;
end

set(gca,'Xtick',xt);
set(gca,'xticklabel',xtl);
 xlabel('Frequency (yr^{-1})');
 ylabel('Spectral amplitude (dB)');

hold on;
 

 plot(freq,db(Gred_theoretical),'k-','LineWidth',1.5);
 plot(freq,db(Gred_theoretical.*param.scalecrit),'b-','LineWidth',2.0);
 plot(freq,db(Gred_theoretical.*param.scale99),'-.','LineWidth',1.0,'Color',[0.5 0.5 0.5]); 
 plot(freq,db(Gred_theoretical.*param.scale95),'--','LineWidth',1.0,'Color',[0.5 0.5 0.5]); 
 plot(freq,db(Gred_theoretical.*param.scale90),'-','LineWidth',1.0,'Color',[0.5 0.5 0.5]);


 plot(freq,db(Gxx_corr),'Color','r','LineWidth',2.5,'LineStyle','-');
 nuquist=round(1/max(nu));
 nuorder=floor(log(max(nu)*1000)/log(10.));
 nutext=sprintf('f_{nyq}=1/%d yr^{-1}',nuquist);
 critext=sprintf('P_{cri}=%5.2f%',param.critical);
 
 hold off;


return;
