/*******************************************/
/*  GLUES  Region preparation package      */
/*  Kai W. Wirtz                09.09.2003 */
/*******************************************/
#include "defines.h"
#include "vars.h"
/* ---------------------------------------------------------------------*/

/*************************************************/
/*   show time slice of geopolitical map         */
/*************************************************/
void set_col(int d,int dd, int col);

void set_black(int d,int dd);
void show_map(int mode,char **argv)
{
int d,dd,dx,dy,dx1,dy1,np1,np2,da,found;
unsigned char val;
  /* char symb[NPOP+1]=".O+x="; */

for(d=0;d<DIM1;d++)
  for(dd=0;dd<DIM2;dd++)
    {
 /*    if(mode>=0) */
       np1=occ[d][dd];
/*     val=(unsigned char)((occ[d][dd]+2)*255.0/(NPOP+1)); */
    if(mode>0)
      {
      val=(unsigned char)((np1%122+1)*255.0/(122+1));
      if(map[d][dd]<1E-8) val=0;
      }
    else
      if(mode<0)
         if(SAGE)
	   val=(unsigned char)(domap[d][dd]*15);
	 else
	   val=(domap[d][dd]>0)+(unsigned char)(domap[d][dd]*1E-7);
      else
         val=(unsigned char)(pop[np1-1].actmap*255.0);

/*       if(occ[d][dd]<=51201 && occ[d][dd]>5201&&mode==0) */
/*         printf("%d(%d:%1.3f)\n",val,occ[d][dd],pop[occ[d][dd]-1].actmap); */
    if(mode!=0 | 1 )
       set_col(d,dd,val);
    else
        /* ------------------------------------ */
        /*    show border lines in npp-mode     */
        /* ------------------------------------ */
      {

      if(check_border(d,dd,np1)) set_black(d,dd);
      else set_col(d,dd,val);
      }
    }
/*if(MAGICK || mode<=0) displaymap(argv[0],dfmap,dlat,dlon,4,mode);*/
}

/* ---------------------------------------------------------------------*/

/********************************************/
/*           Initialising fields            */
/********************************************/
void init_regions(int mode) {
  int d,dd,di;
  unsigned char val;
  float nr,redfac=1.,gdd_red=0.3,rad,rad_max=120,fac,
           npp[16]={2000,1600,1400,1200,1200,1100,1000,    /* 1-7 */
		    1100,1100, 900, 700, 500,  80,  10,1}; /* 8-15 */
  /*
    %  1.Trop. Evergr. Forest/Woodland
    %  2.Trop. Decid. Forest/Woodland
    %  3.Temp. Broadl. Evergr. Forest/Woodland
    %  4.Temp. Ndleaf Evergr. Forest/Woodland
    %  5.Temp. Decid. Forest/Woodland
    %  6.Boreal Evergr. Forest/Woodland
    %  7.Boreal Decid. Forest/Woodland
    %  8.Evergr./Decid. Mixed Forest/Woodland
    %  9.Savanna
    % 10.Grassland/Steppe
    % 11.Dense Shrubland
    % 12.Open Shrubland
    % 13.Tundra
    % 14.Hot Desert
    % 15.Polar desert/Rock/Ice
  */
  /**********************************************/
  /*   focus on region contintent for testing   */
  /**********************************************/
printf("\tinitializing from %d to %d and %d to %d ...\n",lon1,lon2,lat1,lat2);
  for(nps=0,nr=1.0/npp[0],d=lat1;d<lat2;d++)
    for(dd=lon1;dd<lon2;dd++) {
      /********************************/
      /*     grid initialization      */
      /********************************/
      if(SAGE)  /* convert Vegetation Index of SAGE map to NPP */
	if((di=domap[d][dd])>0)
	  if(di<16)
	    {
	      val=(unsigned char)(npp[di-1]*nr*255);
	      map[d-lat1][dd-lon1]=npp[di-1]*nr;
	    }
	  else
	    printf("biome index too high %d (%d %d)\n",di,d,dd);
	else
	  val=map[d-lat1][dd-lon1]=0;
      else
	{
	if(dd==lon1 || dd==lon2-1||d==lat1||d==lat2-1) domap[d][dd]=npp_c[d][dd]=gdd_c[d][dd]=0;
/*	rad = sqrt((dd-360)*(dd-360)+(d*d));*/
	rad = (double)d;
	if( rad <rad_max)
	  {
/*	  fac=redfac*sqrt((rad_max-rad)/rad_max);*/
	  fac=redfac*rad/rad_max;
	  if(domap[d][dd]>1.0/fac) domap[d][dd]*=fac;
	  npp_c[d][dd]*=fac;
	  gdd_c[d][dd]*=fac; gdd_c[d][dd]-=fac*gdd_red;
	  if(gdd_c[d][dd]<EPS) gdd_c[d][dd]=EPS;
	  }
	
	val=(unsigned char)(domap[d][dd]*256.0/intl);
/*        map[d-lat1][dd-lon1]=domap[d][dd]*1.0/intl;*/
        map[d-lat1][dd-lon1]=npp_c[d][dd]*1./1400;
	if(map[d-lat1][dd-lon1]>1) map[d-lat1][dd-lon1]=1;
	if(map[d-lat1][dd-lon1]<EPS) map[d-lat1][dd-lon1]=EPS;
        map2[d-lat1][dd-lon1]=gdd_c[d][dd]*1./366;
	if(map2[d-lat1][dd-lon1]>1) map2[d-lat1][dd-lon1]=1;
	if(map2[d-lat1][dd-lon1]<EPS) map2[d-lat1][dd-lon1]=EPS;

	}
      set_col(d-lat1,dd-lon1,val);
      /*     if(d==49 && dd>144 && dd<154)  */
      /* printf("%d %d %ld\t%d %d %1.2f\n",d,dd,intl,domap[d][dd],val,map[d-lat1][dd-lon1]); */
      
      /************************************************/
      /*   Initialising: one population at each cell  */
      /************************************************/
      if(domap[d][dd]>0)
	if(nps++<NPOP)
	  {
	  occ[d-lat1][dd-lon1]=nps;
/*	  pop[nps-1].actmap=pop[nps-1].newmap=map[d-lat1][dd-lon1];*/
	  pop[nps-1].actmap=pop[nps-1].newmap=map[d-lat1][dd-lon1];
	  pop[nps-1].actmap2=pop[nps-1].newmap2=map2[d-lat1][dd-lon1];
	  pop[nps-1].num=1;
	  pop[nps-1].lat=d;
	  pop[nps-1].far=sin(d*3.1415/DIMW1);
	  pop[nps-1].lon=dd;
	  }
	else
	  printf("NPOP %d too small\t%d\n",NPOP,dlat*dlon);
      else
	occ[d-lat1][dd-lon1]=0;
    }
  printf("%d land cells found (NPOP=%d)\n",inum=nps,NPOP);
  
  /********************************************/
  /*   Initialising spatial pop distribution  */
  /********************************************/
  for(d=0;d<dlat;d++)
    for(dd=0;dd<dlon;dd++)
      if(map[d][dd]==0)
	set_col(d,dd,0);
      else
	set_col(d,dd,10);
}

