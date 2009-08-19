function vecode(TATB,PRCB,GDD0B,PA)

%               VECODE - DYNAMIC GLOBAL VEGETATION MODEL 
%
%  Purpose: Computation of vegetation cover (trees/grass/desert fractions),
%           NPP, LAI, biomass, soil carbon storage with annual time step
%
%  Description:
%
%  Brovkin, V.,  A. Ganopolski, W. von Bloh, A. Bondeau,
%  M. Claussen, W. Cramer, V. Petoukhov, S. Rahmstorf, and Yu. Svirezhev,  
%  VEgetation COntinuous DEscription Model (VECODE):  Technical Report,
%  in preparation. 

%  References: 
%  
%  Brovkin V., Bendtsen J., Claussen M., Ganopolski A., Kubatzki C., 
%  Petoukhov V., Andreev A., Carbon cycle, vegetation and climate dynamics
%  in the Holocene: Experiments with the CLIMBER-2 model, Global
%  Biogeochemical Cycles, in press
%  
%  Brovkin, V., A. Ganopolski, and Yu. Svirezhev, 1997. A continuous 
%  climate-vegetation classification for use in climate-biosphere studies. 
%  Ecological Modelling, 101, pp. 251-261.

% Translated into Matlab by Carsten Lemmen May 2009

cl_register_function;

% Default CO2 mixing ration
if nargin<3
    warning('Please provide temp, prec, gdd0 information');
    TATB(1,1)=10;
    PRCB(1,1)=650;
    GDD0B(1,1)=3600;
    PA=370;
end
if ~exist('PA','var') PA=280.0; end

%-----------------------------------
% From file declar.inc
global IT  % number of latitudes
global NS  % number of longitudes

[NS,IT]=size(TATB);


%-----------------------------------
% From file bio.inc
% in common block /BIODAT/

global a bet gamm fmax npp nppmax v1 v2 v3
global c1t c2t c3t c1g c2g c3g
global d1t d2t d3t d1g d2g d3g
global e1t e2t e3t e1g e2g e3g
global f1t f2t f3t f1g f2g f3g
global k1t k2t k3t k1g k2g k3g
global t1t t2t t3t t4t t1g t2g t3g t4g
global ps1 ps2 ps3 ps4 ps5 soilt
global forshare_st t1tn t1td desshare_st nlshare_st
global deng dentd dentn
global ave_t ave_pr ave_pr05 desmin desmax
global ades acr k0t k0g k4g

% Added by Carsten Lemmen
global gdd0_min gdd0_max
global gdd0 npp ave_t ave_pr co2
global lat lon KVEG INI_STEP



% input data: annual mean temperature in degr. Celc. - ave_t
%             annual mean precipitation, mm/year - ave_pr
%             growing degree days above 0 degr. Celcius - gdd0
%             CO2 concentration in the atmosphere, ppm - co2
%             KVEG - control parameter (1 - equilibrium model, 2 - dynamic model)
%
% output data: st(i,j) - trees fraction in cell i,j
%              sg(i,j) - grass fraction 
%              sd(i,j) - desert fraction
%              snlt(i,j) - needle leaved trees fraction in total trees
%                          st(i,j)+sg(i,j)+sd(i,j)=1, 0<= snlt(i,j)<= 1
%              alai(i,j) - annual maximum of total leaf area index, m2/m2
%              anpp(i,j) -  annual NPP, kgC/m2/yr
%              anup(i,j) - annual NEP (land carbon uptake), kgC/m2/yr
%              b1(i,j) - total green (leaves) biomass, kgC/m2
%              b2(i,j) - total structural (stem, roots) biomass, kgC/m2  
%              b3(i,j) - total fast soil carbon storage,  kgC/m2
%              b4(i,j) - total slow soil carbon storage,  kgC/m2
%              b12(i,j) - total biomass, kgC/m2
%              b34(i,j) - total soil carbon, kgC/m2
%
% internal vars: b1t(i,j) - green biomass, kgC/m2, trees  
%              b2t(i,j) - structural biomass, kgC/m2, trees  
%              b3t(i,j) - fast soil carbon storage,  kgC/m2, trees 
%              b4t(i,j) - slow soil carbon storage,  kgC/m2, trees 
%              b1g(i,j), b2g(i,j), b3g(i,j), b4g(i,j) - carbon vars, grass 
%              alait(i,j),alaig(i,j) - annual maximum of total LAI, 
%                               separately for trees and grass
%
% turnover times: t1t, t2t, t3t, t4t, yrs, trees 
%                 t1g, t2g, t3g, t4g, yrs, grass 
%
%-----------------------------------


