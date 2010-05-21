function cl_year_one(ax)

cl_register_function;
% Corrects a zero year on an x axis to 1 AD
if ~exist('ax','var') ax=gca; end

xt=get(ax,'XTick');
i0=find(xt==0);
if ~isempty(i0)
  xtl=get(ax,'XTickLabel');
  len=length(xtl(i0,:));
  xtl(i0,1:len)=' ';
  if len<4 xtl(i0,1)='1';
  else xtl(i0,1:4)='1 AD';
  end
  xt(i0)=1;
  set(gca,'XTick',xt,'XTickLabel',xtl);
end

end