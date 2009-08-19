function cl_register_function
% CL_REGISTER_FUNCTION registers function in journal file
%  default journal file name is 'cl_journal.txt'
%  each calling function's file name is written in a single line to 
%  the journal file.

% Author Carsten Lemmen <carsten.lemmen@gkss.de>
% Date 2009-05-09


journal_fname='cl_journal.txt';

if ~exist(journal_fname,'file')
  stack_offset=0;
else
  stack_offset=1;
end

fid=fopen(journal_fname','a');
%if str2num(version('-release'))>13
%  stack=dbstack(stack_offset);
%else
  stack=dbstack;
  %end

for i=1+stack_offset:length(stack)
  if isfield(stack,'file')
    fprintf(fid,'%s\n',stack(i).file);
  elseif isfield(stack,'name')
    fprintf(fid,'%s\n',stack(i).name);
  else
    warning('This version of dbstack does not have file/name field');
  end
end

fclose(fid);
return
end