global b1t b2t b3t b4t b1g b2g b3g b4g
global alai alait alaig anpp anup
global st sg sd snlt
global b1 b2 b3 b4 b12 b34
global t1t t2t t3t t4t yrs trees
global t1g t2g t3g t4g grass

% parameters initialization: default INI_STEP=0
      
if  ~exist('INI_STEP','var') INI_STEP=0; end
if (INI_STEP==0) INITCPAR; end

% Choose equilibrium/dynamic model (KVEG=1/2s)
KVEG=2;

% SPATIAL LOOP: k - longitude, i - latitude 
for k=1,NS
  for i=1,IT
	ave_t= TATB(i,k);
	ave_pr=PRCB(i,k);
	gdd0=GDD0B(i,k);
    co2=PA;
    lat=i;
	lon=k;

	if (KVEG==1) 
      %   equilibrium run
      %... calculation of trees/grass fractions and amount of carbon in pools 
      %       for equilbrium state; NEP equals to total storage

	  CCSTAT;	  
    else
% calculation of dynamics of carbon pools and trees fraction 

 	  if (INI_STEP==0) 
        % initialization of carbon variables from equilibrium run in case of absent restart data 
 	    CCSTAT;
 	  else
 	    CCDYN;
 	  end
 	end

    if(lat==1 && lon==1) fprintf('ST=%f,SG=%f,NPP=%f,LAI=%f',...
        st(lat,lon),sg(lat,lon),anpp(lat,lon),alai(lat,lon));
    end
  end
end

INI_STEP=1;

return;
end


%-----------------------------------
function CCSTAT

%-----------------------------------
% From file declar.inc
global IT  % number of latitudes
global NS  % number of longitudes

%-----------------------------------
% From file bio.inc
% in common block /BIODAT/

global a bet gamm fmax npp nppmax v1 v2 v3
global c1t c2t c3t c1g c2g c3g
global d1t d2t d3t d1g d2g d3g
global e1t e2t e3t e1g e2g e3g
global f1t f2t f3t f1g f2g f3g
global k1t k2t k3t k1g k2g k3g
global t1t t2t t3t t4t t1g t2g t3g t4g
global ps1 ps2 ps3 ps4 ps5 soilt
global forshare_st t1tn t1td desshare_st nlshare_st
global deng dentd dentn
global ave_t ave_pr ave_pr05 desmin desmax
global ades acr k0t k0g k4g
% Added by Carsten Lemmen
global gdd0_min gdd0_max
global gdd0 npp ave_t ave_pr co2
global lat lon

global b1t b2t b3t b4t b1g b2g b3g b4g
global alai alait alaig anpp anup
global st sg sd snlt
global b1 b2 b3 b4 b12 b34
global t1t t2t t3t t4t yrs trees
global t1g t2g t3g t4g grass



% calculation of initial carbon cycle parameters

CCPARAM;

% calculation of equilibrium storages
%
% leaves biomass
% b1t is leaves phytomass for trees, b1g - for grass (kg C/m2)
% t1t is residence time of carbon in trees, t1g - in grass (years)



b1t(lat,lon)=k1t*t1t*npp;
b1g(lat,lon)=k1g*t1g*npp;

%   stems and roots biomass

