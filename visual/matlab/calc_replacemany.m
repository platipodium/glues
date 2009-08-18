function calc_replacemany(year,ratio,dyear,extra)
%extra='eleven'
cl_register_function();

if ~exist('year','var') year=5.5; end
if ~exist('ratio','var') ratio=33; end
if ~exist('dyear','var') dyear=0.5; end
if ~exist('m_proj') addpath('~/matlab/m_map'); end;

yrtext=sprintf('_%.1f_%.1f',year,dyear);

if exist('extra','var') yrtext=[yrtext '_' extra]; end


[dirs,files]=get_files;
files.rm=['replacemany' yrtext '_' num2str(ratio)];

if ~exist([files.rm '.tsv'],'file')
  warning('Required file %s does not exist\n', [files.rm '.tsv']);
  return
end


rmdata=read_textcsv([files.rm '.tsv'],' ','"');

% gupp denotes leave-outs in upper part => represents lower
% glow denotes leave-outs in lower part => represents upper
rmdata.gdiff=rmdata.glow-rmdata.gupp;
rmdata.k=1./rmdata.Freq;
rmsite=rmdata.Site;
nrep=length(rmdata.gdiff);

ending=['_tot.dat_' num2str(ratio) '_var'];
%Alkenone_MarmaraSea_tot.dat_40_var; 552;  3.14;   NaN;   NaN;1;1;0

for i=1:nrep
    rmdata.Site{i}=strrep(rmdata.Site{i},ending,'');
    rmdata.Site{i}=strrep(rmdata.Site{i},'_tot.dat.red','');
    rmdata.Site{i}=strrep(rmdata.Site{i},['.dat_' num2str(ratio) '_var'],'');
    rmdata.Site{i}=strrep(rmdata.Site{i},['_var_condensed'],'');
    rmdata.Site{i}=strrep(rmdata.Site{i},['_condensed'],'');
end;

holodata=get_holodata('proxydescription.csv');

%valid=[1:138];
%valid=[1:5,7:14,17:23,26:29,31:35,37:43,45:47,49,51:56,...
%       58:60,63:65,67:69,71,73:77,80:87,89,90,92:96,98:100,...
%       102:104,107:109,111:118,121:138];


lon=holodata.Longitude;
lat=holodata.Latitude;
No_sort=holodata.No_sort;

nsites=length(holodata.Datafile);

for isite=1:nsites
  [dummy,sitename,dummy,dummy]=fileparts(holodata.Datafile{isite});   
  sname{isite}=sitename;
end

for irep=1:nrep 
    isite=strmatch(rmdata.Site{irep},sname,'exact') ;
    if (isite>0)
          rmdata.lat(irep)=lat(isite(1));
          rmdata.lon(irep)=lon(isite(1));
          rmdata.No_sort(irep)=No_sort(isite(1));
      else 
          fprintf('Line %d: site %s not found\n',irep,rmdata.Site{irep});
          %a=rmdata.Site{irep};
          %isite=strmatch(a,sname);
          %sname{isite}
          rmdata.lat(irep)=NaN;
          rmdata.lon(irep)=NaN;
          rmdata.No_sort(irep)=NaN;
          
     end
  %fprintf(' %d %d %d\n',ilow,iupp,itot);
end


for irep=1:nrep  

    rmdata.istot(irep)=0;
    rmdata.islow(irep)=0;
    rmdata.isupp(irep)=0;
   
  if isnan(rmdata.gdiff(irep))
      if (rmdata.No_sort(irep)<500)
       fprintf('No period information for site %s (%d)\n',rmdata.Site{irep},rmdata.No_sort(irep));
      end
      rmdata.islow(irep)=NaN;
   rmdata.isupp(irep)=NaN;
  end
    
   if (rmdata.Freq(irep)==0) continue; end

       reference=min(rmdata.ar95(irep),rmdata.arcrit(irep));
  rmdata.istot(irep)=rmdata.gtot(irep) >= reference;
  rmdata.islow(irep)=rmdata.gupp(irep) >= reference;
  rmdata.isupp(irep)=rmdata.glow(irep) >= reference;
 if isnan(rmdata.gdiff(irep))
   rmdata.islow(irep)=NaN;
   rmdata.isupp(irep)=NaN;
  end
end

save([files.rm '.mat'],'rmdata');

fid=fopen([files.rm '.csv'],'w');
for i=1:nrep
    fprintf(fid,'%s;%4d;%6.2f;%6.2f;%6.2f;%1d;%1d;%1d;%3d\n',rmdata.Site{i},...
       rmdata.Freq(i),rmdata.gdiff(i),rmdata.lon(i),rmdata.lat(i),...
       rmdata.istot(i),rmdata.isupp(i),rmdata.islow(i),rmdata.No_sort(i));
end
fclose(fid);

end


% call this function for paper-relevant data
% years=5.5;  dyear=0.5; ratio=33;
% extras={'eleven','normalised','deevented','detrended','d0.12'}; ne=5;
% for e=1:ne, calc_replacemany(years,ratio,dyear,extras{e}); end;

% call this function for paper-relevant data
%years=[2.0:0.2:9.0];ny=length(years); dyear=2.0;ratio=33;
%for y=1:ny calc_replacemany(years(y),ratio,dyear); end;


