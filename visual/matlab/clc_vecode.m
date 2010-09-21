function [production,share,carbon,p]=clc_vecode(temp,prec,gdd0,co2)
% [prod,share,carbon] = CLC_VECODE(t,p,g)
% is the matlab implementation of V. Brovkins's VECODE
% dynamical vegetation model
% Input arguments (required) 
%  t temperature (anuual mean, degree C)
%  p prescipitation (annual sum, mm)
%  g growing degree days above zero (sum of temperatures above zero)
%
% [prod,share,carbon] = CLC_VECODE(t,p,g,c)
% Optional input argument 
%  c carbon dioxide concentration (ppmv)
% 
% Output arguments
%  prod production variables (nep, npp)
%  share fraction of forest, grass, desert
%  carbon carbon stock in leaves, stems, soil

% Copyright 2009,2010 Carsten Lemmen
% GKSS-Forschungzentrum Geesthacht
% This software is released under GPL

  cl_register_function;
  
  if nargin<3
    warning('Arguments missing','Please provide temp, prec, gdd0 information');
    temp=25;
    prec=8850;
    gdd0=3600; % Year-round 10 degree
  end
  
  if max(gdd0)<361
      warning('Did you provide gdd instead of gdd0? Please double-check your input!');
  end
  
  if ~exist('co2','var') co2=280; end

  p=initpar;
  [production,share,p]=ccparam(temp,prec,gdd0,co2,p);
  p=ccstat(production,share,p);
  [production,share,carbon,p]=climpar(production,share,p);

  return
end

function [production,share,p]=ccparam(temp,prec,gdd0,co2,p)
% Calculationof initial carboncycle parameters

% This is the SUBROUTINE CCPARAM
% from V. Brovkins VeCODE DGVM

% it calculates parameters of the annual cycle
  
% prec : Annual precipitation [mm]
% gdd0:  growing degree days above zero
% temp:  annual mean temperature 
% co2:   co2 
% p parameters

% Calculate potential trees share %
  

forestshare=temp*0.0;
desertshare=temp*0.0;

gdddiff=gdd0-p.GDD0MIN;

avefor=prec.*prec.*prec.*prec;
db1=-p.BETA*gdddiff;
db2=p.GAMMA*gdddiff;
db3=gdddiff.*gdddiff;
  
vf=find(gdddiff>=0);
forestshare(vf)=(1.0-exp(db1(vf))).*avefor(vf)./(avefor(vf) ...
    +p.ALPHA.*db3(vf).*exp(db2(vf)));

vf=find(forestshare>p.FSHAREMAX);
forestshare(vf)=p.FSHAREMAX;
  
% Calculated potential desert share 

% complete deserts when gdd0<100
vd=find(gdd0<100.0);
desertshare(vd)=1.0;

% slow decrease of desert when gdd0>00
vd=find(gdd0>=100.0 & gdd0<p.GDD0MIN)
desertshare(vd)=(p.GDD0MIN-gdd0(vd))/(p.GDD0MIN-100.);

% variable desert faction when gdd0>GDD0MAX
prc=p.ACR*exp((p.GAMMA*gdddiff)/2.0);
vm=find(gdd0>=p.GDD0MAX & prec<prc);
desertshare(vm)=1.0;
foresetshare(vm)=0.0;

db2=(prec-prc)./exp(p.GAMMA*gdddiff);
vp=find(gdd0>=p.GDD0MAX & prec>=prc);
desertshare(vp)=1.03/(1.0+p.ADES.*db2(vp).*db2(vp)-0.03);
desertshare(desertshare<0)=0;

% Lieth's npp
npp=clc_npp(temp,prec);
npp=vecode_co2_enrichment(npp,co2);


% allocation factors and residence time of leaves biomass
p.k1t=p.c1t+p.c2t./(1+p.c3t*npp);
p.k1g=p.c1g+p.c2g./(1+p.c3g*npp);

p.t1t=p.d1t+p.d2t./(1+p.d3t*npp);
p.t1g=p.d1g+p.d2g./(1+p.d3g*npp);

%   residence time of stems and roots biomass
p.t2t=p.e1t+p.e2t./(1+p.e3t*npp);
p.t2g=p.e1g+p.e2g./(1+p.e3g*npp);