b2t(lat,lon)=(1-k1t)*t2t*npp;
b2g(lat,lon)=(1-k1g)*t2g*npp;

%   litter

b3t(lat,lon)=(k0t*b1t(lat,lon)/t1t+k2t/t2t*b2t(lat,lon))*t3t;
b3g(lat,lon)=(k0g*b1g(lat,lon)/t1g+k2g/t2g*b2g(lat,lon))*t3g;

% mortmass and soil organic matter

b4t(lat,lon)=(k3t/t3t*b3t(lat,lon))*t4t;
b4g(lat,lon)=(k4g/t2g*b2g(lat,lon)+k3g/t3g*b3g(lat,lon))*t4g;

% initialization of fraction dynamic variables
        
st(lat,lon)=forshare_st;
sd(lat,lon)=desshare_st;
snlt(lat,lon)=nlshare_st;
sg(lat,lon)=1.-st(lat,lon)-sd(lat,lon);

CLIMPAR;
	
return
end
	
%-----------------------------------
function CCDYN
%-----------------------------------
% From file declar.inc
global IT  % number of latitudes
global NS  % number of longitudes

%-----------------------------------
% From file bio.inc
% in common block /BIODAT/

global a bet gamm fmax npp nppmax v1 v2 v3
global c1t c2t c3t c1g c2g c3g
global d1t d2t d3t d1g d2g d3g
global e1t e2t e3t e1g e2g e3g
global f1t f2t f3t f1g f2g f3g
global k1t k2t k3t k1g k2g k3g
global t1t t2t t3t t4t t1g t2g t3g t4g
global ps1 ps2 ps3 ps4 ps5 soilt
global forshare_st t1tn t1td desshare_st nlshare_st
global deng dentd dentn
global ave_t ave_pr ave_pr05 desmin desmax
global ades acr k0t k0g k4g

% Added by Carsten Lemmen
global gdd0_min gdd0_max
global gdd0 npp ave_t ave_pr co2
global lat lon

global b1t b2t b3t b4t b1g b2g b3g b4g
global alai alait alaig anpp anup
global st sg sd snlt
global b1 b2 b3 b4 b12 b34
global t1t t2t t3t t4t yrs trees
global t1g t2g t3g t4g grass



% temporal var*/
%	REAL tempor1,tempor2,db2,fd,dst,dd,nld,dstime
%    REAL dsg,dsd,temp_sg,temp_st
        
% calculation of current carbon cycle parameters

CCPARAM;
	
% calculation of dynamic fractions

fd=forshare_st-st(lat,lon);
dd=desshare_st-sd(lat,lon);
nld=nlshare_st-snlt(lat,lon);
temp_st=st(lat,lon);
temp_sg=sg(lat,lon);
        
% calculation of forest dynamics; exponential filtre
dst=forshare_st-fd*exp(-1./t2t)-st(lat,lon);
st(lat,lon)=st(lat,lon)+dst;
snlt(lat,lon)=nlshare_st-nld*exp(-1./t2t);

% desert dynamics; exponential filtre
dsd=desshare_st-dd*exp(-1./t2g)-sd(lat,lon)
tempor1=sd(lat,lon)+dsd+st(lat,lon)

% smooting of response time for desert dynamics 
if (tempor1 > 0.9)
  dstime=t2g*(1-tempor1)*10.+t2t*(tempor1-0.9)*10;
  dsd=desshare_st-dd*exp(-1./dstime)-sd(lat,lon);
end        
        
sd(lat,lon)=sd(lat,lon)+dsd
dsg=-dst-dsd

sg(lat,lon)=1.-st(lat,lon)-sd(lat,lon)

if (sg(lat,lon)<0) sg(lat,lon)=0; end
if (st(lat,lon)<0) st(lat,lon)=0; end
if (sd(lat,lon)<0) sd(lat,lon)=0; end
 
% calculation of dynamics of storages

