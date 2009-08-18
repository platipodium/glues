function hdls=plot_map_markers(lon,lat,data,thresh,offset,description,varargin)

cl_register_function();

if ~exist('data','var')
    lon=(rand(30,1)-0.5)*360;
    lat=(rand(30,1)-0.5)*180;
    data=(rand(30,1)-0.5)*3;
    thresh=1.0;
    offset=3.0;
    description=repmat({'test'},30,1);
    m_proj('mollweide');
    m_coast;
end;

pos=find(data>thresh);
neg=find(data<-thresh);
zer=find(abs(data)<=thresh);

n=length(lat);
hdls=zeros(n,1);

msize=offset+abs(data);
msize(zer)=offset;
 
for i=pos, a=msize(i); hdls(i)=m_plot(lon(i),lat(i),'ro','MarkerSize',offset,'MarkerFaceColor',[0.7 0 0],'Color',[0.7 0 0]); end;
for i=neg, a=msize(i); hdls(i)=m_plot(lon(i),lat(i),'bo','MarkerSize',offset,'MarkerFaceColor','b'); end;
for i=zer, hdls(i)=m_plot(lon(i),lat(i),'ko','MarkerSize',offset,'MarkerFaceColor','k'); end;

for i=1:n
  h=hdls(i);
  if h<1 continue; end
  set(h,'Tag',description{i});
  set(h,'ButtonDownFcn',@onclick);
  ht=m_text(lon(i)+0.2,lat(i)+0.2,description{i},'Visible','off','Interpreter','None','Color',get(h,'Color'));
  ud=get(h,'UserData');
  ud.MarkerSize=get(h,'MarkerSize');
  ud.TextHandle=ht;
  set(h,'UserData',ud);
end

return

function offclick(gcbo,eventdata,handles)
%disp(get(gcbo,'Tag'));
ud=get(gcbo,'UserData');
set(ud.TextHandle,'Visible','off');
%set(gcbo,'MarkerSize',ud.MarkerSize);
set(gcbo,'ButtonDownFcn',@onclick);
return;

function onclick(gcbo,eventdata,handles)
disp(get(gcbo,'Tag'));
ud=get(gcbo,'UserData');
set(ud.TextHandle,'Visible','on');
%set(gcbo,'MarkerSize',10);
set(gcbo,'ButtonDownFcn',@offclick);
return;