%   residence time of fast carbon pool
p.t3t=16*exp(-p.ps5*(temp-p.soilt));
p.t3g=40*exp(-p.ps5*(temp-p.soilt)) ; 

% residence time of slow soil organic matter
p.t4t=900*exp(-p.ps5*(temp-p.soilt));
p.t4g=p.t4t;

%calculation of potential nedleleaves trees ratio
nlshare=(p.t1t-p.t1td)/(p.t1tn-p.t1td);
nlshare(find(nlshare>1))=1.0;
nlshare(find(nlshare<0))=0.0;

share.needle = nlshare;
share.forest = forestshare; 
share.desert = desertshare;
share.grass = 1-share.forest-share.desert;

production.npp=npp;

return;
end

function [production,share,carbon,p]=climpar(production,share,p)
% Function CLIMPAR


% Calculationof annual average LAI
p.laig=p.b1g*p.deng;
p.lait=p.b1t.*(p.dentn*share.needle+p.dentd*(1-share.needle));
lai=p.lait.*share.forest+p.laig.*share.grass

% Calculation of  annual uptake
%if isfield(p,'b1');
%  tempor1=b1+b2+b3+b4;
%else
%  tempor1=0;
%end
b1=p.b1t.*share.forest+p.b1g.*share.grass;
b2=p.b2t.*share.forest+p.b2g.*share.grass;
b3=p.b3t.*share.forest+p.b3g.*share.grass;
b4=p.b4t.*share.forest+p.b4g.*share.grass;
b12=b1+b2;
b34=b3+b4;

%nep=b12+b34-tempor1;

%production.nep=nep;
production.lai=lai;

carbon.leaf=b1;
carbon.stem=b2;
carbon.litter=b3;
carbon.soil=b4;

 return
end

function p=ccstat(production,share,p)
% Calculation of equilibrium storage

npp=production.npp/100;

% leaves
p.b1t=p.k1t.*p.t1t.*npp;
p.b1g=p.k1g.*p.t1g.*npp;

% stems and roots;
p.b2t=(1-p.k1t).*p.t2t.*npp;
p.b2g=(1-p.k1g).*p.t2g.*npp;

% litter
p.b3t=(p.k0t.*p.b1t./p.t1t+p.k2t./p.t2t.*p.b2t).*p.t3t;
p.b3g=(p.k0g.*p.b1g./p.t1g+p.k2g./p.t2g.*p.b2g).*p.t3g;

% mortmass and soil organic matter
p.b4t=(p.k3t./p.t3t.*p.b3t).*p.t4t;
p.b4g=(p.k4g./p.t2g.*p.b2g+p.k3g./p.t3g.*p.b3g).*p.t4g;

return;
end


function p=initpar

p.ACR      = 28.;
p.ADES     = 0.0011;
p.ALPHA    = 7000;
p.BETA     = 0.005;
p.GAMMA    = 0.00017;
p.GDD0MIN  = 900.;       
p.GDD0MAX  = 1800.;      
p.FSHAREMAX= 1.0;

p.c1t=0.046;
p.c2t=0.58;
p.c3t=1.6;
p.c1g=0.069;
p.c2g=0.38;
p.c3g=1.6;
p.d1t=0.22;
p.d2t=7.19;
p.d3t=5.5;
p.d1g=0.6;
p.d2g=0.41;
p.d3g=6.0;
p.e1t=17.9;
p.e2t=167.3;
p.e3t=15.;
p.e1g=0.67;
p.e2g=50.5;
p.e3g=100.;
p.f1t=0.43;
p.f2t=24.3;
p.f3t=13.;
p.f1g=0.34;
p.f2g=17.8;
p.f3g=50.;
p.k2t=1.;
p.k3t=0.017;
p.k0t=0.6;
p.k0g=0.2;
p.k2g=0.55;
p.k4g=0.025;
p.k3g=0.013;
p.t3g=1.;
p.t1tn=4;
p.t1td=1;
p.deng=20;
p.dentd=20;
p.dentn=6;
p.ps5=0.04;
p.soilt=5;

return;
end
  