% re-allocation of carbon storages between trees and grass areas  
% correction for trees

        tempor1=b4t(lat,lon);
        tempor2=b3t(lat,lon);

        if(st(lat,lon) > 0) 
          if(dst>0)   
            b4t(lat,lon)=(b4t(lat,lon)*temp_st ...
              +b4g(lat,lon)*dst)/st(lat,lon);
            b3t(lat,lon)=(b3t(lat,lon)*temp_st ...
              +b3g(lat,lon)*dst)/st(lat,lon);
          end
          b2t(lat,lon)=b2t(lat,lon)*temp_st/st(lat,lon);
          b1t(lat,lon)=b1t(lat,lon)*temp_st/st(lat,lon);
        end
        
% correction for grass

        if(sg(lat,lon) > 0) 	      
                if(dst > 0)   
                 b4g(lat,lon)=b4g(lat,lon)*(temp_sg-dst) ...
                /sg(lat,lon);
                 b3g(lat,lon)=b3g(lat,lon)*(temp_sg-dst) ...
                /sg(lat,lon);
                else 
           b4g(lat,lon)=(b4g(lat,lon)*temp_sg-tempor1*dst) ...
          /sg(lat,lon);
           b3g(lat,lon)=(b3g(lat,lon)*temp_sg-tempor2*dst) ...
          /sg(lat,lon);
                end
         b2g(lat,lon)=b2g(lat,lon)*temp_sg/sg(lat,lon);
         b1g(lat,lon)=b1g(lat,lon)*temp_sg/sg(lat,lon);
        end
              
% slow soil organic matter

	b4t(lat,lon)=b4t(lat,lon)+k3t/t3t*b3t(lat,lon)-b4t(lat,lon)/t4t;
	b4g(lat,lon)=b4g(lat,lon)+k4g/t2g*b2g(lat,lon)+k3g/t3g* ...
         b3g(lat,lon)-b4g(lat,lon)/t4g

%   fast soil organic matter

	b3t(lat,lon)=b3t(lat,lon)+b1t(lat,lon)/t1t*k0t+ ...
       k2t/t2t*b2t(lat,lon)-b3t(lat,lon)/t3t;
	b3g(lat,lon)=b3g(lat,lon)+b1g(lat,lon)/t1g*k0g+ ...
       k2g/t2g*b2g(lat,lon)-b3g(lat,lon)/t3g; 

% leaves biomass

	b1t(lat,lon)=b1t(lat,lon)+k1t*npp-b1t(lat,lon)/t1t;
	b1g(lat,lon)=k1g*npp*t1g;

%   stems and roots biomass

	b2t(lat,lon)=b2t(lat,lon)+(1-k1t)*npp-b2t(lat,lon)/t2t;
	b2g(lat,lon)=b2g(lat,lon)+(1-k1g)*npp-b2g(lat,lon)/t2g;


CLIMPAR;
	
return;
end


%-----------------------------------
function CLIMPAR
%-----------------------------------
% From file declar.inc
global IT  % number of latitudes
global NS  % number of longitudes

%-----------------------------------
% From file bio.inc
% in common block /BIODAT/

global a bet gamm fmax npp nppmax v1 v2 v3
global c1t c2t c3t c1g c2g c3g
global d1t d2t d3t d1g d2g d3g
global e1t e2t e3t e1g e2g e3g
global f1t f2t f3t f1g f2g f3g
global k1t k2t k3t k1g k2g k3g
global t1t t2t t3t t4t t1g t2g t3g t4g
global ps1 ps2 ps3 ps4 ps5 soilt
global forshare_st t1tn t1td desshare_st nlshare_st
global deng dentd dentn
global ave_t ave_pr ave_pr05 desmin desmax
global ades acr k0t k0g k4g

% Added by Carsten Lemmen
global gdd0_min gdd0_max
global gdd0 npp  co2
global lat lon KVEG

global b1t b2t b3t b4t b1g b2g b3g b4g
global alai alait alaig anpp anup
global st sg sd snlt
global b1 b2 b3 b4 b12 b34
global t1t t2t t3t t4t yrs trees
global t1g t2g t3g t4g grass



