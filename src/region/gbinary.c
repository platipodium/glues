/************************************************
  File gbinary.c
  Interface for reading and writing binary data
  files for the GLUESimulator
  Carsten Lemmen <c.lemmen@fz-juelich.de>
 
  Created: 2003-10-08
  
  Modification history 
************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <math.h>
int iroundf(double x) { /*printf("%1.3f ->%d\n",x,(int)floor(0.5+x)); */return (int)floor(0.5+x); }

/* Byte ordering type definition */

enum byte_order_type {little_endian,big_endian} byte_order;

/* Private prototypes  */

static enum byte_order_type get_byte_order (void);
static int write_binary_record_32bit(const char* filename, int numvars, int nparts,int** data, 
			      const int* sizes, const char* mode);
static int read_binary_record_32bit(const char* filename, int numvars, int nparts, int** data, 
			     const int* sizes, int numrec);

/* Public prototypes */
int scale2pack(int* data,unsigned long nparts,float scale,float offset,float maxval);
int write_binary_record(const char* filename, int numvars, int nparts,int** data, 
			const int* sizes, const char* mode);
int write_text_record(const char* filename, int numvars, int nparts,int** data, const int* sizes, const char* mode);
int write_metafile(const char* filename, int numvars, int nparts,char** descriptions,const int* sizes, int numrec);
int read_binary_record(const char* filename, int numvars, int nparts, int** data, 
		       const int* sizes, int numrec);

/***************************************************
 Implementation section 
**********************************************/

/* Determine byte order */ 

static enum byte_order_type get_byte_order (void) {
  short w = 255;
  unsigned char *s = (unsigned char *) &w;
  if (*s) return (little_endian);
  else return (big_endian);
}

static int write_binary_record_32bit(const char* filename, int numvars, int nparts,int** data, const int* sizes, const 
char* mode) {
  
  /* const char* filename is a pointer to a file name on the system
     int numvars is the number of variables to write
     int nparts is the number of entries in each data variable
     const int*** is a list with numvars entries, consisting of pointers to the data
     const int*   is a list with numvars entries, denoting the size (in bits) the data should use
     char mode is the file open mode (r,w,a)
  */

  FILE* file;
  int i,j;
  int *scales;
  int integer;
  enum byte_order_type order;

  if (sizeof(int)!=4) {
    printf("Integer is not defined as 32 bit on this platform, failed\n");
    return 0;
  }

  if (mode[0]=='w') {
    order=get_byte_order();
    if (order==big_endian) printf("Writing binary data on BIG_ENDIAN system\n");
    else printf("Writing binary data on LITTLE_ENDIAN system\n");
  }
  
  scales=(int*)calloc(numvars+1,sizeof(int));
  for (j=0; j<numvars; j++) scales[j+1]=scales[j]+sizes[j];
  if (scales[numvars]>32) {
    printf("Data length (%2d) exceeds 32 bits, nothing written to file %s\n",scales[numvars],filename);
    return 0;
  }

  if ((file=fopen(filename,mode))==NULL) return 0;
  
  for (i=0; i<nparts; i++) {
    for (j=0,integer=0; j<numvars; j++) {
      integer+=((data[j][i]))*((int)pow(2,scales[j]));
      /*printf("%6d%6d%12d%8d%12d%6d\n",j,i,integer,scales[j+1],(int)pow(2,scales[j]),data[j][i]);*/
    }
    fwrite(&integer,4,1,file);
  }

  free(scales);
  fclose(file);

  return (i-1)*(j-1);
}

/*-----------------------------------*/

static int read_binary_record_32bit(const char* filename, int numvars, int nparts, int** data, const int* sizes, int 
numrec) {
  
  /* const char* filename is a pointer to a file name on the system
     int numvars is the number of variables to read
     int nparts is the number of entries in each data variable
     int** is a list with numvars entries, consisting of pointers to the data
     const int*   is a list with numvars entries, denoting the size (in bits) the data use in the file
     int numrec is the zero-based offset (number of record) of the data to read
  */

  FILE* file;
  unsigned int *scales,*p2s, i,j,integer,last;

  if (sizeof(int)!=4) {
    printf("Integer is not defined as 32 bit on this platform, failed\n");
    return 0;
  }

  scales=(unsigned int*)calloc(numvars+1,sizeof(unsigned int));
  for (j=scales[0]=0; j<numvars; j++) scales[j+1]=scales[j]+sizes[j];
  p2s=(unsigned int *)calloc(numvars+1,sizeof(unsigned int));
  for (j=0; j<=numvars; j++) p2s[j]=(unsigned int)pow(2,scales[j]);

  if (scales[numvars]>32) {
    printf("Data length (%2d) exceeds 32 bits, nothing read from file %s\n",scales[numvars],filename);
    return 0;
  }

  printf("numrec=%d\n",numrec);
  if ((file=fopen(filename,"r"))==NULL) return 0;
  fseek(file,numrec*4L*nparts,SEEK_SET);

  for (i=0; i<nparts; i++) {
    fread(&integer,4,1,file);
    for (j=0,last=0; j<numvars; j++) {
     if(j<numvars-1)
      data[j][i]=(int)((double)(integer%p2s[j+1])/p2s[j]);
     else
      data[j][i]=(int)((double)(integer)/p2s[j]);
 if(i%8000==0 && j==-2)
       printf("out %5d%7d%12p%8d%12p%6d\n",j,i,integer,scales[j],p2s[j+1],data[j][i]);

      integer-=data[j][i]*p2s[j];

    }
  }

  free(scales);
  fclose(file);

  return (i-1)*(j-1);
}

