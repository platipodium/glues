#include <stdlib.h>
#include <stdio.h>
#include <string.h>

int main (int argc, char* argv[]) {

    FILE*  in,out;
    unsigned int i,format,count=10;

    double vd;
    float vf;
    int   vi;
    short int vs;
    long int vl;
    long double vld;
    char vc;

    if (argc == 0)  { in=stdin; }
    else if (argv[1][0] == '-') {
	if (strlen(argv[1]) == 1) {
	    in=stdin;
	}
	else {
	    fprintf(stderr,"Usage dump_binary [-|file]\n");
	    exit(1);
	}
    }
    else {
	in=fopen(argv[1],"rb");
    }

    if (in == NULL) {
	fprintf(stderr,"Could not open file\n");
	exit(2);
    }


	
    fprintf(stdout,"Char (%d): ",sizeof(char));
    for (i=0; i<count; i++) fread(&vc,sizeof(char),1,in),fprintf(stdout,"%d ",vc);
    rewind(in);

    fprintf(stdout,"\nShrt (%d): ",sizeof(short));
    for (i=0; i<count; i++) fread(&vs,sizeof(short int),1,in),fprintf(stdout,"%d ",vd);
    rewind(in);

   fprintf(stdout,"\nIntg (%d): ",sizeof(int));
    for (i=0; i<count; i++) fread(&vi,sizeof(int),1,in),fprintf(stdout,"%d ",vi);
    rewind(in);

   fprintf(stdout,"\nLong (%d): ",sizeof(long));
    for (i=0; i<count; i++) fread(&vl,sizeof(long),1,in),fprintf(stdout,"%ld ",vl);
    rewind(in);

  fprintf(stdout,"\nReal (%d): ",sizeof(float));
    for (i=0; i<count; i++) fread(&vf,sizeof(float),1,in),fprintf(stdout,"%f ",vf);
    rewind(in);
  fprintf(stdout,"\nDble (%d): ",sizeof(double));
    for (i=0; i<count; i++) fread(&vd,sizeof(double),1,in),fprintf(stdout,"%f ",vd);
    rewind(in);

    if (in != stdin) fclose(in);
    return 0;
}

		       
