function yearAD=cl_time2yearAD(time,unit)

is_since=findstr('since',unit);
if isempty(is_since) offset=0;
else
   ref_date_str=unit(is_since+6:end);  
   ref_date=datenum(ref_date_str); % convert to Julian days since 0-0-0
end  

if strmatch('year',unit) fac=1;
elseif strmatch('day',unit) fac=360.0;
elseif strmatch('minute',unit) fac=360*1440.0;
elseif strmatch('second',unit) fac=360*1440*60.0;
end

yeartime=time/fac;

ad_date=datenum('01-01-01 00:00:00');
if ~isempty(is_since) & ~strcmp(unit,'years since 01-01-01')
  yearAD=yeartime+str2num(datestr(ref_date,'yyyy'));
else 
  yearAD=yeartime;
end


return

end