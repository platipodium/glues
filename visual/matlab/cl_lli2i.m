function [index,ilat,ilon]=cl_lli2i(ilat,ilon,cols,rows)
  
cl_register_function();

if ~exist('cols','var') cols=720; end;
if ~exist('rows','var') rows=360; end;

i=find(ilat>rows);
ilat(i)=2*rows-ilat(i);
ilon(i)=ilon(i)+cols/2;

i=find(ilat<1);
ilat(i)=1-ilat(i);
ilon(i)=ilon(i)+cols/2-1;

i=find(ilon<1);
ilon(i)=ilon+cols;
i=find(ilon>cols);
ilon(i)=ilon-cols;

index=(ilat-1)*cols+ilon;
  
return

