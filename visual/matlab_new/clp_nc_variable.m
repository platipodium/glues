function [retdata,basename]=clp_nc_variable(varargin)
% [retdata,basename]=clp_nc_variable(varargin)
% This function plots a variable from a netcdf file
% give arguments as key value pairs, i.e. ('file','myfile.nc')
% see source code for full list of available options

% Carsten Lemmen <carsten.lemmen@hzg.de>
% License: GNU Public License v3

arguments = {...
  {'latlim',[-inf inf]},...
  {'lonlim',[-inf inf]},...
  {'timelim',[-5000,-5000]},...
  {'lim',[-inf,inf]},...
  {'reg','lbk'},...
  {'discrete',0},...
  {'variables','farming'},...
  {'scale','absolute'},...
  {'figoffset',0},...
  {'timeunit','BP'},...
  {'timestep',1},...
  {'marble',0},...
  {'seacolor',0.7*ones(1,3)},...
  {'landcolor',.8*ones(1,3)},...
  {'transparency',0},...
  {'snapyear',1000},...
  {'movie',1},...
  {'mult',1},...
  {'div',1},...
  {'sub',0},...
  {'add',0},...
  {'file','../../euroclim_0.4.nc'},...%  {'retdata',NaN},...
  {'basename','variable'},...
  {'nocolor',0},...
  {'ncol',19},...
  {'nogrid',0},...
  {'nocbar',0},...
  {'nocoast',0},...
  {'noaxes',0},...
  {'nohatch',1},...
  {'axiscolor',[.5 .5 .5]},...
  {'notitle',0},...
  {'threshold',NaN},...
  {'flip',0},...
  {'showtime',1},...
  {'showstat',1},...
  {'showvalue',0},...
  {'scenario',''},...
  {'noprint',0}...
  {'cmap',NaN},...
  {'rpath','regionpath_685'},...
};

cl_register_function;

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length 
  eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); 
end

[d,f]=get_files;

% Choose 'emea' or 'China' or 'World'
if all(isinf([lonlim latlim]))
  if ischar(reg)
    %[ireg,nreg,loli,lali]=find_region_numbers(reg);
     [ireg,nreg,loli,lali]=cl_select_regions('reg',reg,'rpath',rpath);
  else
    ireg=reg;
    nreg=length(ireg);
  end
else
  if ischar(reg)
    %[ireg,nreg,loli,lali]=find_region_numbers('lat',latlim,'lon',lonlim);
    [ireg,nreg,loli,lali]=cl_select_regions('lat',latlim,'lon',lonlim,'rpath',rpath);
    reg=ireg;
  else
     ireg=reg;
     nreg=length(ireg);
  end
end

if ~exist(file,'file')
    error('File does not exist');
end
ncid=netcdf.open(file,'NC_NOWRITE');

varname='region'; varid=netcdf.inqVarID(ncid,varname);
region=netcdf.getVar(ncid,varid);

[ndim nvar natt udimid] = netcdf.inq(ncid); 
for varid=0:nvar-1
  [varname,xtype,dimids,natts]=netcdf.inqVar(ncid,varid);
  if strcmp(varname,'lat') lat=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'lon') lon=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'latitude') latit=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'longitude') lonit=netcdf.getVar(ncid,varid); end
end

if exist('lat','var') 
  if length(lat)~=length(region)
    if exist('latit','var') lat=latit; end
  end
else
  if exist('latit','var') lat=latit; end
end

if exist('lon','var') 
  if length(lon)~=length(region)
    if exist('lonit','var') lon=lonit; end
  end
else
  if exist('lonit','var') lon=lonit; end
end


varname=variables; varid=netcdf.inqVarID(ncid,varname);
try
    description=netcdf.getAtt(ncid,varid,'description');
catch
    description=varname;
end



try
    units=netcdf.getAtt(ncid,varid,'units');
catch
    units='';
end
data=double(netcdf.getVar(ncid,varid));
[varname,xtype,dimids,natt] = netcdf.inqVar(ncid,varid);

if isnumeric(mult) data=data .* mult;
else
  factor=double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,mult)));    
  data = data .* repmat(factor,size(data)./size(factor));
end

