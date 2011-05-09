function cl_bcad(ax)
% Corrects a negative years to absolute years

cl_register_function;
if ~exist('ax','var') ax=gca; end

xt=get(ax,'XTick');
i0=find(xt==0);
if ~isempty(i0)
  cl_year_one(ax);
end

ineg=find(xt<0);
if ~isempty(ineg);
  xtl=get(ax,'XTickLabel');
  len=length(xtl(ineg(1),:));
  for i=1:length(ineg)
    xtl(ineg(i),:)=strrep(xtl(ineg(i),:),'-',' ');
  end
  for i=1:length(xtl)
    if all(xtl(i,:)==' ') continue; end
    while(xtl(i,end)==' ') xtl(i,2:end)=xtl(i,1:end-1); xtl(i,1)=' '; end
  end
end

xtl=strtrim(xtl);

set(ax,'XTick',xt,'XTickLabel',xtl);

end