%       REAL tempor1

% calculation of annual averaged LAI - lai

	 alaig(lat,lon)=b1g(lat,lon)*deng;
         alait(lat,lon)=b1t(lat,lon)*(dentn*snlt(lat,lon)+ ...
                       dentd*(1-snlt(lat,lon)));
         alai(lat,lon)= alait(lat,lon)*st(lat,lon) ...
                       +alaig(lat,lon)*sg(lat,lon);
     
% calculation of annual carbon uptake

	if (KVEG==2)  && length(b1)+length(b2)+length(b3)+length(b4)>3
	   tempor1=b1(lat,lon)+b2(lat,lon)+b3(lat,lon)+b4(lat,lon);
    else 
           tempor1=0;
     end
        
        b1(lat,lon)=b1t(lat,lon)*st(lat,lon)+b1g(lat,lon)*sg(lat,lon);
        b2(lat,lon)=b2t(lat,lon)*st(lat,lon)+b2g(lat,lon)*sg(lat,lon);
        b3(lat,lon)=b3t(lat,lon)*st(lat,lon)+b3g(lat,lon)*sg(lat,lon);
        b4(lat,lon)=b4t(lat,lon)*st(lat,lon)+b4g(lat,lon)*sg(lat,lon);
        b12(lat,lon)=b1(lat,lon)+b2(lat,lon);
        b34(lat,lon)=b3(lat,lon)+b4(lat,lon);
	anup(lat,lon)=(b1(lat,lon)+b2(lat,lon) ...
            +b3(lat,lon)+b4(lat,lon)-tempor1) ;

%...      NET PRIMARY PRODUCTION

        anpp(lat,lon)=npp;

	return
	end

%-----------------------------------
function CCPARAM(ave_t,ave_pr,gdd0,co2)
%-----------------------------------
% From file declar.inc
global IT  % number of latitudes
global NS  % number of longitudes

%-----------------------------------
% From file bio.inc
% in common block /BIODAT/

global a bet gamm fmax npp nppmax v1 v2 v3
global c1t c2t c3t c1g c2g c3g
global d1t d2t d3t d1g d2g d3g
global e1t e2t e3t e1g e2g e3g
global f1t f2t f3t f1g f2g f3g
global k1t k2t k3t k1g k2g k3g
global t1t t2t t3t t4t t1g t2g t3g t4g
global ps1 ps2 ps3 ps4 ps5 soilt
global forshare_st t1tn t1td desshare_st nlshare_st
global deng dentd dentn
global ave_t ave_pr ave_pr05 desmin desmax
global ades acr k0t k0g k4g

% Added by Carsten Lemmen
global gdd0_min gdd0_max
global gdd0 npp co2
global lat lon



%       REAL  npp1,npp2,db1,db2,db3,avefor,differ,pcr
% calculation of current cycle parameters

% potential trees share

       avefor=ave_pr*ave_pr*ave_pr*ave_pr;
       differ=gdd0-gdd0_min;
       db1=-bet*differ;
       db2=gamm*differ;
       db3=differ*differ;

       if(differ < 0)  
          forshare_st=0;
       else 
          forshare_st=(1-exp(db1))*avefor/(avefor+a*db3*exp(db2));
       end
       if (forshare_st > fmax) forshare_st=fmax; end

% potential desert share - desshare_st

       desshare_st=0;
	 
% cold deserts 

       if(gdd0 < 100) desshare_st=1 ;  end
         
       if(gdd0 >= 100 && gdd0 < gdd0_min)
           desshare_st=(gdd0_min-gdd0)/(gdd0_min-100.)
       end

% dry deserts

 	 if (gdd0 >= gdd0_max) 
 	 
            pcr=acr*exp(gamm/2.*differ);

            if (ave_pr < pcr) 
                desshare_st=1;
                forshare_st=0;
            else
                db2=(ave_pr-pcr)/exp(gamm*differ);
                desshare_st=1.03/(1+ades*db2*db2)-0.03;
                if (desshare_st < 0) desshare_st=0; end
            end
            
         end

