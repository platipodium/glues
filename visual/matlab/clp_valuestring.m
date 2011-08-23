function svalue=clp_valuestring(value)

if iscell(value) || isstruct(value)
    svalue=value;
elseif ischar(value);
    svalue=['''' value ''''];
elseif isnumeric(value)
  if (length(value) == 1);
    svalue=num2str(value);
  else
    if size(value,2)==1 value=transpose(value); end
    if size(value,1)==1 svalue=['[' num2str(value) ']']; 
    else
      svalue=['[[' num2str(value(1,:)) ']' ];
      for i=2:size(value,1)
        svalue=[ svalue ';[' num2str(value(i,:)) ']' ];
      end
      svalue=[svalue ']'];      
    end
  end
end

if ~exist('svalue','var')
  error('Problem in clp_valuestring, output argument not assigned');
end

return
end