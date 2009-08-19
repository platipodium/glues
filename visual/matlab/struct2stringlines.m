function strline=struct2stringlines(struct)

cl_register_function();

if ~exist('struct','var')
      struct=get_version;
end

if ~isstruct(struct)
    error('You must provide a struct');
end

cell=struct2cell(struct);

strline=[ char(cell{1}) ];
for i=2:length(cell)
    strline = [strline ' '  char(cell{i})];
end


return
end
