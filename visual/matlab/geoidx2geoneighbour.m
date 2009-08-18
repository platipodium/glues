function [ilonl,ilatu,ilonr,ilatb]=geoidx2geoneighbour(ilon,ilat,cols)
    
cl_register_function();

  ilonl=mod(ilon+cols-2,cols)+1;
  ilonr=mod(ilon,cols)+1;
  ilatu=ilat-1;
  ilatb=ilat+1;
   
return
