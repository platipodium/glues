function [names,ops]=parse_expression(expression,level) 

cl_register_function();

ops=[];
if ~exist('expression','var') expression='Tech*Dens-3*Farm'; end
if ~exist('level','var') level=0; end

posplus=[0,strfind(expression,'+'),length(expression)+1];
posminus=[0,strfind(expression,'-'),length(expression)+1];
posop=unique([posplus posminus]);
nopm=length(posop)-2;

if nopm>0 for i=1:nopm+1
    [n,o]=parse_expression(expression(posop(i)+1:posop(i+1)-1),level+1);
    if exist('names','var') names{numel(names)+1}=n; else names{1}=n; end
    if i>nopm continue; end
    ops=[ops expression(posop(i+1))];
    end
end

posop=[0,strfind(expression,'*'),length(expression)+1];
nomul=length(posop)-2;
if nomul>0 for i=1:nomul+1 
    n=parse_expression(expression(posop(i)+1:posop(i+1)-1),level+1);

 
    if exist('names','var') names{numel(names)+1}=n; else names{1}=n; end
   
    if i>nomul continue; end
    ops=[ops expression(posop(i+1))];
    end
end
    
if nomul+nopm<1 
     names=expression;
end

names

return;

end
