function pindex=cl_findpeaks(values,thresholds)

cl_register_function;

if ~exist('values','var')
  values=[1 -4 -3 0 -2 3 4 -5 6 7 1 2 -2 3 -5 -1]/3;
end

if ~exist('thresholds','var')
  thresholds=[1];
end

n=length(values);
nt=length(thresholds);

% Precalculate matrix
np=0;
for it=1:nt
  t=thresholds(it);
  peakind=find(values>=t | values<=-t);
  signchange=find(values(2:end)>0 & values(1:end-1)<0 ...
      | values(2:end)<0 & values(1:end-1)>0);
  np=max([min([length(signchange) length(peakind)])+1 np]);
end

pindex=zeros(np,nt)+NaN;

for it=1:nt      
  peakindex=[];

  t=thresholds(it);
  peakind=find(values>=t | values<=-t);
  signchange=find(values(2:end)>0 & values(1:end-1)<0 ...
      | values(2:end)<0 & values(1:end-1)>0);

  if numel(signchange)<1 continue; end
  np=0;
  ip=find(peakind<=signchange(1));
  if ~isempty(ip)
    [mp,p]=max(abs(values(peakind(ip))));
    peakindex(1)=peakind(ip(p));
    np=1;
  end
  for is=1:length(signchange)-1
    ip=find(peakind>signchange(is) & peakind<=signchange(is+1));
    if ~isempty(ip)
      np=np+1;
      [mp,p]=max(abs(values(peakind(ip))));
      peakindex(np)=peakind(ip(p));
    end
  end  
  ip=find(peakind>signchange(end));
  if ~isempty(ip)
    [mp,p]=max(abs(values(peakind(ip))));
    np=np+1;
    peakindex(np)=peakind(ip(p));
  end
   
  pindex(1:np,it)=peakindex;
end
  
%[2 7 8 10 14 15]

return
end