% calculation of NPP, Lieth's formula

	db1=-v1*ave_pr;
	db2=-v2*ave_t;
	npp1=(1.-exp(db1));
	npp2=1./(1.+v3*exp(db2));
	if(npp1 < npp2) 
                npp=nppmax*npp1;
	    else
                npp=nppmax*npp2;
	end

% CO2 enrichment factor

        npp=npp*(1+0.25/log(2.)*log(co2/280.));

% allocation factors and residence time of leaves biomass

	k1t=c1t+c2t/(1+c3t*npp);
	k1g=c1g+c2g/(1+c3g*npp);

	t1t=d1t+d2t/(1+d3t*npp);
	t1g=d1g+d2g/(1+d3g*npp);

%   residence time of stems and roots biomass

	t2t=e1t+e2t/(1+e3t*npp);
	t2g=e1g+e2g/(1+e3g*npp);

%   residence time of fast carbon pool

        t3t=16*exp(-ps5*(ave_t-soilt));
        t3g=40*exp(-ps5*(ave_t-soilt)) ; 

% residence time of slow soil organic matter

        t4t=900*exp(-ps5*(ave_t-soilt));
        t4g=t4t;

%calculation of potential nedleleaves trees ratio

	nlshare_st=(t1t-t1td)/(t1tn-t1td);
	if (nlshare_st > 1) nlshare_st=1; end
	if (nlshare_st < 0) nlshare_st=0; end

return;
end


%-----------------------------------
function INITCPAR
%-----------------------------------
% From file declar.inc
global IT  % number of latitudes
global NS  % number of longitudes

%-----------------------------------
% From file bio.inc
% in common block /BIODAT/

global a bet gamm fmax npp nppmax v1 v2 v3
global c1t c2t c3t c1g c2g c3g
global d1t d2t d3t d1g d2g d3g
global e1t e2t e3t e1g e2g e3g
global f1t f2t f3t f1g f2g f3g
global k1t k2t k3t k1g k2g k3g
global t1t t2t t3t t4t t1g t2g t3g t4g
global ps1 ps2 ps3 ps4 ps5 soilt
global forshare_st t1tn t1td desshare_st nlshare_st
global deng dentd dentn
global ave_t ave_pr ave_pr05 desmin desmax
global ades acr k0t k0g k4g

% Added by Carsten Lemmen
global gdd0_min gdd0_max
global gdd0 npp ave_t ave_pr co2
global lat lon


% initialisation of variables
         ades=0.0011;
         acr=28;
         a=7000.;
         bet=0.005;
         gamm=0.00017;
         gdd0_min=900.;
         gdd0_max=1800.;
         fmax=1.;
	 nppmax=1.46;
	 v1=0.000664;
	 v2=0.119;
	 v3=3.73;
	 c1t=0.046;
	 c2t=0.58;
	 c3t=1.6;
	 c1g=0.069;
	 c2g=0.38;
	 c3g=1.6;
	 d1t=0.22;
	 d2t=7.19;
	 d3t=5.5;
	 d1g=0.6;
	 d2g=0.41;
	 d3g=6.0;
	 e1t=17.9;
	 e2t=167.3;
	 e3t=15.;
	 e1g=0.67;
	 e2g=50.5;
	 e3g=100.;
	 f1t=0.43;
	 f2t=24.3;
	 f3t=13.;
	 f1g=0.34;
	 f2g=17.8;
	 f3g=50.;
         k2t=1.;
         k3t=0.017;
         k0t=0.6;
         k0g=0.2;
         k2g=0.55;
         k4g=0.025;
         k3g=0.013;
         t3g=1.;
	 t1tn=4;
	 t1td=1;
	 deng=20;
	 dentd=20;
	 dentn=6;
	 ps5=0.04;
	 soilt=5;
     return
	 end
