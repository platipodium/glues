function hdl=clp_bar(xpos,ypos,height,varargin)

arguments = {...
  {'width',0.02},...
  {'barcolor','b'}
};

cl_register_function;

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length 
  eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); 
end

npos=length(xpos);
if length(ypos)==1 ypos=repmat(ypos,npos,1); end
if length(height)==1 height=repmat(height,npos,1); end

barwidth=width;
for i=1:npos
  xx=xpos(i)+[-barwidth/2 barwidth/2 barwidth/2 -barwidth/2 -barwidth/2];
  yy=ypos(i)+[0 0 height(i) height(i) 0];
  hdl(i)=patch(xx,yy,barcolor);
  
end