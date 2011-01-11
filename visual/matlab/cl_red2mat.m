function cl_red2mat(file)

cl_register_function();

if ~exist('file','var') file='data/indus_varves.red'; end


if ~exist(file,'file') error('File does not exist'); end

fid=fopen(file,'r');
while (~feof(fid))
  l=fgetl(fid);
  while (l(1)==' ') l=l(2:end); end
  if (l(1)=='!')
    if findstr(l,'OFAC') 
        [tok,rem]=strtok(l,'=');
        param.ofac=str2num(strrep(rem,'=','')); 
    elseif findstr(l,'HIFAC') [tok,rem]=strtok(l,'='); param.hifac=str2num(strrep(rem,'=','')); 
    elseif findstr(l,'n50') [tok,rem]=strtok(l,'='); param.n50=str2num(strrep(rem,'=','')); 
    elseif findstr(l,'Nsim') [tok,rem]=strtok(l,'='); param.nsim=str2num(strrep(rem,'=','')); 
    elseif findstr(l,'rho') [tok,rem]=strtok(l,'='); param.rho=str2num(strrep(rem,'=','')); 
    elseif findstr(l,'tau') [tok,rem]=strtok(l,'='); param.tau=str2num(strrep(rem,'=','')); 
    elseif findstr(l,'freedom') [tok,rem]=strtok(l,'='); param.dof=str2num(strrep(rem,'=','')); 
    elseif findstr(l,'Bandwidth') [tok,rem]=strtok(l,'='); param.bandwidth=str2num(strrep(rem,'=','')); 
    elseif findstr(l,'Thomson') [tok,rem]=strtok(l,'='); param.critical=str2num(strrep(rem,'=','')); 
    elseif findstr(l,'scaling') [tok,rem]=strtok(l,'='); [tok,rem]=strtok(rem,'=')
        param.scalecrit=str2num(strrep(rem,'=','')); 
    end
  end
  if strmatch('!#  Freq',l) 
      break; 
  end
end

C=textscan(fid,'%f%f%f%f%f%f%f%f%f%f%f%f%f%f','CommentStyle','!');
fclose(fid);

freq=C{1};
Gxx=C{2};
Gxx_corr=C{3};
Gred_theoretical=C{4};
Gred_average=C{5};
CorrFactor=C{6};

param.scale80=mean(C{7}./C{4});
param.scale90=mean(C{8}./C{4});
param.scale95=mean(C{9}./C{4});
param.scale99=mean(C{10}./C{4});

save('-v6',strrep(file,'.red','_red.mat'),'param','freq','Gxx','Gxx_corr','Gred_theoretical','Gred_average','CorrFactor');

return
end