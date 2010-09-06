function [gdd,gdd0,gdd5]=clc_gdd(temp,yearlen)

monthlen=[31 28 31 30 31 30 31 31 30 31 30 31];

s=size(temp);
im=find(s==12);
if ~isempty(im)
 s(im)=1;
 gdd=sum((temp>0).*repmat(monthlen,s),im);  
 gdd0=sum((temp>0).*temp.*repmat(monthlen,s),im);  
 gdd5=sum((temp>5).*temp.*repmat(monthlen,s),im);  
else
 gdd=sum(temp>0);
 gdd0=sum((temp>0).*temp);
 gdd5=sum((temp>5).*temp);
end

return
end