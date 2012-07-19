function clp_capacity(varargin)

global LiterateTechnology technology
global density gammab overexp qfarming
global ndomesticated omega germs resist tlim
global naturalfertility

% Initialize parameters
LiterateTechnology=12;
KnowlegeLoss=0.3;
ndommaxmean=7;
gammab=0.04;
omega=0.04;
gdd_opt=0.7;
kappa=550;
overexp=0.01;
deltat=0.15;
NPPCROP=900;
deltan=1;
deltar=0;
InitDensity=0.03;
InitQFarm=0.04;
InitNdomast=0.25;
InitTechnology=1;
germs=1;
resist=0;


technology=InitTechnology;
density=InitDensity;
qfarming=InitQFarm;
ndommax=ndommaxmean;
ndomesticated=InitNdomast;
naturalfertility=1;
tlim=1;


nt=200000;
dt=10;
ni=ceil(nt/dt);

for i=1:ni
  
  % Calculate diagnostics
  t(i)=technology;
  p(i)=density;
  q(i)=qfarming;
  p(i)=density;
  rgr=rgr();

  % Calculate tendencies
  dTdt=deltat.*drdT();
  dQdt=qfarming.*(1-qfarming).*drdQ();
  dNdt=deltan.*ndomesticated.*(ndommax-ndomesticated).*drdN();
  dRdt=deltar.*(germs-resist).*resist.*drdR();
  dpdt=rgr.*density;

  % do Euler integration
  technology=technology+dTdt.*dt;
  qfarming=max(qfarming+dQdt.*dt,InitQFarm);
  ndomesticated=ndomesticated+dNdt.*dt;
  density=density+dpdt.*dt;
  
end

end


function rgr=rgr()
  global art omega technology germs resist
  global overexp density actualfertility naturalfertility
  global actexploit qfarming tlim ndomesticated
  global product literacy LiterateTechnology disease
  global gammab

  art=1-omega*technology;
  actexploit=overexp.*sqrt(technology).*density;
  actualfertility=naturalfertility-actexploit;
  product=sqrt(technology).*(1-qfarming) ...
      + (tlim.*technology).*ndomesticated.*qfarming;
  literacy=technology/LiterateTechnology;
  disease = (germs-resist).*density.*exp(-literacy);
  birthrate= gammab.*actualfertility.*art.*product;
  deathrate=10*gammab*disease;
  rgr=birthrate - deathrate;
end
  
  
function drdT=drdT()
  global actexploit technology product art omega
  global LiterateTechnology gammab disease actualfertility
  
  dydT=-0.5*actexploit/technology;
  %dpdt=art.*((1-qfarming).*0.5/sqrt(technology)+tlim.*qfarming.*ndomesticated);
  dpdT=-omega.*product/art;
  dmdT=-10*gammab*disease/LiterateTechnology;
  drdT=gammab.*(dydT.*product+actualfertility.*dpdT)-dmdT;
  return;
end

function drdQ=drdQ()
  global technology tlim ndomesticated gammab
  global actualfertility art
  
  dpdQ=-sqrt(technology)+(tlim.*technology).*ndomesticated;
  drdQ=gammab.*actualfertility.*art.*dpdQ;
  return;
end

function drdN=drdN()
  global tlim technology qfarming art
  global actualfertility gammab
  
  dpdN=(tlim.*technology).*qfarming.*art;
  drdN=gammab.*actualfertility*dpdN;
  return;
end

function drdR=drdR()
  global density technology;
  drdR=density./technology;
end




