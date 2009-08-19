function tout=disturb_chronology(tin,numd,delta)
%
%  dist_chronology(numd,delta) maximally disturbs all time dates in vector
%  tin
%

cl_register_function();

if~exist('tin','var') tin=[1:0.02:10]; end

nts = length(tin);

% numd  : number of dated segments (time model resolution)	
if ~exist('numd','var') numd = 10; end

if ~exist('delta','var') delta=0.15; end

% creates vector of time-dated positions
tau = (0:numd) * max(tin)/numd;
% not necessarily of equal distance; also check real time-models!

% loop over all vector elements
for tii=1:nts 

  t = tin(tii);

%  find segment index
  [m tj] = min(abs(t-tau));  
  if t-tau(tj)<=0, tj=tj-1; end

  tj=max(tj,1);
  tj=min(tj,numd);
  
% position in segment
  x = (t-tau(tj))/(tau(tj+1)-tau(tj));

% new date
% creates new vector from old one
% delta : time shift/uncertainty, specified in main 
  tout(tii) = t + delta*(1-2*x);
end
  
%clf; plot(tin,'r-'); hold on; plot(tout,'b-');

  [tsort,isort]=sort(tout);
  if (any(isort-[1:nts]~=0))
      warning('Overlapping data')
  end
 
  
  return;
end

  
