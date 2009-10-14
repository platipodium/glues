function [npp,forest,desert]=cl_vecode(temp,prec,gdd0,co2)
% [n,f,d] = VECODE(t,p,g)
% is the matlab implementation of V. Brovkins's VECODE
% dynamical vegetation model
% Input arguments (required) 
%  t temperature (anuual mean, degree C)
%  p prescipitation (annual sum, mm)
%  g growing degree days above zero
%
% [n,f,d] = VECODE(t,p,g,c
% Optional input argument 
%  c carbon dioxide concentration (ppmv)
% 
% Output arguments
%  n net primary production
%  f forest share
% d desert share

% copyright 2009 Carsten Lemmen
% GKSS-Forschungzentrum Geesthacht
% This software is released under GPL

  cl_register_function;
  
  if nargin<3 error('At least three input arguments are required'); end
  if ~exist('co2','var') co2=280; end

  npp=vecode_npp_lieth(temp,prec);
  npp=vecode_co2_enrichment(npp,co2);
  [forest,desert]=currentcycle(temp,prec,gdd0);
return
end

function [forestshare,desertshare]=currentcycle(temp,prec,gdd0)

ACR      = 28.;
ADES     = 0.0011;
ALPHA    = 7000;
BETA     = 0.005;
GAMMA    = 0.00017;
GDD0MIN  = 90.;        % /* decreased by factor 10 from Brovkin */
GDD0MAX  = 180.;       % /* decreased by factor 10 from Brovkin */
FSHAREMAX= 1.0;

  
% This is the SUBROUTINE CCPARAM
% from V. Brovkins VeCODE DGVM

% it calculates parameters of the annual cycle
  
% prec : Annual precipitation [mm]
% gdd0:  growing degree days above zero
% temp:  annual mean temperature 
% co2:   co2 

% Calculate potential trees share %
  

forestshare=temp*0.0;
desertshare=temp*0.0;

gdddiff=gdd0-GDD0MIN;

avefor=prec.*prec.*prec.*prec;
db1=-BETA*gdddiff;
db2=GAMMA*gdddiff;
db3=gdddiff.*gdddiff;
  
vf=find(gdddiff>=0);
forestshare(vf)=(1.0-exp(db1(vf))).*avefor(vf)./(avefor(vf)+ALPHA.*db3(vf).*exp(db2(vf)));

vf=find(forestshare>FSHAREMAX);
forestshare(vf)=FSHAREMAX;
  
% Calculated potential desert share 

% complete deserts when gdd0<100
vd=find(gdd0<100.0)
desertshare(vd)=1.0;

% slow decrease of desert when gdd0>00
vd=find(gdd0>=100.0 & gdd0<GDD0MIN)
desertshare(vd)=(GDD0MIN-gdd0(vd))/(GDD0MIN-100.);

% variable desert faction when gdd0>GDD0MAX
prc=ACR*exp((GAMMA*gdddiff)/2.0);
vm=find(gdd0>=GDD0MAX & prec<prc);
desertshare(vm)=1.0;
foresetshare(vm)=0.0;

db2=(prec-prc)./exp(GAMMA*gdddiff);
vp=find(gdd0>=GDD0MAX & prec>=prc);
desertshare(vp)=1.03/(1.0+ADES.*db2(vp).*db2(vp)-0.03);
desertshare(desertshare<0)=0;

  
 return
end
  




