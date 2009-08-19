/*---------------------------------------------------------*/
/*      Random number generator for Monte Carlo runs       */
/*---------------------------------------------------------*/

#include <stdio.h>

unsigned long l0,l1=2147483648u;

double random2()
{

if((l0=l0*65539)<0)
	l0+=l1;
return (double)(l0)*(double)2.3283064369E-10;
}

void init_random2(unsigned long dv)
{
l0=dv;
}

int main(int argc, char* argv[]) {
        
   long n,i;
   if (argc>1) { n=atoi(argv[1]); }
   else n=10;
    
   init_random2(1000);

for (i=0; i<n; i++) fprintf(stdout,"%f\n",random2());

 return 0;

}
