function proxy=find_proxy(sstr,type)

cl_register_function();

if ~exist('sstr','var') sstr=1; end;
if ~exist('type','var') type=''; end;

load('holodata.mat');
n=length(holodata.No);
id=[];

textfields={'Datafile','Plotname','Source','Comment'};
nt=length(textfields);

if strcmp(type,'') 
    if isnumeric(sstr) id=sstr; 
    else 
        
        for i=1:n
            k=[];
            for j=1:nt
                k=[k eval(['strfind(holodata.' textfields{j} '{i},sstr);'])];
                if ~isempty(k) id=[id i]; end;
            end
        end         
        
    end 
   
    
else switch type
    case 'Datafile', 
        for i=1:n
            k=strfind(holodata.Datafile{i},sstr);
            if ~isempty(k) id=[id i]; end;
        end         
    case 'Plotname', 
        for i=1:n
            k=strfind(holodata.Plotname{i},sstr);
            if ~isempty(k) id=[id i]; end;
        end         
    case 'Source', 
        for i=1:n
            k=strfind(holodata.Source{i},sstr);
            if ~isempty(k) id=[id i]; end;
        end         
end
end
        

id=unique(id);
  
for i=1:length(id)
    proxy(i).No=holodata.No(id(i));
    proxy(i).No_sort=holodata.No_sort(id(i));
    proxy(i).Datafile=holodata.Datafile(id(i));
    proxy(i).Plotname=holodata.Plotname(id(i));
    proxy(i).Latitude=holodata.Latitude(id(i));
    proxy(i).Longitude=holodata.Longitude(id(i));
    proxy(i).CutoffFreq=holodata.CutoffFreq(id(i));
    proxy(i).Source=holodata.Source(id(i));
    proxy(i).Comment=holodata.Comment(id(i));
    proxy(i).No_sort=holodata.No_sort(id(i));
    proxy(i).Proxy=holodata.Proxy(id(i));
    %proxy(i).Interpret=holodata.Interpret(id(i));    
end

    
return