void set_col(int d,int dd, int col) {
  *(dfmap+d*DIM2*3+dd*3)=col;
  *(dfmap+d*DIM2*3+dd*3+1)=256-col;
  *(dfmap+d*DIM2*3+dd*3+2)=196-0.75*col;
}

void set_black(int d,int dd) {
  *(dfmap+d*DIM2*3+dd*3)=0;
  *(dfmap+d*DIM2*3+dd*3+1)=0;
  *(dfmap+d*DIM2*3+dd*3+2)=0;

}
/********************************************/

double random2() {
  unsigned long l1=2147483648;
  if((l0=l0*65539)<0)
    l0+=l1;
  return (double)(l0)*(double)2.3283064369E-10;
}

int calc_area(long d) {
 if(d<NPOP)
   if(pop[d].num==0) return 0;
   else return 1+(int)(pop[d].num*pop[d].far);
 else
   err2exit("index too large",d);
}


int dump_map()
{
FILE* dumpfile;

dumpfile=fopen("dump.bin","w");
fwrite(domap,DIMW1*DIMW2,sizeof(unsigned int),dumpfile);
fclose(dumpfile);
}

void set_new_pop(dx,dy,inew)
{
int dn;
double nmap;
/*     if(dd>5000 && dl>loop-2)*/
/*        printf("transfer cell %d/%d\t %d %d\n",dd,dn0,dx,dy);*/
if(inew>NPOP) printf("ind %d too large in %d %d\n",inew,dx,dy);

newocc[dx][dy]=inew;
dn=inew-1;
pop[dn].newmap=(pop[dn].newmap*pop[dn].num+map[dx][dy])/(1+pop[dn].num);
pop[dn].newmap2=(pop[dn].newmap2*pop[dn].num+map2[dx][dy])/(1+pop[dn].num);
pop[dn].num++;
dn=occ[dx][dy]-1;

nmap=pop[dn].newmap;
if(pop[dn].num>1)
  pop[dn].newmap=(pop[dn].newmap*pop[dn].num-map[dx][dy])/(pop[dn].num-1);
if(pop[dn].newmap<0)
  printf("newmap %d %d\t %1.3f->%1.3f\t%1.3f\n",dn,pop[dn].num,nmap,pop[dn].newmap,map[dx][dy]);
nmap=pop[dn].newmap2;
if(pop[dn].num>1)
  pop[dn].newmap2=(pop[dn].newmap2*pop[dn].num-map2[dx][dy])/(pop[dn].num-1);
if(pop[dn].newmap2<0)
  printf("newmap2 %d %d\t %1.3f->%1.3f\t%1.3f\n",dn,pop[dn].num,nmap,pop[dn].newmap2,map2[dx][dy]);
pop[dn].num--;
if(pop[dn].num<0 ||  dn<0)
/*  err2exit("negative pop number of ",dn);*/
   pop[dn].num=0;
}


int check_border(d,dd,np1)
{
int da,dx1,dy1,np2;
for(da=0;da<NDIR;da++)  /* scan all neighbors */
   {
   dx1=(d+dirx[da]+DIM1)%DIM1;  /* x/y coordinate of neighbor */
   dy1=(dd+diry[da]+DIM2)%DIM2;
   if((np2=occ[dx1][dy1])>0)
   if(np1!=np2)
      return 1;
   }
return 0;
}

