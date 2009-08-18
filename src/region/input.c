/*******************************************/
/*   reads ascii cramer leemans data       */
/*                                         */
/*   Kai W. Wirtz               15.12.2002 */
/*******************************************/
#include "defines.h"
#include "vars.h"

char logfile[8]="reg.log";
/******************************************/
/*     read cramer-lehmans ascii file     */
/******************************************/
void read_map(char* filename, int binout)
{
int ix,iy,d,dd,in;
float lat,lon,val[12],mval;
char fbinname[99];
FILE *sp,*sp2;
float min,max,rat;

for(d=0;d<DIMW1;d++)
   for(dd=0;dd<DIMW2;dd++)
     domap[d][dd]=0;  /* background (sea) value */
sp=fopen(filename,"r");
in=1;dd=0;min=9E9,max=0;
/******************************************/
/*   read values for min/max caclulation  */
/******************************************/
while(in!=EOF)
  {
  in=fscanf(sp,"%f %f ",&lat,&lon);  /* coordinates */
/*    printf("%1.1f %1.1f\t",lat,lon); */
  if(in!=EOF)
    {
    for(d=0;d<12;d++)
	fscanf(sp,"%f ",&val[d]); /* read monthly values */
    for(d=0,mval=0;d<12;d++)
       mval+=val[d];   /* calc annual mean */
    mval/=12;
    if(mval<min) min=mval; /* calc minimum for renormalization */
    if(mval>max) max=mval;
    }
  }
fclose(sp);

/*********************************/
/*      2nd read for matrix      */
/*********************************/
sp=fopen(filename,"r");
in=1;dd=0;
rat=intl*0.99/(max-min);
printf("min=%1.1f max=%1.1f rat=%1.2f in %s \n",min,max,rat,filename);

while(in!=EOF)
  if((in=fscanf(sp,"%f %f ",&lat,&lon))!=EOF)
    {
    for(d=0;d<12;d++)
	in=fscanf(sp,"%f ",&val[d]); /* read monthly values */
    for(d=0,mval=0;d<12;d++)
       mval+=val[d];   /* calc annual mean */
    mval/=12;
    iy=(int)(lat*2+360);   /* coordinates -> memory address */
    ix=(int)(180-lon*2);
  /********************************************/
  /*   transforming float data to int field   */
  /********************************************/
    domap[ix%DIMW1][iy%DIMW2]=1+(unsigned int)((mval-min)*rat)%intl;;
    if(dd++%500==-10)
      printf("%d %d %d %1.2f \t%d\n",dd,ix,iy,mval,domap[ix%DIMW1][iy%DIMW2]);
    }
printf("reading %s ready ..\n",filename);
fclose(sp);

/***********************************************/
/*  write selected region data to binary file  */
/***********************************************/
if(binout==1)
  {
  strcpy(fbinname,filename);
  strcat(fbinname,".bin");
  printf("writing %s  ...\t",fbinname);

  sp=fopen(fbinname,"w");
  fwrite(domap,DIMW1*DIMW2,sizeof(unsigned int),sp);
  fclose(sp);
  }
printf("ready \n",fbinname);
}
/******************************************/
/*     read climber-ascii file     */
/******************************************/
void read_climber_map(char* filename, int binout)
{
int ix,iy,d,dd,in,i,ih;
float lat,lon,npp,mnpp;
char fbinname[99];
char header[99];
char stringdata[30];
FILE *sp,*sp2;
float min,max,rat;

strcpy(fbinname,filename);
strcat(fbinname,".bin");

if(NEW_REG || binout==2)
  {
  for(d=0;d<DIMW1;d++)
    for(dd=0;dd<DIMW2;dd++)
      domap[d][dd]=0;  /* background (sea) value */

  sp=fopen(filename,"r");
  in=1;dd=0;min=9E9,max=0;

  /******************************************/
  /*   read values for min/max caclulation  */
  /*   Header length calculation            */
  /******************************************/
  ih=0;
  while(in!=EOF) {
    in=fgets(header,99,sp);
    if (header[0]!='#') break;
    fprintf(stdout,"%s",header);
    ih++;
    }
  fclose(sp);
  if(binout!=-2)
    {
    sp=fopen(filename,"r");
    for (i=0; i<ih; i++) in=fgets(header,99,sp);

    i=0;
    while ((in=fgets(header,99,sp))!=EOF) {
      strncpy(stringdata,header,30);
      i++;
      sscanf(stringdata,"%f %f %f",&lat,&lon,&npp);
      if(npp<min) min=npp;       /* calc minimum for renormalization */
      if(npp>max) max=npp;
      /* printf("%10i:%9.3f %9.3f %9.3f\n",i,lat,lon,npp);*/
      if (i%1000==0) printf(".",i);
      if (i==NPOP+1) {
        printf("...overflowing");
        break;
      }
    }

    fclose(sp);
    printf("\nThere are %d entries in file\n",i);
    }
  else
    min=-0.1,max=1.6;
/*********************************/
/*      2nd read for matrix      */
/*********************************/
  sp=fopen(filename,"r");
  in=1;dd=0;
  rat=intl*0.99/(max-min);
  printf("min=%1.1f max=%1.1f rat=%1.2f in %s \n",min,max,rat,filename);
    min=-0.1,max=1.6;
  rat=intl*0.99/(max-min);

  for (i=0; i<ih; i++) in=fgets(header,99,sp);
  i=0;
  while(in!=EOF) {
    if ((in=fgets(header,99,sp))!=EOF) {
      strncpy(stringdata,header,30);
      sscanf(stringdata,"%f %f %f",&lat,&lon,&npp);
      /*printf("%9.3f %9.3f %9.3f\n",lat,lon,npp);*/
      iy=(int)(lat*2+360);   /* coordinates -> memory address */
      ix=(int)(180-lon*2);
      /********************************************/
      /*   transforming float data to int field   */
      /********************************************/
      domap[ix%DIMW1][iy%DIMW2]=1+(unsigned int)((npp-min)*rat)%intl;;
      if(dd++%10000==0)
	printf("%d %d %d %1.2f \t%d\n",dd,ix,iy,npp,domap[ix%DIMW1][iy%DIMW2]);

      if (i++==NPOP+1) {
	printf("...overflowing");
	break;
      }
    }
  }
  printf("reading %s ready ..\n",filename);
  fclose(sp);

  /***********************************************/
  /*  write selected region data to binary file  */
  /***********************************************/
  if(binout>=1)
    {
    printf("writing %s  ...\t",fbinname);
    sp=fopen(fbinname,"w");
    fwrite(domap,DIMW1*DIMW2,sizeof(unsigned int),sp);
    fclose(sp);
    }
  printf("ready \n");
  }
else
   read_bin_map(fbinname);
}

