function cl_read_climber
%CL_READ_CLIMBER  Converts CLIMBER database to mat and netcdf
%  CL_READ_CLIMBER converts the .grd ascii files from the CLIMBER model to
%  Matlab .mat files and NetCDF format
%
%  two local files climber.mat and climber.nc are created
% 
%  See also CL_READ_IIASA

% Copyright 2010 Carsten Lemmen <carsten.lemmen@gkss.de>

cl_register_function;

filename='tran.dat';

if ~exist(filename,'file');
  error('Could not find climber data file ''tran.dat''');
end

%   /* ========== GRID DESCRIPTION ====================================
%    70      | LX      | longitudinal dimension
%    36      | LY      | latitudinal dimension
%    5.14285 | dxt     | longitudinal step (deg)
%    5.      | dyt     | latitudinal step (deg)
%    -177.42857  | sxt     | longitude of i=1
%    87.5    | syt     | latitude of j=1 (positive !)
%    Data is 4-Byte BIG_ENDIAN
%   */
% 

fid=fopen(filename,'rb');

  for (y=0; y<NY; y++) {
    for (m=0; m<NM; m++) {

      for (la=0; la<NLA; la++) {
	offset=y*(NLA*NLO)+la*(NLO);
	fread(raw,sizeof(float),NLO,in);

	for (lo=0; lo<NLO; lo++) {
#ifndef BIG_ENDIAN
	  big2little4((void*)(&raw[lo]));
#endif
	  tmp[la*NLO+lo]+=(raw[lo]*10.0);  /* convert to centigrade */
          gdd[offset+lo]+=(raw[lo]>7);
	  /*if (lo < 20) printf("%5d",temp[offset+lo]);*/
	}
     }
      
      for (la=0; la<NLA; la++) {
	offset=y*(NLA*NLO)+la*(NLO);
	fread(raw,4,NLO,in);
	
	/*printf("%5d%5d%5d ",y,m,la);*/
	for (lo=0; lo<NLO; lo++) {
#ifndef BIG_ENDIAN
	  big2little4((void*)(&raw[lo]));
#endif
	  prec[offset+lo]+=iroundf(raw[lo]*30.); /* convert to monthly*/
	  /*if (lo < 20) printf("%5d",prec[offset+lo]);*/
	}
	/*printf("\n");*/
      }
  
      /* Skip npp data for now */
      if (y*m < (NY-1)*(NM-1)) fseek(in,4*NLA*NLO,SEEK_CUR);
    }

    /* Correct to annual mean from annual sum */
    for (la=0; la<NLA; la++) for (lo=0; lo<NLO; lo++) {
      temp[y*(NLA*NLO)+la*NLO+lo]=iroundf((double)tmp[la*NLO+lo]/NM);

      tmp[la*NLO+lo]=0.0;
    }
  }
  fclose(in);





return
tran=load(filename,'-ascii');


% Data is lower-left coded, change to center
    eval(['lon=' par '(:,1)+0.25;']); 
    eval(['lat=' par '(:,2)+0.25;']); 

    
  eval([par '= ' par '(:,3:end);']);
  
  
save('-v6','climber',parameters{:},'lon','lat');

nid=length(lat);

if (1)
  ncid=netcdf.create('climber.nc','NC_WRITE');
  mondim=netcdf.defDim(ncid,'month',12);
  netcdf.defVar(ncid,'month','NC_BYTE',mondim);
  iddim=netcdf.defDim(ncid,'id',nid);
  netcdf.defVar(ncid,'id','NC_INT',iddim);
  latid=netcdf.defVar(ncid,'lat','NC_FLOAT',iddim);
  netcdf.putAtt(ncid,latid,'Description','Latitude (centered) of land grid cell');
  lonid=netcdf.defVar(ncid,'lon','NC_FLOAT',iddim);
  netcdf.putAtt(ncid,lonid,'Description','Longitude (centered) of land grid cell');

  for ip=1:np
    netcdf.defVar(ncid,parameters{ip},'NC_FLOAT',[iddim,mondim]);
  end
  
  netcdf.endDef(ncid);
  
  monid=netcdf.inqVarID(ncid,'month');
  netcdf.putVar(ncid,monid,[1:12]);
  
  idid=netcdf.inqVarID(ncid,'id');
  netcdf.putVar(ncid,idid,[1:nid]);
  
  varid=netcdf.inqVarID(ncid,'lat');
  netcdf.putVar(ncid,varid,lat);
  varid=netcdf.inqVarID(ncid,'lon');
  netcdf.putVar(ncid,varid,lon);
  
  
  for ip=1:np
    par=parameters{ip};
    parid=netcdf.inqVarID(ncid,par); 
    eval(['parval = ' par ';']);
    netcdf.putVar(ncid,parid,parval);
  end
  
  netcdf.close(ncid);
end

return;
end
