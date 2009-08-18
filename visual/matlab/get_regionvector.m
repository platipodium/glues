%GET_FILES  gets file names and directories
%   [DIR,FILE] = GET_FILES returns the setup, plot and result
%   directories in the DIR object, and the mapping file and 
%   mapping file length file names in the FILE object.
%
%   If any of the directories does not exist, the function
%   returns.  If any of the mapping files do not exist, the
%   function returns.

% Copyright (C) 2007 Carsten Lemmen and Kai Wirtz
%                    GKSS-Forschungszentrum Geesthacht GmbH

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3, or (at your option
% any later version.

% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.

% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
% 02110-1301, USA.

function [regionvector,regionlength] = get_regionvector(varargin);

cl_register_function();

    if (nargin==0) [directory,file]=get_files; 
    else 
        directory.setup=varargin{1}; 
    end;

    fid=fopen([directory.setup '/regionvector.mat']);
    if fid > 0
        load([directory.setup '/regionvector.mat']); 
        return;
    else  
        fid=fopen([directory.setup '/regionvector_686.mat']);
        if fid > 0  
            load([directory.setup '/regionvector_686.mat']);
            return;
        end;
    end;
           
    % Open mapping files and determine endianness 
    [fid,message]=fopen(file.mappinglen,'r','b');
    if (fid < 0) message; end;
    regionlength=fread(fid,inf,'uint32');
    fclose(fid);
    if max(regionlength < 10000) mappingfileendian='b'; 
    else  
        [fid,message]=fopen(file.mappinglen,'r','l');
        if (fid < 0) message; end;
        regionlength=fread(fid,inf,'uint32');
        fclose(fid);
        if max(regionlength < 10000) mappingfileendian='l'; end;    
    end;    
    
    n=length(regionlength);
    fprintf('Reading %ld region lengths from %s-endian file %s',n,mappingfileendian,file.mappinglen);

    [fid,message]=fopen(file.mapping,'r',mappingfileendian);
    regionvector=fread(fid,inf,'uint32');
    maxn=ceil(length(regionvector)/n);
    regionvector=reshape(regionvector,maxn,n)';
    fclose(fid);

    save([directory.setup '/regionvector_686.mat'],'regionvector','regionlength');
    
return;
%EOF

