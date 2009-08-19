function data=read_hyde_asc(filename)

cl_register_function;

if ~exist('filename','var')
  filename='/h/koedata01/data/model/hyde/crop5000BC.asc';
end

if ~exist(filename,'file')
   warning ('File %s does not exist\n',filename);
end


[p,f,e,v]=fileparts(filename);
matfilename=[f '.mat'];

f=strrep(f,'_','');
l=length(f);
varname=f(1:4);
period=f(end-1:end);
time=str2num(f(5:end-2));

fid=fopen(filename,'r');

if fid<1
    return;
end

nl=0;
while (1)
line=fgetl(fid);
[tok,rem] = strtok(line);
if ~isempty(str2num(tok)) break; end
nl=nl+1;
expression=sprintf('%s = %s;',tok,rem);
eval(expression);
end

frewind(fid);
data=textscan(fid,'%f','HeaderLines',nl);
fclose(fid);

d=reshape(data{:},ncols,nrows);
d(d<0)=NaN;

expression=sprintf('%s = d;',varname);
eval(expression);

if str2num(version('-release'))>13
  vexpr='''-v6'',';
else
  vexpr='';;
 end
 

expression=sprintf('save(%smatfilename,''%s'',''time'');',vexpr,varname);
eval(expression);

end