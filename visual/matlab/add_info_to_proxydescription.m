function calc_replacemany(year,ratio)


cl_register_function();



if ~exist('year','var') year=6000; end
if ~exist('ratio','var') ratio=33; end
if ~exist('m_proj') addpath('~/matlab/m_map'); end;

[dirs,files]=get_files;
files.rm=['replacemany_' num2str(year) '_' num2str(ratio)];

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
end;

holodata=get_holodata(fullfile(dirs.proxies,'proxydescription.csv'));

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
          fprintf('%d %s\n',irep,rmdata.Site{irep});
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
  reference=min(rmdata.ar95(irep),rmdata.arcrit(irep));
  rmdata.istot(irep)=rmdata.gtot(irep) >= reference;
  rmdata.islow(irep)=rmdata.gupp(irep) >= reference;
  rmdata.isupp(irep)=rmdata.glow(irep) >= reference;
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
