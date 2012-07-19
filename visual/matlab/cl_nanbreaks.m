function nmatrix=cl_nanbreaks(ind,values)
% CL_NANBREAKS inserts NaN values into values as whenever index ind
% is discontinuous


%ind=[1 2 3 4 6 7 8 10 14 16 17 18 19 29 21]';
%values=[1:length(ind)]';


nind=length(ind);
inan=find((ind(2:end)-ind(1:end-1))>1);
if isempty(inan) out=values;
else
    
nnan=length(inan);
out=zeros(nind+nnan,size(values,2));

out(1:inan(1),:)=values(1:inan(1),:);
out(inan(1)+1,:)=NaN;
for i=1:nnan-1
   off=i+1;
   out(inan(i)+off:inan(i+1)+off-1,:)=values(inan(i)+1:inan(i+1),:);
   out(inan(i+1)+off,:)=NaN;
end
off=nnan;
out(inan(nnan)+off+1:end,:)=values(inan(nnan)+1:end,:);
end

if nargout>0 nmatrix=out; end

end