/* ---------------------------------------------------------------------*/

/******************************************/
/*     read climber-ascii file     */
/******************************************/
void conv_climber_map_all(char* filename)
{
int ix,iy,d,dd,in,i,ih,bitd=10,bitm=16;
unsigned long intf,val;
unsigned char bmap2[DIMW1][DIMW2],bmap1[DIMW1][DIMW2];
float lat,lon,npp,mnpp,gdd,dum;
char fbinname[99];
char header[99];
char stringdata[30];
FILE *sp,*sp2;
float min,max,rat;

strcpy(fbinname,filename);
strcat(fbinname,".bin");

intf=(long)(pow(2,bitd));
intl=intf-2,
   

sp=fopen(filename,"r");
in=1;dd=0;min=9E9,max=0;

  /******************************************/
  /*   read values for min/max caclulation  */
  /*   Header length calculation            */
  /******************************************/
ih=0;
while(in!=EOF) {
    in=fgets(header,99,sp);
    if (header[0]!='#') break;
    fprintf(stdout,"%s",header);
    ih++;
    }
fclose(sp);
min=-0.05,max=1.65;
/*********************************/
/*      2nd read for matrix      */
/*********************************/
sp=fopen(filename,"r");
in=1;dd=0;
rat=intl*0.99/(max-min);
printf("min=%1.1f max=%1.1f rat=%1.2f in %s \n",min,max,rat,filename);
    min=-0.1,max=1.6;

rat=intl*0.99/(max-min);

for (i=0; i<ih; i++) in=fgets(header,99,sp);
i=0;
while(in!=EOF)
  if ((in=fgets(header,99,sp))!=EOF)
    {
    strncpy(stringdata,header,30);
    sscanf(stringdata,"%f %f %f %f %f %f %f",&lat,&lon,&npp,&dum,&dum,&dum,&dum,&gdd);
    /*printf("%9.3f %9.3f %9.3f\n",lat,lon,npp);*/
    iy=(int)(lat*2+360);   /* coordinates -> memory address */
    ix=(int)(180-lon*2);
      /********************************************/
      /*   transforming float data to int field   */
      /********************************************/

    bmap1[ix%DIMW1][iy%DIMW2]=(int)((double)gdd/365)*64*4;
    val=1+(unsigned long)((npp-min)*rat)%intl;
    bmap2[ix%DIMW1][iy%DIMW2]=val%256;
    bmap1[ix%DIMW1][iy%DIMW2]+=(int)((double)val/256);
    if(ix%77==0 && iy%90==0)
	printf("%d %d %1.2f %1.2f\t%d\t %d %d\n",ix,iy,npp,gdd,val,bmap1[ix%DIMW1][iy%DIMW2],bmap2[ix%DIMW1][iy%DIMW2]);

    if (i++==NPOP+1)
        {
	printf("...overflowing");
	break;
        }
    }

printf("reading %s ready ..\n",filename);
fclose(sp);

  strcpy(fbinname,filename);
   strcat(fbinname,".2bin");
   printf("writing %s  ...\n",fbinname);

printf("writing %s  ...\t",fbinname);
sp=fopen(fbinname,"w");
fwrite(domap,DIMW1*DIMW2,sizeof(unsigned int),sp);
fclose(sp);

  printf("ready \n");

}


