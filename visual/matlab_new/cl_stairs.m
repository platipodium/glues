function [xout,yout]=cl_stairs(x,y)
  
  n=length(x);
  if n<1 [xout,yout]=[Nan Nan]; return; end
  if n<2 [xout,yout]=[x,y]; return; end
  
  xout=[x(1) ; reshape(repmat(x(2:end-1),1,2)',2*(n-2),1); x(end)]
  yout=reshape(repmat(y(1:n-1),1,2)',2*(n-1),1);

  return;
end
