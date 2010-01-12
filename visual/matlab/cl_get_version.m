function v=cl_get_version
% CL_GET_VERSION gets calling file's version information
%  
% V=CL_GET_VERSION returns calling file's version information 
%   in structure V with members
%   v.file (file name)
%   v.function (function name)
%   v.version (file last modified date)s

cl_register_function;

v.matlab=version;
v.user=[ getenv('USER') '@' getenv('HOST')];
[v.computer,maxsize,v.endian]=computer;
v.os=getenv('OSTYPE');
v.time=datestr(now);
v.pwd=pwd;
v.release=str2num(version('-release'));


progname='cl_get_version.m';
funcname='cl_get_version';

if v.release>13
    
  stack = dbstack(1);
  if length(stack)>0
    callee = stack(1);
    progname=callee.file;
    funcname=callee.name;
  end
else
  stack=dbstack;
  if length(stack)>1
      callee = stack(2);
      progname=callee.file;
      funcname=callee.name;
  end
end
    

d=dir(progname);

v.file=progname;
v.function=funcname;
v.version=d.date;

  v.copy=['(c)' datestr(now,'yyyy') ' ' getenv('USER')];
  
return;
end
