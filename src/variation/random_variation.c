#include <stdlib.h>
#include <stdio.h>
#include <string.h>

//#define DEBUG 0

int main(int argc, char* argv[]) 
{
  unsigned long int seed=123456789;
  char line[1024];
  char rangefile[1024],valuefile[1024];
  char typus[255],name[255],value[255];
  FILE *infile,*outfile;
  char *serror;
  int ierror;
  double minval,maxval,val;
  size_t offset;

  fprintf(stdout,"Program deprecated, please use C++ version RandomVariation.cc");

  if (argc>1) 
    seed=(unsigned long)atol(argv[1]);
 
 
  fprintf(stdout,"Program %s called with arguments %s (%ld)\n",argv[0],argv[1],seed);
  
  srand(seed);

  sprintf(rangefile,"../variation/variation_ranges.tsv");
  sprintf(valuefile,"../variation/variation_values.tsv");

  infile=fopen(rangefile,"r");
  if (infile==NULL) return 1;
  outfile=fopen(valuefile,"w");
  if (outfile==NULL) return 2;
  fprintf(outfile,"# File automatically generated by program %s\n",argv[0]);
  fprintf(outfile,"# Seed value for this run is %ld\n",seed);

  while (!feof(infile)) {
    serror=fgets(line,1024,infile);
    if (feof(infile)) break;
    if (serror==NULL) return 3;

#ifdef DEBUG
    fprintf(stderr,"Line:\t%s",line);
#endif

    offset=0;
    serror=strchr(line,'\t');
    if (serror==NULL) return 4;
    else {
      memcpy(typus,line+offset,serror-line-offset);
      typus[serror-line-offset]='\0';      
      offset=serror-line+1;
    }
#ifdef DEBUG
    //fprintf(stderr,"\t%s (%d,%d) %x %x\n",typus,strlen(typus),offset,line,serror);
        fprintf(stderr,"\t%s",typus);
#endif

    serror=strchr(line+offset,'\t');
    if (serror==NULL) return 5;
    else {
      memcpy(name,line+offset,serror-line-offset);
      name[serror-line-offset]='\0';      
      offset=serror-line+1;
    }
#ifdef DEBUG
    // fprintf(stderr,"\t%s (%d,%d) %x %x\n",name,strlen(name),offset,line,serror);
    fprintf(stderr,"\t%s",name);
#endif
   
    serror=strchr(line+offset,'\t');
    if (serror==NULL) return 6;
    else {
      minval= atof(line+offset);
      offset=serror-line+1;
    }
#ifdef DEBUG
    fprintf(stderr,"\t%f",minval);
#endif
    
    serror=strchr(serror,'\t');
    if (serror==NULL) return 7;
    else {
      maxval= atof(line+offset);
    }
#ifdef DEBUG
    fprintf(stderr,"\t%f\n",maxval);
#endif

    val=(1.0*rand())/RAND_MAX*(maxval-minval)+minval;

#ifdef DEBUG
    fprintf(stdout,"%s\t%s\t%f\t%f\t%f\n",typus,name,minval,val,maxval);
#endif
    fprintf(outfile,"%s\t%s\t%f\n",typus,name,val);
  } 
		       
  fclose(infile);
  fclose(outfile);

  return 0;
}