/*********************************************************/
/*     convert climber-ascii file to bin and graphics    */
/*********************************************************/
void convert_bin(char* filename,char **argv, int binout)
{
int d,dd,in,i,slen;
char fname[99],fbinname[99],buf[5],*ppos,*ppos0;
FILE *sp;
strcpy(fname,filename);
ppos0=strrchr(fname,'.');
if(ppos0==NULL) err2exit("wrong filename");
slen=(int)(ppos0-fname);  /*strlen(filename)+;*/
   printf("%s slen=%d\n",ppos0,slen);

for(d=8000,i=-1;d<=8000;d+=400,i--)
   {
   dd=1+(int)(log10((double)(d+1)));
   if(dd>slen) dd=slen;
/*   printf("%d %d digits=%d %s\n",d,(int)(log10((double)(d+1))),dd,fname-dd);*/
   sprintf(buf,"%d",d); ppos=ppos0-dd;
   strncpy(ppos,buf,dd);

   printf("converting %s  ...\n",fname);
   conv_climber_map_all(fname);
   }
exit(0);
}
/* ---------------------------------------------------------------------*/

/****************************************/
/*        read   SAGE  ascii file       */
/****************************************/
void read_sage_map(char* filename, int binout, int binin)
{
int ix,iy,d,dd,in;
float lat,lon,val[DIMW2],mval;
char fbinname[199],item[32];
FILE *sp,*sp2;
float min,max,rat;
float nppveg[18];

strcpy(fbinname,filename);
strcat(fbinname,".bin");
  printf("opening %s ... NEW %d \n",fbinname,NEW_REG);

if(NEW_REG)
  {
  sp=fopen(filename,"r");
  printf("opening %s ...%ld \n",filename,sp);
  fscanf(sp,"%s %d ",item,&d); /* read head items */
  if(d!=DIMW2) err2exit("wrong dimension",d);
  fscanf(sp,"%s %d ",item,&d);
  if(d!=DIMW1) err2exit("wrong dimension",d);
   for(dd=0;dd<4;dd++)
    fscanf(sp,"%s %f",item,&rat);

  for(d=0;d<DIMW1;d++)
    for(dd=0;dd<DIMW2;dd++) /* read single data */
     {
     fscanf(sp,"%d ",&in);
     if(in>0) domap[d][dd]=in;
     else domap[d][dd]=0;
/*     if(d%499==0 && dd%319==0) */
/*       printf("%d %d\t%d %d\n",d,dd,domap[d][dd],in); */

     }
  printf("reading %s ready ..\n",filename);
  fclose(sp);

/***********************************************/
/*  write selected region data to binary file  */
/***********************************************/
  if(binout==1)
    {
    printf("writing %s  ...\n",fbinname);
    sp=fopen(fbinname,"w");
    fwrite(domap,DIMW1*DIMW2,sizeof(unsigned int),sp);
    fclose(sp);
    }
  }
else
  read_bin_map(fbinname);
}
/****************************************/
/*        read ETOPO 05  ascii file     */
/****************************************/
void read_etopo_map(char* filename, int binout, int binin)
{
int ix,iy,d,dd,in;
float lat,lon,val[DIMW2],mval;
char fbinname[199],item[32];
FILE *sp,*sp2;
float min,max,rat;
float nppveg[18];

strcpy(fbinname,filename);
strcat(fbinname,".bin");
if(NEW_REG)
  {
  sp=fopen(filename,"r");
  for(d=0;d<DIMW1;d++)
    for(dd=0;dd<DIMW2;dd++) /* read single data */
     {
     fscanf(sp,"%d ",&in);
     if(in>0) domap[DIMW1-d][dd]=in*1.0/9000*intl;
     else domap[DIMW1-d][dd]=0;
     if(d%400==0 && dd%500==0 && d<DIMW1)
       printf("%d %d\t%d %d\n",d,dd,domap[DIMW1-d][dd],in);

     }
  printf("reading %s ready ..\n",filename);
  fclose(sp);

/***********************************************/
/*  write selected region data to binary file  */
/***********************************************/
  if(binout==1)
    {
    printf("writing %s  ...\n",fbinname);
    sp=fopen(fbinname,"w");
    fwrite(domap,DIMW1*DIMW2,sizeof(unsigned int),sp);
    fclose(sp);
    }
  }
else
  read_bin_map(fbinname);
}