if isnumeric(div) data=data ./ div; 
else
  factor=double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,div)));    
  data = data ./ repmat(factor,size(data)./size(factor));
end

if isnumeric(sub) data=data - sub; 
else
  factor=double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,sub)));    
  data = data - repmat(factor,size(data)./size(factor));
end

if isnumeric(add) data=data + add; 
else
  factor=double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,add)));    
  data = data +  repmat(factor,size(data)./size(factor));
end


if length(timelim)==1 timelim(2)=timelim(1); end

% Find time dimension
ntime=1;
if numel(data)>length(data)
  idimid=find(udimid==dimids);
  tid=netcdf.inqVarID(ncid,netcdf.inqDim(ncid,udimid));
  time=netcdf.getVar(ncid,tid);
  timeunit=netcdf.getAtt(ncid,tid,'units');
  time=cl_time2yearAD(time,timeunit);
  itime=find(time>=timelim(1) & time<=timelim(2));
  if isempty(itime)
      error('Not data in specified time range')
  end
  itime=itime([1:timestep:length(itime)]);
  
  alltime=time;
  time=time(itime);
  ntime=length(time);
end
if ntime==1 && ~exist('itime','var') itime=1; end

netcdf.close(ncid);

%ireg=find(lat>=latlim(1) & lat<=latlim(2) & lon>=lonlim(1) & lon<=lonlim(2));
%nreg=length(ireg);
region=region(ireg);
lat=lat(ireg);
lon=lon(ireg);

switch (varname)
    case 'region_neighbour', data=(data==0) ;
    otherwise ;
end

if ~exist('time','var') 
  warning('No time dimension'); 
  ntime=1;
  showtime=0;
  itime=1;
end

