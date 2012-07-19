function filenames = zipinfo(zipfilename)
%ZIPINFO Extract names of filename entries in zip file.
%
%   FILENAMES = ZIPINFO(ZIPFILENAME)

% Copyright 2010
% Carsten Lemmen

    
zipfilename = fullfile(pwd,'data/1000bc_lu.zip');
filenames = [];

% Create a Java ZipFile object and obtain the entries.
try
   javafile = java.io.File(zipfilename);
   zipfile  = org.apache.tools.zip.ZipFile(javafile);
   filenames = zipfile.getEntries;
catch exception
   if ~isempty(zipfile)
       zipfile.close();
   end    
   error('Zip file "%s" is empty or invalid.',zipfilename);
end


% Setup the ZIP API to process the entries.
api.getNextEntry    = @getNextEntry;
api.getEntryName    = @getEntryName;
api.getInputStream  = @getInputStream;
api.getFileMode     = @getFileMode;
api.getModifiedTime = @getModifiedTime;

% Extract ZIP contents.
files = extractArchive(outputDir, api, mfilename);

if nargout == 1
   varargout{1} = files;
end

%--------------------------------------------------------------------------
   function entry = getNextEntry
      try
         if entries.hasMoreElements
            entry = entries.nextElement;
         else
            entry = [];
         end
      catch exception  %#ok<SETNU>
         fcnName = mfilename;
         format = [upper(fcnName(3)) fcnName(4:end)];
         eid = sprintf('MATLAB:%s:invalid%sFileEntry', mfilename, format);
         error(eid,'Invalid %s file %s.', upper(format), zipFilename);
      end
   end

%--------------------------------------------------------------------------
   function entryName = getEntryName(entry)
      entryName = char(entry.getName);
   end

%--------------------------------------------------------------------------
   function inputStream = getInputStream(entry)
      inputStream  = zipFile.getInputStream(entry);
   end

%--------------------------------------------------------------------------
   function fileMode = getFileMode(entry)
      if ispc
         % Return the external attribute for Windows.
         % The external attribute is the Unix file mode shifted
         % left by 16 bits with the system, hidden, and archive
         % attributes in the lower 2-bytes.
         fileMode = entry.getExternalAttributes;
      else
         % Return the Unix file mode
         fileMode = entry.getUnixMode;
      end
   end

%--------------------------------------------------------------------------
   function modifiedTime = getModifiedTime(entry)
      modifiedTime = entry.getTime;
   end

%--------------------------------------------------------------------------
end