/* ---------------------------------------------------------------------*/

/************************************************/
/*  read selected region data from binary file  */
/************************************************/
int read_bin_map(char *filename)
{
    int ix,iy,d,dd,in;
    char fbinname[99];
    FILE *sp;
    
    if( (sp=fopen(filename,"r"))==NULL)
	err2exit(filename,sp);
    else
	printf("start reading %s ..\n",filename);
    fread(domap,DIMW1*DIMW2,sizeof(unsigned int),sp);
    fclose(sp);
    return 0;
    
}
/* ---------------------------------------------------------------------*/

/**************************************/
/*    print error message and exit    */
/**************************************/
int err2exit(char *message, long arg)
{
    printf("\n*** fatal error: %s !! (%d) ***\n",message,arg);
    printf("\n now exiting ...\n");
    exit(1);
    return 1;
}


/******************************************/
/*     read gluesclimate.bin file     */
/******************************************/
int read_gluesclimate_bin(char* filename, int yn, int binout) {

    extern int read_binary_record(const char*,int,int,int**,int*,int);
    int  sizes[4]={10,9,7,6};
    int* data[4];
    int  numrecords=1+180/8,numvars=4;
    FILE *file;
    int  nparts,i,j,k,ix,iy;
    char fbinname[255];
    
/* set background (sea) value */
    for(i=0;i<DIMW1;i++) for(j=0;j<DIMW2;j++) domap[i][j]=0;
    
/* get nparts and other file info */
    file=fopen(filename,"r");
    if (file==NULL) {
	fprintf(stderr,"Error opening file %s\n",filename);
	return -1;
    }
    fseek(file,0,SEEK_END);
    nparts=ftell(file)/(4*numrecords);
    fclose(file);
    printf("found %d data for %d slices in %s  ...\t",nparts,numrecords,filename);
    for (i=0; i<numvars; i++) data[i]=(int*)calloc(nparts,sizeof(int));
    lon=(float*)calloc(nparts,sizeof(float));
    lat=(float*)calloc(nparts,sizeof(float));
    
    read_binary_record(filename,numvars,nparts,data,sizes,yn);
    
    for (i=0; i<nparts; i++) {
	lon[i]=(double)(data[0][i])/2.0-180.;
	lat[i]=(double)(data[1][i])/2.0-60.;
	/*   lon[i]=(data[0])[i]-360;
	     lat[i]=(data[1])[i]-180;*/
	iy=(int)(lon[i]*2+360);   /* coordinates -> memory address */
	ix=(int)(180-lat[i]*2);
	npp_c[ix%DIMW1][iy%DIMW2]=data[2][i]*11.0;
	gdd_c[ix%DIMW1][iy%DIMW2]=data[3][i]*6.0;
	/*    domap[ix%DIMW1][iy%DIMW2]=1+(unsigned int)(intl*npp_c[ix%DIMW1][iy%DIMW2]*1.0/1400);*/
	domap[ix%DIMW1][iy%DIMW2]=1+(unsigned int)(intl*gdd_c[ix%DIMW1][iy%DIMW2]*1.0/366);
/*    if(ix%100==0 && iy%50==0)
    printf("%d %d %d\t%d \n",yn,ix,iy,domap[ix%DIMW1][iy%DIMW2]);*/
    }
    
  /***********************************************/
  /*  write selected region data to binary file  */
  /***********************************************/
  if(binout==1) {
    strcpy(fbinname,filename);
    strcat(fbinname,".map");
    printf("Writing %s  ...\t",fbinname);
    
    file=fopen(fbinname,"w");
    fwrite(domap,DIMW1*DIMW2,sizeof(unsigned int),file);
    fclose(file);
  }

  for (i=0; i<numvars; i++) free(data[i]);
  free(lon);
  free(lat);
  printf("done\n");
}


