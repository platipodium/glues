function cl_redfit(varargin)

cl_register_function;

arguments = {...
  {'nsim',1000},...  % nsim should be higher for higher p levels
  {'mctest',1},...
  {'ofac',4.0},...
  {'hifac',1.0},...
  {'n50',2},...
  {'rhopre',-99.0},...
  {'iwin',1},...
  {'filename','/Users/lemmen/projects/glues/m/holocene/redfit/src/sajama_d18O.dat'}...
};

[args,rargs]=clp_arguments(varargin,arguments);
for i=1:args.length   
  eval([ args.name{i} ' = ' clp_valuestring(args.value{i}) ';']); 
end


if ~exist(filename,'file') error('File does not exist'); end
fid=fopen(filename,'r');
C=textscan(fid,'%f %f','CommentStyle','#j');
fclose(fid);

t=C{1};
x=C{2};

%t1=t(1);
%tdum=t(end);
np=length(t);
maxdim=np;
nseg=round(2*np/(n50+1));   % points per segment
avgdt=sum(t(2:np)-t(1:np-1))*1.0/(np-1);
tp=avgdt*nseg;              % average period in segment
df = 1.0/(ofac*tp);         % frequency spacing
fnyq = hifac * 1.0/(2.0*avgdt); % average Nyquist freq
nfreq= fnyq/(df+1);         % f(1)=f0; f(nfreq)=fnyq
nout=nfreq;

ini=1;
[freq,gxx]=spectr(ini,t,x,ofac,hifac,n50,iwin);




return
end

function [frq,gxx]=spectr(ini,t,x,ofac,hifac,n50,iwin)
  
si=1.0;
tzero=0.0;

np=length(t);
nseg = round(2 * np / (n50 + 1));         % points per segment
avgdt = (t(np) - t(1)) * 1.0 / (np-1);  % average sampling interval
tp = avgdt * nseg;                      % average period of a segment
df = 1.0 / (ofac * tp);                 % freq. spacing
wz = 2.0 * pi * df;                     % omega = 2*pi*f
fnyq = hifac * 1.0 / (2.0 * avgdt);     % average Nyquist freq.
nfreq = fnyq / df + 1;                  % f(1) = f0; f(nfreq) = fNyq
lfreq = nfreq * 2;
nout = nfreq;

gxx=zeros(nout,1);
twk=zeros(nseg,1);
frq=zeros(nseg,1);
xwk=zeros(nseg,1);
ftrx=zeros(lfreq,1);
ftix=zeros(lfreq,1);

if (ini==1)
  tcos=zeros(nseg,nfreq,n50);
  tsin=zeros(nseg,nfreq,n50);
  wtau=zeros(nfreq,n50);
  ww=zeros(nseg,n50);
end

for i=1:n50
 istart=round((i-1)*nseg/2);
 
 % Working copy for this segment
 twk=t(istart+1:nseg);
 xwk=x(istart+1:nseg);

 % detrend
 xwk=detrend(twk,xwk);
 
 % weight with window
 % and setup trigonometric array for lsft
 if (ini==1)
   wwk=winwgt(twk,iwin);
   ww(1:length(wwk),i)=wwk;
   xwk=ww(1:nseg,i).*xwk;
   %trig(i,twk,wz,nfreq);
 end
 
 %ftfix(i,xwk,twk,wz,nfreq,si,lfreq,tzero,ftrx,ftix);
 
 %gxx=gxx+(ftrx.*ftrx+ftix.*ftix);

end

scal=2.0/(n50*nseg*df*ofac);
gxx=gxx*scal;
frq=[0:nout-1]*df;


return
end


function [tsin,tcos]=trig(iseg,tsamp,wz,nfreq)

nn=length(tsamp);
tol1 = 1.0E-04;

wuse = wz;
istop = nfreq;
wdel = wuse;
wrun = wuse;
ii = 2;

while(1)
  arg=2.0*wrun*tsamp;
  tc=cos(arg);
  ts=sin(arg);
  sumts=sum(tsamp.*ts);
  sumtc=sum(tsamp.*tc);
  csum=sum(tc);
  ssum=sum(ts);
  
  if (abs(ssum)>tol1 | abs(csum)>tol1)
    watan=atan2(ssum,csum);
  else
    watan=atan2(-sumtc,sumts);
  end
  
  wtau(ii,iseg) = 0.5 * watan;
  wtnew = wtau(ii,iseg);
  
  arg=wrun.*tsamp-wtnew;
  tcos(:,ii,iseg)=cos(arg);
  tsin(:,ii,iseg)=sin(arg);
  
  ii = ii + 1;
  wrun = wrun + wdel;
  if (ii>istop) break;
  end
end
return
end


function ww=winwgt(t,iwin)
% calc. normalized window weights
% window type (iwin)  0: Rectangular
%                     1: Welch 1
%                     2: Hanning
%                     3: Parzen (Triangular)
%                     4: Blackman-Harris 3-Term
%--------------------------------------------------------------------------

pi = 3.141592653589793238462643383279502884197;
tpi = 2.0 * pi;

nseg = length(t);
rnp = 1.0*nseg;
fac1 = (rnp / 2.0 ) - 0.5;
fac2 = 1.0 / ((rnp / 2.0 ) + 0.5);
fac3 = rnp - 1.0;
fac4 = tpi /(rnp - 1.0);
tlen = t(nseg) - t(1);

jeff=rnp.*(t-t(1))/tlen;

switch(iwin)
    case 0, ww(1:nseg)=1.0;
    case 1, ww=1.0-((jeff-fac1)*fac2).^2;
    case 2, ww=0.5*(1.0-cos(tpi.*jeff/fac3));
    case 3, ww=1.0-abs((jeff-fac1)*fac2);
    case 4, ww=0.4243801 - 0.4973406 * cos(fac4 * jeff) ... 
              + 0.0782793 * cos(fac4 * 2.0 * jeff);
end

sumw2=sum(ww.*ww);  
scal = sqrt(rnp / sumw2);
ww=ww*scal;
return;
end


function winbw(iwin,df,ofac)

bw=[1.21 1.59 2.00 1.78 2.26];
winbw=df*ofac*bw(iwin+1);

return
end


function ydetrended=detrend(x,y)
% Least squares trend removal
  
n=length(x);
sx = sum(x);
sy = sum(y);

z=x-sx/n;
st2=sum(z.*z);
b=sum(z.*y)./st2;
a=(sy-sx*b)./n;

ydetrended=y-(a+b*x);

return
end



















