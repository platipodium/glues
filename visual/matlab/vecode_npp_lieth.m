function [npp,npp_p,npp_t,lp,lt]=vecode_npp_lieth(temp,prec)
% prec : Annual precipitation [mm]
% temp:  annual mean temperature 
% calculation of NPP g/m2/a, Lieth's formula
% also known as Miami model (Lieth 1972)

cl_register_function();

  NPPMAX   = 1460;    
  V1       = 0.000664;
  V2       = 0.119;
  V3       = 3.7248;

  npp_p=(1.-exp(-V1*prec))*NPPMAX;
  npp_t=1./(1.+V3*exp(-V2*temp))*NPPMAX;
  
  npp=npp_p;
  ip=find(npp_t>=npp_p);
  it=find(npp_t<npp_p);
  npp(it)=npp_t(it);
  
  % find climate sensitivities:
  lt=zeros(length(npp),1);
  lp=lt;
  
  lt(it)=(NPPMAX*V2*V3*exp(-V2*temp(it)))./(1+V3*exp(-V2*temp(it))).^2;
  lp(ip)=NPPMAX*V1*exp(-V1*prec(ip));
  
  return
end

