function get_map_coords

cl_register_function();

figure(1); clf reset;
m_proj('miller')
m_coast;
%m_grid('box','fancy');

%set(gcf,'UserData',[]);
%set(gcf,'windowbuttondownfcn',@track);

set(gca,'UserData',[]);
set(gca,'buttondownfcn',@track);
pause
ud=get(gca,'UserData');
n=length(ud);
nl=10;
line=zeros(nl,2)-999;
line(1:n,:)=ud;
string='[';
for i=1:nl
  string=[string sprintf('%4d %4d;',round(line(i,:))) ];
end
string=[string ']' ];
fprintf('%s',string);
close(1);

return

function track(axnum,varargins)

temp=get(gca,'currentpoint');
[lo,la]=m_xy2ll(temp(1),temp(3));
%points=[points, temp];
%disp(temp);
disp([lo,la]);
set(gca,'UserData',[get(gca,'UserData') ; [lo la]]);

return