if isfinite(threshold)
  %% plot timing maps
  ntime=1;
  timing=(data>=threshold)*1.0;
  izero=find(timing==0);
  timing(izero)=NaN;
  timing=timing.*repmat(alltime',size(data,1),1);
  timing(isnan(timing))=inf;
  timing=min(timing,[],2);
  data=timing;
  data(isinf(data))=NaN;
  description=['Timing of '  varname];
  minmax=timelim;
  if isinf(minmax(1)) minmax(1)=min(data); end
  if isinf(minmax(2)) minmax(2)=max(data); end
  itime=1;
  units='Calendar year';
else 
  minmax=double([min(min(min(data(ireg,itime)))),max(max(max(data(ireg,itime))))]);
  ilim=find(isfinite(lim));
  minmax(ilim)=lim(ilim);
end


%seacolor=0.7*ones(1,3);
%landcolor=0.8*ones(1,3);  

if isnan(cmap)
  if transparency && isnan(threshold)
  %colmap=[linspace(0,0,n)' linspace(0.1,0.6,n)' linspace(1,0.5,n)']
    colmap=hsv2rgb([linspace(0,0,ncol)' linspace(0.1,0.5,ncol)' linspace(1,0.8,ncol)']);
    colmap(:,3)=colmap(:,1);
    colmap(:,1)=colmap(:,2);
  else
    colmap=jet(ncol);
  end

  if nocolor 
    cmap=flipud(gray(ncol));
    if ~transparency flip=1; end
  end

  cmap=colormap(colmap);
else
    eval(['cmap=' cmap '(ncol);']);
    cmap=colormap(cmap);
    colmap=cmap;
end
if (flip==1) colmap=flipud(colmap); end

  
rlon=lon;
rlat=lat;

iinf=isinf(lonlim);
if exist('loli','var') lonlim(iinf)=loli(iinf); else lonlim=[-180 180]; end
iinf=isinf(latlim);
if exist('lali','var') latlim(iinf)=lali(iinf); else latlim=[-60 80]; end

if isinf(lonlim(1)) lonlim(1)=-180; end
if isinf(lonlim(2)) lonlim(2)= 180; end
if isinf(latlim(1)) latlim(1)=-60; end
if isinf(latlim(2)) latlim(2)=80; end

  % plot map
  figid=max([1,varid+figoffset]);
  figure(figid); 
  clf reset;
  cmap=colormap(colmap);
  set(figid,'DoubleBuffer','on');    
  set(figid,'PaperType','A4');
  hold on;
  if (marble<2) pb=clp_basemap('lon',lonlim,'lat',latlim,'nogrid',nogrid,'nocoast',nocoast,'axiscolor',axiscolor); end
  if (marble==1)
    pm=clp_marble('lon',lonlim,'lat',latlim);
    if pm>0 alpha(pm,marble); end
  elseif (marble==2)
    pb=clp_basemap('lon',lonlim,'lat',latlim,'nogrid',nogrid,'nocoast',1,'noaxes',noaxes,'axiscolor',axiscolor);
    pm=clp_relief;
  elseif (marble==3)
    pb=clp_basemap('lon',lonlim,'lat',latlim,'nogrid',nogrid,'nocoast',1,'noaxes',noaxes,'axiscolor',axiscolor);
    pm=clp_naturalearth('lon',lonlim,'lat',latlim);
  else
    if ~nocoast 
      m_coast('patch',landcolor);
      set(gca,'Tag','m_coast'); end
      % only needed for empty (non-marble background) to get rid of lakes
      c=get(gca,'Children');
      ipatch=find(strcmp(get(c(:),'Type'),'patch'));
      npatch=length(ipatch);
      if npatch>0
        if npatch==1  iwhite=find(sum(get(c(ipatch),'FaceColor'),2)==3); 
        else
          iwhite=[];
          try
            iwhite=find(sum(cell2mat(get(c(ipatch),'FaceColor')),2)==3);
          catch
            for k=1:npatch
               if (sum(get(c(ipatch(k)),'FaceColor'))==3) iwhite=[iwhite;k]; end
            end
          end
        end
        if ~isempty(iwhite) 
          set(c(ipatch(iwhite)),'FaceColor',seacolor);
          set(c(ipatch(iwhite)),'Tag','Lake');
        end
      end
    
  
  end
  
set(gca,'YColor',axiscolor,'XColor',axiscolor);

% DELETE: ncol=length(colormap);

  %% Invisible plotting of all regions
  %[hp,loli,lali,lon,lat]=clp_regionpath('lat',latlim,'lon',lonlim,'draw','patch','col',landcolor,'reg',reg);
  %m_grid('backcolor','none','color','k');
  %axes;
  
%  [hp,loli,lali,lon,lat]=clp_regionpath('lat',latlim,'lon',lonlim,'draw','patch','col',landcolor,'rpath',rpath);  
   [hp,loli,lali,lon,lat]=clp_regionpath('reg',reg,'draw','patch','col',landcolor,'rpath',rpath);  
  ival=find(hp>0);
  if transparency alpha(hp(ival),0); end
  

  
  if ~nohatch
         for isty=1:ceil(ncol/3) hatchstyles{isty}='cross'; end
        for isty=ceil(ncol/3)+1:ceil(ncol*2/3) hatchstyles{isty}='single'; end
        for isty=ceil(ncol*2/3)+1:ncol hatchstyles{isty}='speckle'; end
        ihspeckle=strmatch('speckle',hatchstyles);
        ihsingle=strmatch('single',hatchstyles);
        ihcross=strmatch('cross',hatchstyles);
        hatchdensities=zeros(ncol,1);
        hatchdensities(ihspeckle)=linspace(.2,1,length(ihspeckle));
        hatchdensities(ihsingle)=linspace(3,6,length(ihsingle));
        hatchdensities(ihcross)=linspace(1,5,length(ihcross));
        hatchwidths=zeros(ncol,1);
        hatchwidths(ihspeckle)=linspace(1,9,length(ihspeckle));
        hatchwidths(ihsingle)=linspace(1,9,length(ihsingle))/10;
        hatchwidths(ihcross)=linspace(1,9,length(ihcross))/10;
       
  end

  
  
%% Time loop

for it=1:ntime
  
  if minmax(2)>minmax(1)
    resvar=round(((data(ireg,itime(it))-minmax(1)))./(minmax(2)-minmax(1))*(length(cmap)-1))+1;
  else
    resvar=data(ireg,itime(it))*0+1;
    ncol=1;
    cmap=repmat(seacolor/2.0,2,1);
    colormap(cmap);
  end
    
  resvar(resvar>length(cmap))=length(cmap);

  if (discrete>0)
    [b,i,j]=unique(resvar);
    resvar=resvar(i);
    rlat=lat(i);
    rlon=lon(i);
  end
  
  titletext=description;
  if (ntime>1) titletext=[titletext ' ' num2str(time(it))]; end
  if ~notitle ht=title(titletext,'interpreter','none','color',axiscolor); end

 
  %m_plot(lon,lat,'rs','MarkerSize',0.1);
  for i=1:ncol
    if i==1 j=find(resvar<=1);
    elseif i==ncol j=find(resvar>=ncol);
    else j=find(resvar==i);
    end
    
    if isempty(j) continue; end
    for ij=1:length(j)
      h=hp(j(ij));
      if isnan(h) || h==0 continue; end
      ud.data=squeeze(data(ireg(j(ij)),itime));
      if exist('time','var') ud.time=time; else ud.time=[]; end
      set(h,'ButtonDownFcn',@onclick,'UserData',ud);
      greyval=0.15+0.35*sqrt(i./ncol);
      if transparency
        %if i./ncol>0.33 greyval=0.33; elseif (i./ncol)>0.66 greyval=0.5; else greyval=0; end
        if ~isnan(threshold) greyval=0.33; end
        alpha(h,greyval); 
      end
      if ~nocolor
        set(h,'FaceColor',cmap(i,:),'tag','region_patch','EdgeColor',cmap(min(ncol,i+1),:),'EdgeAlpha',greyval)
      elseif nohatch
        greyval=repmat(0.5,1,3);
        if i<ncol/3 continue; end
        density=7-4.0*i/ncol;
        xp=get(h,'XData'); yp=get(h,'YData');
        [xlon,xlat]=m_xy2ll(xp,yp);
        if (exist('hh','var') && j(ij)<=length(hh) && (hh(j(ij))>0)) delete hh(j(ij)); end
        hh(j(ij))=m_hatch(xlon,xlat,'cross',30,density,'color',greyval,'linewidth',0.1);
        set(h,'EdgeColor',greyval,'EdgeAlpha',0.3,'FaceAlpha',0)
      else % hatched part
         greyval=repmat(0.5,1,3);
        density=7-4.0*i/ncol;
        xp=get(h,'XData'); yp=get(h,'YData');
        [xlon,xlat]=m_xy2ll(xp,yp);
        if (exist('hh','var') && j(ij)<=length(hh) && (hh(j(ij))>0)) delete hh(j(ij)); end
        %hh(j(ij))=
        m_hatch(xlon,xlat,hatchstyles{i},30,hatchdensities(i),'color',greyval,'linewidth',.5);
        set(h,'EdgeColor',greyval,'EdgeAlpha',1,'FaceAlpha',1)
      end
    end
  end
  
  if showvalue
    for ir=1:nreg
        if isnan(data(ireg(ir),itime(it))) continue; end
        if lon(ir)<lonlim(1) || lon(ir)>lonlim(2) || lat(ir)<latlim(1) || ...
            lat(ir)>latlim(2) continue; end
       m_text(double(lon(ir)),double(lat(ir)),num2str(data(ireg(ir),itime(it))),...
           'HorizontalAlignment','center','VerticalAlignment','middle','tag','showvalue');
    end
  end
  
  if (it==1)
    fdir=fullfile(d.plot,'variable',varname);
    if ~exist('fdir','dir') system(['mkdir -p ' fdir]); end
  end
  if (it==1) && ~nocbar% && ~transparency
    cb=colorbar('FontSize',15,'tag','colorbar');
    %colormap(cmap);
    if length(units)>0 title(cb,units); end
    if minmax(2)>minmax(1)
      yt=get(cb,'YTick');
      ytlim=get(cb,'YLim');
      yr=minmax(2)-minmax(1);
      ytl=scale_precision((yt-ytlim(1))*yr/(ytlim(2)-ytlim(1))+minmax(1),4)';
      set(cb,'YTickLabel',num2str(ytl));
    else
      cb=colorbar('FontSize',15,'Ytick',minmax(1));
    end
  end
  
  if ~nohatch % Manipulate color bar
    ax=gca;
    cb=cl_colorbar('value',0:ncol);
    yt=get(cb,'YTick');
    ytlim=get(cb,'YLim');
    yr=minmax(2)-minmax(1);
    ytl=scale_precision((yt-ytlim(1))*yr/(ytlim(2)-ytlim(1))+minmax(1),4)';
    set(cb,'YTickLabel',num2str(ytl));
    cbp=get(cb,'Children');
    cbp=findobj(cbp,'-property','FaceColor');
    greyval=repmat(0.5,1,3);

    for i=1:ncol
      cbpp=findobj(cbp,'FaceColor',cmap(i,:));
      set(cbpp,'FaceColor','none');
      axes(cb);
      hatchdata={hatchstyles,hatchdensities};
      set(cb,'UserData',hatchdata);
      for icbp=1:length(cbpp)
         xp=get(cbpp(icbp),'XData');
         yp=get(cbpp(icbp),'YData');
         xp=xp([4 1:3]);
         yp=yp([2:4 1]);
         cl_hatch(xp,yp,hatchstyles{ncol+1-i},30,hatchdensities(ncol+1-i),'color',greyval,'linewidth',.5);
      end
    end
    axes(ax);
  end
    
  set(gcf,'UserData',cl_get_version);
 
  if (exist('time','var') && showtime>0)
    if time(it)<0 bcad='BC'; else bcad='AD'; end
    if time(it)==0 time(it)=1; end
    m_text(lonlim(1)+0.02*(lonlim(2)-lonlim(1)),latlim(1)+0.02*(latlim(2)-latlim(1)),...
        [num2str(abs(time(it))) ' ' bcad],...
        'VerticalAlignment','bottom','HorizontalAlignment','left','background','w','tag','Time')
  end
 %% 
 
 
  if (showstat>0)
      isfin=isfinite(data(ireg,itime(it)));
      s(1)=min(data(ireg(isfin),itime(it)));
      s(3)=max(data(ireg(isfin),itime(it)));
      s(2)=median(data(ireg(isfin),itime(it)));
      s=scale_precision(s,3);
      statstr=sprintf('%.2f:%.2f:%.2f',s);
      m_text(lonlim(2)-0.02*(lonlim(2)-lonlim(1)),latlim(1)+0.02*(latlim(2)-latlim(1)),statstr,...
        'VerticalAlignment','bottom','HorizontalAlignment','right','background','w','tag','Statistics')  
  end
  
  obj=findall(gcf,'-property','FontSize');
  set(obj,'FontSize',15);
  obj=findall(gcf,'tag','Statistics');
  set(obj,'FontSize',10);
  
  %%
  if ischar(reg) bname=[varname '_' reg '_' num2str(nreg)];
  else bname=[varname '_'  num2str(nreg)];
  end
  if length(scenario)>0 bname=[bname '_' scenario]; end
  
  if exist('time','var') if (ntime>1 || showtime>0) bname = [bname '_' num2str(time(it))]; end; end
  if ~noprint cl_print('name',fullfile(fdir,bname),'ext',{'pdf','png'}); end
  %pause(0.05);
end

if nargout>0 
  retdata.value=data(ireg,itime); 
  retdata.lat=lat';
  retdata.lon=lon';
  retdata.handle=hp';
  retdata.region=ireg;
  if exist('time','var') retdata.time=time;end
end
if nargout>1 basename=fullfile(fdir,bname); end

end



function offclick(gcbo,eventdata,handles)
ud=get(gcbo,'UserData');
set(gcbo,'ButtonDownFcn',@onclick);
set(gcbo,'EdgeColor',ud.EdgeColor);
set(gcbo,'LineWidth',ud.lineWidth);
return;
end

function onclick(gcbo,eventdata,handles)
ud=get(gcbo,'UserData');
ud.figure=gcf;
ud.EdgeColor=get(gcbo,'EdgeColor');
ud.LineWidth=get(gcbo,'LineWidth');
set(gcbo,'EdgeColor','y');
set(gcbo,'LineWidth',4);

auxfig=findobj('-tag','Auxiliary figure');
if isempty(auxfig) figure(); else figure(auxfig); end
set(auxfig,'tag','Auxiliary figure');
plot(ud.time,ud.data,'k-');
figure(ud.figure);
return;
end






