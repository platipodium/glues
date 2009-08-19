/****************************************************************
 * GLUES						        *
 * Global Land-Use and technological Evolution Simulator	*
 *								*
 * \author Carsten Lemmen <carsten.lemmen@gkss.de>
 * \file printevents.c
 * \date 2007-05-24
 ***************************************************************/

#include <stdio.h>

int main(int argc, char* argv[]) {

    const char* sfilename="/h/lemmen/projects/glues/glues/glues-1.1.2/setup_685/EvSeries.dat";
    const char* rfilename="/h/lemmen/projects/glues/glues/glues-1.1.2/setup_685/EventInReg.dat";
    FILE* f;

    float fdummy;
    unsigned int old_sgn=1,rmax=0;

    f=fopen(sfilename,"r");
    if (f == NULL) { return 1; }

    while( fdummy<0 | old_sgn==1) { 
	fread(&fdummy, sizeof(float),1,f);
	if (fdummy<0) old_sgn=-1;
	printf("%d %f\n",rmax,fdummy);
	rmax++;
	
    }
    rmax--;
    fclose(f);

    return 0;
}

