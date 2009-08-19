function ts_data_v=remove_singularevents(ts_data_t,ts_data_v)
%
%  remove singular events from ts_data_v
%    (which is trend-removed and STD normalized!!)
cl_register_function();

critper=[[8.0 8.4];[10.5 12]];
sc=2;
nts=length(ts_data_t);

%  number of periods with singular events	
nts = size(critper,1);

fac=zeros(nts,1)-1;indl=zeros(nts,1);
clear ind

% loop over all SE periods
for tii=1:nts 
%  find supra-critical values
  ind2 = find(ts_data_t>=critper(tii,1) & ts_data_t<critper(tii,2) & abs(ts_data_v)>1.5);
  if ind2,
    fac(tii)=0.5/max(abs(ts_data_v(ind2)));
    indl(tii)=length(ind2);
    ind(tii,1:indl(tii))=ind2; 
  end
end

    % reduce singular events
    if(sc==2)
      for tii=1:nts 
        if(fac(tii)>0)
          ts_data_v(ind(tii,1:indl(tii)))= ts_data_v(ind(tii,1:indl(tii)))*fac(tii);
        end
      end
    end
return
end
