function [p,lonlim,latlim]=clp_relief(varargin)

cl_register_function;

% typically called after clp_basemap
% Default values
lonlim = [-10 42];
latlim = [31 57];

% todo: if no figure exists, create one with a call to clp_basemap

if ~exist('filename','var') 
  filename='data/lbk_background.png'; 
end

if ~exist(filename,'file')
  warning('File %s does not exist, please recreate',filename);
  return
end

a=imread(filename);
[nla,nlo,ncol]=size(a);
 
lo0=lonlim(1); lo1=lonlim(2);
dlo=lo1-lo0;
la0=latlim(1); la1=latlim(2);
dla=la1-la0;

gla=[la1:-dla./(nla-1):la0];
glo=[lo0+dlo/2./nlo:dlo./nlo:lo1-dlo/2./nlo];

 
% m_proj('equidistant','lat',[latmin,latmax],'lon',[lonmin,lonmax]);
[llx,lly]=m_ll2xy(lonlim(1),latlim(1),'clip','off');
[urx,ury]=m_ll2xy(lonlim(2),latlim(2),'clip','off');
 
p=image([llx,urx],[ury,lly],a(:,:,1:3));

return
end