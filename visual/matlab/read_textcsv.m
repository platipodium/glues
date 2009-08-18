function data=read_textcsv(filename, delim, textdelim)

cl_register_function();

if ~exist('filename') filename='redfit_all.tsv'; end
%if ~exist('filename') filename='/h/lemmen/projects/glues/m/holocene/redfit/data/output/total/taylordome_d18O_tot.dat.red'; end;
if ~exist('delim') delim=' '; end;
if ~exist('textdelim') textdelim='"'; end;
commentmarker='#';

[pathstr,name,ext,dummy] = fileparts(filename);
[dummy,name,dummy1,dummy2]=fileparts(name);

data = struct('CSVFilename',[name ext]);

fid = fopen(filename);
if fid<0 return; end;

% Skip comments, i.e. fields with prepended comment markers
fl = fgetl(fid);
while ((strcmp(fl(1),commentmarker)==1) & (~feof(fid))) fl=fgetl(fid); end;

% Treat first line as header, do not allow '<>%-'
rem = strrep(fl,textdelim,'');
rem = strrep(rem,'<','');
rem = strrep(rem,'>','');
rem = strrep(rem,'%','');
rem = strrep(rem,'-','');

while ~isempty(rem)
    [tok, rem] = strtok(rem,delim);
    if isempty(tok)
        error('Empty token in file');
    end;   
    if ~isletter(tok(1)) tok=['x' tok]; end;
    data = setfield(data,tok,[]);
end

fnames = fieldnames(data);
ncol = length(fnames);

% read following lines
nl = 0;
while 1
    l = fgetl(fid);
    if (feof(fid)) break; end
    if strcmp(l(1),'#') continue; end
    %fprintf('%s\n',l);
    nl = nl + 1;
    rem = l;
    ntok = 1;
    while ~isempty(rem)
        [tok, rem] = strtok(rem,delim);
        tok=strrep(tok,'''','');
        if isempty(tok) continue; end;
        ntok = ntok + 1;
        if nl == 1
            if tok(1) == textdelim
                data = setfield(data,fnames{ntok},{});
            end
        end
        if strcmp(tok,'"NaN"')
             eval(['data.' fnames{ntok} ' = [data.' fnames{ntok} ' NaN ];'])
        elseif strcmp(tok,'"---"')
             eval(['data.' fnames{ntok} ' = [data.' fnames{ntok} ' NaN ];'])
        elseif (tok(1)  == textdelim )
            eval(['data.' fnames{ntok} '{' num2str(nl) '} = strrep(''' tok ''',''' textdelim ''', '''');']);
            %        elseif ~isa(tok,'numeric')
           % eval(['data.' fnames{ntok} '{' num2str(nl) '} = ''' tok ''';']);
        else          
	      tok = strrep(tok,',','.');
          %fprintf('%s',tok);
          eval(['data.' fnames{ntok} ' = [data.' fnames{ntok} ' ' tok '];']);
        end
    end
end

fclose(fid);
return;
