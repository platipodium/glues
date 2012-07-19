function sarray=cl_reorder(array,order,dim)

if ~exist('dim','var') dim=1; end

if length(order)~=size(array,dim)
  error('Dimension mismatch');
end

s=size(array);
n=length(s);
if dim>n
  error('Requested dimension does not exist.');
end

if n==1
  sarray=array(order);
elseif n==2
  switch(dim)
    case 1,sarray=array(order,:);
    case 2, sarray=array(:,order);
  end
elseif n==3
  switch(dim)
    case 1, sarray=array(order,:,:);
    case 2, sarray=array(:,order,:);
    case 3, sarray=array(:,:,order);
  end
elseif n==4
  switch(dim)
    case 1, sarray=array(order,:,:,:);
    case 2, sarray=array(:,order,:,:);
    case 3, sarray=array(:,:,order,:);
    case 4, sarray=array(:,:,:,order);
  end
else
  error('Not implemented yet');
end

return;
end