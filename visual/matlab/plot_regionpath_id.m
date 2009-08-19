function phdls=plot_regionpath_id(lon,lat,id,dislocation)

cl_register_function();

if ~exist('lon','var') | ~exist('lat','var') | ~exist('id','var')
  error('Mandatory arguments (lon,lat,id).');
end

% Default dislocation
if ~exist('dislocation','var') dislocation=0.01; end;

nlon=length(lon);
nlat=length(lat);
nid =length(id);

if nlon>1 & nlat==1
  lat=repmat(lat,nlon,1);
  if nid==1 id=repmat(id,nlon,1); 
  elseif nid~=nlon 
    error('Input arguments must be of same size or of size 1')
  end
  nid=nlon;
elseif nlat>1 & nlon==1
  lon=repmat(lon,nlat,1);
  if nid==1 id=repmat(id,nlat,1); 
  elseif nid~=nlat
    error('Input arguments must be of same size or of size 1')
  end
  nid=nlat;
end


if ~ishold 
  clf reset;
  latlim=[min(lat)-1,max(lat)+1];
  lonlim=[min(lon)-1,max(lon)+1];
  m_proj('miller','lon',lonlim,'lat',latlim);
  m_grid;
  m_coast;
  hold on;
end;
  
[xt,yt]=m_ll2xy(lon,lat);
[xt,yt]=dislocate_slightly(xt,yt,0.01);
[lo,la]=m_xy2ll(xt,yt);

for i=1:nid
  phdls(i)=m_text(lo(i),la(i),num2str(id(i)),'HorizontalAlignment','center');
end

return

end
