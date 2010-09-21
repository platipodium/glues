function [npp,npp_p,npp_t,lp,lt]=clc_npp(temp,prec)
%CL_NPP_LIETH calculates net primary production from temp and precip
%   NPP=CL_NPP_LIETH(TEMP,PREC) calculates the net primary production (npp)
%   based on the limitation model of Lieth (1972).
%
%   [NPP,NPP_P,NPP_T,LP,LT]=NPP=CL_NPP_LIETH(TEMP,PREC) returns in addition
%   the functional dependence of npp on precip, on temperature and the 
%   associated climate sensitivities
%  
%   Input parameter 
%     prec : Annual precipitation [mm]
%     temp:  annual mean temperature 
%
%   Output 
%     npp,npp_p,npp_l in g/m2/a
%     lp,lt
%   Note
%   Lieth's formula is also know as the Miami model.  The code is 
%   based on the implementation by V. Brovkin (1997) in VECODE


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