int write_metafile(const char* filename, int numvars, int nparts,char** descriptions,const int* sizes, int numrec) {
  
  /* const char* filename is a pointer to a file name on the system
     int numvars is the number of variables to write
     int nparts is the number of entries in each data variable
     const char** is a list variable descriptions
     const int*   is a list with numvars entries, denoting the size (in bits) the data should use
     char mode is the file open mode (r,w,a)
  */
  
  FILE* file;
  char** formats;
  int i,j,digits;
  int * scales;
  enum byte_order_type order;

  if ((file=fopen(filename,"w"))==NULL) return 0;
  
  /* Generate text file formats */
  formats=(char**)malloc(numvars*sizeof(char*));
  for (i=0; i<numvars; i++) {
    formats[i]=(char*)calloc(10,sizeof(char));
    digits=(int)(sizes[i]*log10(2.0)+1);
    sprintf(formats[i],"%%%dd",digits+1);
  }
  
  /* Generate binary format */
  scales=(int*)calloc(numvars+1,sizeof(int));
  for (j=0; j<numvars; j++) scales[j+1]=scales[j]+sizes[j];
  order=get_byte_order();
  
  fprintf(file,"File <%s>\n",filename);
  fprintf(file,"Meta file for GLUESimulator binary and text data\n");
  fprintf(file,"Creator Carsten Lemmen <c.lemmen@fz-juelich.de> ");
  fprintf(file,"and Kai Wirtz <wirtz@icbm.de>\n\n");

  fprintf(file,"SYSTEM\n");
  if (order==big_endian) fprintf(file,"  Byte order:              BIG_ENDIAN\n\n");
  else fprintf(file,"  Byte order:              LITTLE_ENDIAN\n\n");
  
  fprintf(file,"ALL RECORDS\n");
  fprintf(file,"  Number of records:      %d\n",numrec);
  fprintf(file,"  Record length:          %d byte\n",nparts*4);
  fprintf(file,"  Variable number:        %d\n",numvars);
  fprintf(file,"  Variable length:        %d\n\n",nparts); 

  for(j=0; j<numvars; j++) {
    fprintf(file,"VARIABLE %d:\n",j);
    fprintf(file,"  Description:           %s\n",descriptions[j]);
    fprintf(file,"  Textual format:        \"%s\" (C-style)\n",formats[j]);
    fprintf(file,"  Binary representation: %d bit\n",sizes[j]);
    fprintf(file,"  Retrieval formula:     y =( x mod 2^%d) / 2^%d\n\n",scales[j+1],scales[j]);
  }

  fprintf(file,"# END-OF-FILE <%s>\n",filename);
  fclose(file);

  for (i=0; i<numvars; i++) free(formats[i]);
  free(scales);
  free(formats);

  return 1;
}

/*-------------------------------------------------*/

int write_text_record(const char* filename, int numvars, int nparts, int** data, const int* sizes, const char* mode) {
  
  /* const char* filename is a pointer to a file name on the system
     int numvars is the number of variables to write
     int nparts is the number of entries in each data variable
     const int*** is a list with numvars entries, consisting of pointers to the data
     const int*   is a list with numvars entries, denoting the size (in bits) the data should use
     char mode is the file open mode (r,w,a)
  */

  FILE* file;
  char** formats;
  int i,j,digits;

  if ((file=fopen(filename,mode))==NULL) return 0;
  
  formats=(char**)malloc(numvars*sizeof(char*));

  for (i=0; i<numvars; i++) {
    formats[i]=(char*)calloc(10,sizeof(char));
    digits=(int)(sizes[i]*log10(2.0)+1);
    sprintf(formats[i],"%%%dd",digits+1);
  }

  for (i=0; i<nparts; i++) {
    for (j=0; j<numvars; j++) fprintf(file,formats[j],data[j][i]);
    fprintf(file,"\n");
  }

  fclose(file);

  for (i=0; i<numvars; i++) free(formats[i]);
  free(formats);

  return (i-1)*(j-1);
}

int write_binary_record(const char* filename, int numvars, int nparts, int** data, const int* sizes, const char* mode) 
{

  int j,bitstouse=0;

  for (j=0; j<numvars; j++) bitstouse+=sizes[j];

  if (bitstouse<=32) {
    return write_binary_record_32bit(filename,numvars,nparts,data,sizes,mode);
  }

  printf("Cannot efficiently handle %d bit data yet, please implement\n",bitstouse);
  return 0;
}


int read_binary_record(const char* filename,int numvars,int nparts,int** data, const int* sizes,int numrec) {

  int j,bitstouse=0;

  for (j=0; j<numvars; j++) bitstouse+=sizes[j];

  if (bitstouse<=32) {
    return read_binary_record_32bit(filename,numvars,nparts,data,sizes,numrec);
  }

  printf("Cannot efficiently handle %d bit data yet, please implement\n",bitstouse);
  return 0;
}

/*----------------------------------*/

int scale2pack(int* data,unsigned long nparts,float scale,float offset,float maxval) {

  /* Scale2pack scales a data record stored in data
     by adding an offset offset and dividing by the scalefactor scale.
     a maximum value is resprected at maxval, the minimum value is
     always zero 
  */

  unsigned long i;
  
  for (i=0; i<nparts; i++) {
    data[i]=(data[i]+offset<maxval?data[i]+offset:maxval);
    data[i]=(data[i]>0?data[i]:0);
    data[i]=iroundf(data[i]/scale);
  }

  return 1;
}

/*----------------------------------*/
/*-----------------------------------*/
