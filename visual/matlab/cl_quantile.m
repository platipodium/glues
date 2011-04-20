function [xq,n]=cl_quantile(x,q,dim)
% xq=cl_quantile(x,q,dim)
% where xq returns the quantiles q of distribution x along dimension dim

% Carsten Lemmen, 2011-04-19

if ~exist('dim','var') || isempty(dim) dim=1; end
if ~exist('q','var') || isempty(q) q=[.25 .75]; end

if ~exist('x','var')
  error('Please provide an input array');
end
  
xs=sort(x,dim,'ascend');
pdfx=cumsum(xs)./sum(xs);

n=length(q);
for i=1:n
   xq(i)=xs(max(find(pdfx<=q(i))));
end

return
end