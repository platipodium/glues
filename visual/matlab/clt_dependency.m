function [names,files]=clt_dependency(name)

if nargin==0 name='clp_iiasa_vecode'; end
if ~ischar(name) error('String argument expected'); end

[p,n,e]=fileparts(name);
if isempty(e) e='.m'; end
filename=[n e];
scriptname=n;
if ~exist(filename,'file') error('File does not exist'); end

% Empty journal file
fid=fopen('cl_journal.txt','w');
fclose(fid);

eval(n);

return
end

