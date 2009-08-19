/********************************************************/
/*                                                      */
/*     Versuch: einfacher Textfilter (z.B zum            */
/*                Abbrechen ueberlanger Zeilen)          */
/*                                                      */
/*   Kai-W. Wirtz                                       */
/*   Umweltsystemforschung (Uni Kassel)                 */
/*                                                      */
/*   last change: 10/08/97       first edit:10/08/97    */
/*                                                      */
/********************************************************/

#include<stdio.h>
#include<stdlib.h>
#include<string.h>

main(int argn, char **argv )
{
int dd,de;
unsigned long d,dind;
char all[255];
FILE *sp,*sp2;
int c=1;
float time,val,ft,fac,t0=160,t1=275;

sp=fopen("ETOPO05.dat","r");
printf("%ld\n",sp);
sp2=fopen("ETOPO05.dat.new","w");
printf("%ld\n",sp2);

d=0;
while(c!=EOF)
  {

  if( (d++)%10000==0)
      printf("%d %d\n",d,c);
  c=fgetc(sp);
/*  if(c!=0)
     printf("%d\t%1.1f\t%1.6f %s\n",c,time,val,all);
  else
     printf("end %d\n",c);
*/
   if((char)c!=',')
     fputc(c,sp2);

   }
fclose(sp);
fclose(sp2);

return;
}

