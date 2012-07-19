function data=cl_query_steele(varargin)

% Spatial and Chronological Patterns in the Neolithisation of Europe
% James Steele, Stephen J. Shennan, 2000
% http://archaeologydataservice.ac.uk/archives/view/c14_meso/overview.cfm

%cl_register_function;

arguments = {...
  {'variables',{'period','long_decimal','lat_decimal','Cultural_Id'}},...
};

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length 
  lv=length(a.value{i});
  if (lv>1 & iscell(a.value{i}))
    for j=1:lv
      eval( [a.name{i} '{' num2str(j) '} = ''' char(clp_valuestring(a.value{i}(j))) ''';']);         
    end
  else
    eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); 
  end
end

global files

datafile='Steele2000.mat';
if ~exist(datafile,'file') cl_read_steele2000; end

load(datafile);

nv=length(variables);
for iv=1:nv
  [ifile,icol]=find_header(variables{iv});
  if isempty(icol) error('Header could not be found'); end

  data{iv}=files(ifile).data{icol};
  
  
end


return
end

function [ifile,icol]=find_header(header)
global files

for ifile=1:length(files)
  icol=strmatch(header,files(ifile).header);
  if ~isempty(icol) break; end
end

return
end


