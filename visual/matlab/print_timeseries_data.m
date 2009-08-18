function print_timeseries_data(varargin)
cl_register_function();

%\{}

%if ~exist('m_proj') addpath('~/matlab/m_map'); end
%if nargin==0 fignum=1; else fignum=varargin{1}; end

[dirs,files]=get_files;

holodata=get_holodata(fullfile(dirs.proxies,'proxysites.csv')); 
lon=holodata.Longitude;
lat=holodata.Latitude;
holosite={};
nholo=length(lon); 
for i=1:nholo
    [dummy hsitename dummy1 dummy2]=fileparts(char(holodata.Datafile(i))); 
    holosite=cat(1,holosite,{hsitename});
end
    
if ~exist('ts.mat','file')
    error('ts.mat does not exist');
    return
end

load('ts'); 
nfiles=length(ts);

for ifile=1:nfiles
  this=ts(ifile);
  site=strrep(this.sitename,'_tot','');
  iholo=0;
  for j=1:nholo 
      if strcmp(site,char(holosite(j))) 
        iholo=j; 
        break; 
      end
  end
  
  fprintf('%3d %3d %.1f--%.1f %.1f %.1f %.2f %.2f %s\t',ifile,...
      iholo,min(this.time),max(this.time),this.lowspan,this.uppspan,wevents(ifile,:),this.sitename);
  if iholo fprintf('%3d %3d %.2f %.2f %s\t%s\t%s',holodata.No(iholo),holodata.No_sort(iholo),lon(iholo),lat(iholo),...
          char(holodata.Proxy(iholo)),char(holodata.Plotname(iholo)),char(holodata.Source(iholo))); end
  fprintf('\n');       
end

return
