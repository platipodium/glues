function clp_boserup

% Technology T
% Population density p
% Relative growth rate r
% farming quota q

global mu rho omega omikron deltaT  food c
global literate Nmax deltaN natfert actfert artisans

natfert=1;
mu=0.004;
rho=mu;
deltaT=0.025;
literate=12;
Nmax=1.8;
deltaN=0.5/Nmax;

n=12000;
dt=2;

% Preallocate result vectors
dp=zeros(n,1);
dq=dp;
dT=dp;
dN=dp;
p=dp;
T=dp;
q=dp;
N=dp;
c=dp;
f=dp;

mode='glues';


if strcmp(mode,'glues')
  % Initial values for glues
  p(1)=0.01;
  T(1)=1.0;
  q(1)=.04;
  N(1)=0.8;
  omega=0.04;
  omikron=0.12;
else
  p(1)=0.01;
  T(:)=1;
  q(:)=0;
  N(:)=1;
  omega=0;
  omikron=0;
end

capacity=c(1);
dummy=dpdt(p(1),T(1),q(1),N(1),mode);

for i=2:n
    
  if strcmp(mode,'stairs')
    if mod(i,3000)==0 mu=mu*2; end
  end
  dp(i)=dpdt(p(i-1),T(i-1),q(i-1),N(i-1),mode).*dt;
  f(i)=food*actfert;
  if strcmp(mode,'glues')
    dq(i)=dqdt(p(i-1),T(i-1),q(i-1),N(i-1)).*dt;
    dT(i)=dTdt(p(i-1),T(i-1),q(i-1),N(i-1)).*dt;
    dN(i)=dNdt(p(i-1),T(i-1),q(i-1),N(i-1)).*dt;
    T(i)=T(i-1)+dT(i);
    q(i)=q(i-1)+dq(i);
    N(i)=N(i-1)+dN(i);
  end
  p(i)=p(i-1)+dp(i);
end

c=mu.*f./(rho./T);    

j=round([1:100].*n/101+1);

% figure(1); clf; hold on;
% set(gca,'LineWidth',3);
% plot(p(j),'r-','linewidth',5);
% plot(c(j)+omega.*T(j),'m:','linewidth',2);
% plot(T(j),'b-','linewidth',5);
% plot(q(j),'g-','linewidth',5);
% plot(N(j),'y-','linewidth',5);
% xlabel('Time','fontsize',15,'color',[0.7 0.7 0.7]);
% 
% %plot(c(j)-p(j),'m-');
% legend('Density','Capacity','Technology','Farmer share','Economic diversity','Location','NorthWest');

figure(1); clf; hold on;
set(gca,'LineWidth',3);
plot(p(j),'r-','linewidth',5);
plot(c(j),'r:','linewidth',2);
plot(T(j),'b--','linewidth',5);
plot(N(j),'g--','linewidth',5);
%plot(q(j),'g-','linewidth',5);
xlabel('Time','fontsize',15,'color','k');

%plot(c(j)-p(j),'m-');
legend('Population','Environment','Technology','Location','NorthWest');



print('-dpdf','boserup_glues');

return

j=[20:1000].*n/1000;
figure(2); clf reset; hold on;
x=dp;%1+p-c;
y=dT+dN;

plot(x(j),y(j),'b-','linewidth',5);
xlabel('Population growth','fontsize',15,'color',[0.7 0.7 0.7]);
ylabel('Innovativity','fontsize',15,'color',[0.7 0.7 0.7]);
print('-dpdf','boserup_population');

x=1+p-c;

%comet(1+p-c,dT);
%plot(dp,dq,'r');
figure(3); clf reset; hold on;
y=dT+dN;

plot(x(j),y(j),'b-','linewidth',5);
xlabel('Population pressure','fontsize',15,'color',[0.7 0.7 0.7]);
ylabel('Innovativity','fontsize',15,'color',[0.7 0.7 0.7]);
print('-dpdf','boserup_prosperity');

return
end




function dpdt=dpdt_c(p,c)
  global mu
  b=mu;
  d=mu/c;
  r=b-d.*p;
  dpdt=r*p;
  return;
end

function dpdt=dpdt(p,T,q,N,mode)
  global mu rho omega omikron literate 
  global food artisans actfert natfert
  
  food=max(0,sqrt(T).*(1-q)+q.*T.*N);
  artisans=max(0,1-omega.*T);
  actfert=max(0,natfert-omikron.*sqrt(T).*p);
      
  b=mu.*artisans.*actfert.*food;
  d=rho./T;

  r=b-d.*p;
  dpdt=r*p;
  return;
end



function dTdt=dTdt(p,T,q,N)
  global mu rho omega omikron
  global deltaT
  global food artisans actfert literate
 
  dfooddT=0.5./sqrt(T).*(1-q)+q.*N;
  dactfertdT=(actfert>0).*(-0.5*omikron./sqrt(T).*p);
  
  dbdT = mu.*(artisans>0).*(-omega)   .*actfert.*food ...
       + mu.*artisans.*dactfertdT.*food ...
       + mu.*artisans.*actfert.*dfooddT;
   
  drdT=dbdT+rho.*p./T.^2;
  %drdT=dbdT-rho.*exp(-T./literate)./literate;
  dTdt=deltaT.*drdT;
  
  if dTdt<0
      ;
  end
  return
  
end


function dqdt=dqdt(p,T,q,N)
  global mu artisans actfert
 
  dfooddq=-sqrt(T)+T.*N;
  dbdq = mu.*artisans.*actfert.*dfooddq;
   
  dqdt=q.*(1-q).*dbdq;
  return
  
end

function dNdt=dNdt(p,T,q,N)
  global mu Nmax deltaN artisans actfert
 
  dfooddN=q.*T;
  dbdN = mu.*artisans.*actfert.*dfooddN;
   
  dNdt=deltaN.*N.*(Nmax-N).*dbdN;
  return
  
end

