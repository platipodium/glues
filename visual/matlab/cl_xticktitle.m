function cl_xticktitle(str)

cl_register_function;

if ~exist('str','var') str='ka BP'; end
if isnumeric(str) str=num2str(str); end

xtl=get(gca,'XTickLabel');
[n,m]=size(xtl);
l=length(str);
if l<m l=m; end

if strcmp(get(gca,'XDir'),'reverse')
 pos=1;
else
 pos=n;
end

xt=repmat(' ',n,l);
if pos>1 for i=1:pos-1
  off=ceil((l-m)/2);
  xt(i,1+off:m+off)=xtl(i,:);
end
  else for  i=2:n
  off=ceil((l-m)/2);
  xt(i,1+off:m+off)=xtl(i,:);      
      end
end

l=length(str);
if l<m
  off=ceil((m-l)/2);
else
  off=0;
end
xt(pos,1+off:l+off)=str;
set(gca,'XTickLabel',xt);

return;
end