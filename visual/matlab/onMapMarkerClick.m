function onMapMarkerClick(gcbo,eventdata,handles)
cl_register_function();

disp(get(gcbo,'Tag'));
ud=get(gcbo,'UserData');
set(ud.TextHandle,'Visible','on');
set(gcbo,'MarkerSize',10);
set(gcbo,'ButtonDownFcn',@offMapMarkerClick);
return;
