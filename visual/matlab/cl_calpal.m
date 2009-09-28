function [time,dt]=cl_calpal(bp,bprange)


if ~exist('bprange','var') bprange=25; end
n=length(bp);
nr=length(bprange);

if (n~=nr & nr>1)
    error('Dimensions must match');
elseif (nr==1)
    bprange=repmat(bprange,n,1);
end

url='http://www.calpal-online.de/cgi-bin/quickcal.pl?bp=BPDATE&std=BPRANGE'

for i=1:n
  thisurl=strrep(url,'BPDATE',num2str(bp(i)));
  thisurl=strrep(thisurl,'BPRANGE',num2str(bprange(i)));
  
  [string,status]=urlread(thisurl);
  if (status~=1) continue;
  end
  
  i1=strfind(string,'calBC: ');
  i2=strfind(string(i1:end),'&plusmn; ');
  time(i)= str2num(string(i1+7:i1+11));
  dt(i)=str2num(string(i1+i2+8:i1+i2+9));

end


% Calendric Age calBC: 3811 &plusmn; 77
return
end