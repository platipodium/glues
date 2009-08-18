function offMapMarkerClick(gcbo,eventdata,handles)
cl_register_function();

%disp(get(gcbo,'Tag'));
ud=get(gcbo,'UserData');
set(ud.TextHandle,'Visible','off');
set(gcbo,'MarkerSize',ud.MarkerSize);
set(gcbo,'ButtonDownFcn',@onMapMarkerClick);
return;