/*************************************************/
/*       write NPP and GDD of all regions        */
/*************************************************/
void out_region_npp(unsigned long max) {
  int y,d,dd,dl,dn,da,dx,dy,ds,r_num[NPOP];
  double r_npp[NPOP],r_gdd[NPOP];
  FILE *sp,*sp2,*sp3;
  char fname[19]="reg_npp_80_000.dat";
  char fmapname[19]="reg_gdd_80_000.dat";

   /* ---------------------------------- */
  /*    open region & evaluation file   */
  /* ---------------------------------- */
d=(int)(inum*0.01);
fname[11]=48+d%10; dd=inum-d*100;
fname[12]=48+(int)(dd*0.1)%10,fname[13]=48+dd%10;
strncpy(&fmapname[11],&fname[11],3);
printf("writing %d region npp and gdd into\n\t%s %s... \n",inum,fname,fmapname);
if((sp=fopen(fname,"w"))<0)
   printf("error opening %s\n",fname);
if((sp2=fopen(fmapname,"w"))<0)
   printf("error opening %s\n",fmapname);

for(y=0;y<23;y++)
  {
  /* --------------------------------------------- */
  /*     clear npp and gdd stores of regions       */
  /* --------------------------------------------- */
  for(d=0;d<inum;d++) r_npp[d]=r_gdd[d]=r_num[d]=0;
  
  /* ----------------------------------------- */
  /*     read and distribute npp and gdd       */
  /* ----------------------------------------- */
  read_gluesclimate_bin("gluesclimate.bin",y,0);
  for(dx=0;dx<dlat;dx++)
     for(dy=0;dy<dlon;dy++)
       if((d=occ[dx][dy]-1)>=0)
         {
         r_npp[d]+=npp_c[dx][dy];
         r_gdd[d]+=gdd_c[dx][dy];
         r_num[d]++;
         }

  for(d=0;d<inum;d++)
    {
    if(r_num[d]==0)
      err2exit("region has no elements",d);
    else
      if(r_num[d]!=pop[d].num && y==0)
        printf("reg %d num differ %d %d\n",d,r_num[d],pop[d].num);

    fprintf(sp,"%4.1f ",r_npp[d]/r_num[d]);
    fprintf(sp2,"%3.1f ",r_gdd[d]/r_num[d]);
    }
  fprintf(sp,"\n");
  fprintf(sp2,"\n");
  }
fclose(sp);
fclose(sp2);
}

/* ---------------------------------------------------------------------*/

/**********************************/
/*    open and clear log-file     */
/**********************************/
void init_log(void)
{
FILE *sp;
sp=fopen(logfile,"w");
fclose(sp);
sp=fopen("regeval.dat","w");
fclose(sp);

/*----------------------------------*/
/*     initial control settings     */
/*----------------------------------*/
/*first_xcall=1;*/
intl=(long)(pow(256,sizeof(unsigned int)))-2;
if( (dlat=lat2-lat1)!=DIM1 || (dlon=lon2-lon1)!=DIM2 )
  printf("error:check boundaries %d=%d %d=%d?\n",dlat,DIM1,dlon,DIM2);

dfmap=(unsigned char*)malloc(dlat*dlon*3*sizeof(unsigned char));
}

/**********************************/
/*    open and clear log-file     */
/**********************************/
void write_log(char *mes, int num)
{
FILE *sp;
sp=fopen(logfile,"a");
fprintf(sp,"%s: %d\n",mes,num);
fclose(sp);
}
