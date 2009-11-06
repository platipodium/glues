/*******************************************/
/*  GLUES  Region preparation package      */
/*  Kai W. Wirtz                09.01.2003 */
/*******************************************/
#include "defines.h"
#include "vars.h"
#define AREACELL	1972 /* area (km2) of a 0.5x0.5 grid cell */

/*************************************************/
/*   calc & show statistics on pop numbers       */
/*************************************************/
unsigned long calc_distribution(int ds) {
  int d,dd,dx,dy,di,dn;
  unsigned long pn[NSTAT],checkp[NPOP],max;
  char buf[99];

  for(d=0;d<NSTAT;d++)         /* clean pdf array */
    pn[d]=0;
  for(d=0;d<nps;d++)           /* calc pointer to entry */
   if(pop[d].num<=0) pn[0]++;
   else
     if( (dn=1+(int)((double)calc_area(d)/ncrit))<NSTAT)
       pn[dn]++;
    else
       pn[NSTAT-1]++;         /* large regions to last element */

  for(d=inum=sump=max=0;d<nps;d++)  /* mean and max of distribution */
    if(pop[d].num>=ncrit)
      {
      sump+=pop[d].num;
      inum++;
      if(pop[d].num>max) max=pop[d].num;
      }
  if(ds%5==0 || ds==end)
    {
      if(inum==0) inum=1;
      printf("%ld\t%1.0f %d %ld\t",ds,(double)sump/inum,inum,max);
      sprintf(buf,"%ld\t%1.0f %d %ld\t",ds,(double)sump/inum,inum,max);
      write_log(buf,pn[0]);
      for(d=0;d<NSTAT;d++)
	printf("%d ",pn[d]);
      printf("\n");
    }
  /*  for(d=0;d<NPOP;d++)   checkp[d]=0; */
  /* for(d=dout=0;d<DIM1;d++) for(dd=0;dd<DIM2;dd++) */
  /*  if((sump=occ[d][dd])>0) checkp[sump-1]++,dout++; */
  /* for(d=0;d<NPOP;d++) */
  /*  if((int)(0.995+checkp[d]*0.08) >=3) */
  /*    printf("%d:%d(%d) ",(int)(0.995+checkp[d]*0.08),checkp[d],d); */
  /*    printf("\n%ld\n",dout ); */
  return max;
}

/* ------------------------------------------------------------------------------ */

/*************************************************/
/*   calc center and area of all regions
       incl border length to neighbors           */
/*************************************************/
void calc_regions(unsigned long max,int run) {
int d,dd,dl,dn,da,dx,dy,ds,ds0,dx1,dy1,dn0,dr,dni,dnd,inew,*buf;
int *scx,*scy,*six,*siy,found,d1x,d2x,d1y,d2y,db,*old_ind;
unsigned long di,im[NDIR],*rni,rnin,lat,lon,ar,sar,maxn,maxb;
double sinfl,imn[NDIR],*rnf,bl;
double weighta[9]={0.0,1,1,1,1,0.5,0.5,0.5,0.5};
FILE *sp,*sp2,*sp3;
char fname[21]="regions_80_00000.dat";
char fmapname[21]="mapping_80_00000.dat",fmlname[25];
char fevalname[21];

memcpy(newocc,occ,DIM1*DIM2*sizeof(unsigned int));
max+=2;
printf("max=%ld inum=%d\n",max,inum);
max+=(int)(max*0.25);

 /* ----------------------------------------------------- */
 /*  allocate cell pointer memory of connected land mass  */
 /* ----------------------------------------------------- */
six=(int *)malloc(max*sizeof(int));
siy=(int *)malloc(max*sizeof(int));
rni=(long *)malloc(2*max*sizeof(long));
rnf=(double *)calloc(2*max,sizeof(double));
old_ind=(int *)malloc(lround(1.5*inum)*sizeof(int));

  /* ------------------------------------------------ */
  /*    attribute new indices to remaining regions    */
  /* ------------------------------------------------ */
for(d=dr=inew=0;d<nps;d++) /* search for remainders */
  if(pop[d].num>0)
     old_ind[inew++]=d;
  /*  printf("inew=%d <%d?\n",inew,lround(1.5*inum)); */
 /* --------------------------------------- */
 /*    maximal number of cells per region   */
 /* --------------------------------------- */
for(d=maxn=0;d<inew;d++)
   if(pop[old_ind[d]].num>maxn) maxn=pop[old_ind[d]].num;

if(maxn>inew) maxb=maxn; else maxb=inew;

  printf("%d %d ->%d\n",inew,maxn,maxb);
buf=(int *)malloc((maxb+1)*sizeof(int));

  /* ---------------------------------- */
  /*    open region & evaluation file   */
  /* ---------------------------------- */
  if(run>=0)  
  {
    sprintf(fname,"regions_XX_%05d.dat",inew);
    printf("writing regions into %s ... (%d)\n",fname,run);
    if((sp=fopen(fname,"w"))<0) {
      printf("error opening %s\n",fname);
    }
    
    sprintf(fevalname,"regeval_XX_%05d.dat",inew);
    sp2=fopen(fevalname,"a");
  }

  /* ---------------------------------- */
  /*    open region mapping      file   */
  /* ---------------------------------- */
  if(run>=0)  
  {
    sprintf(fmapname,"mapping_XX_%05d.dat",inew);
    strcpy(fmlname,fmapname); 
    strcat(fmlname,".len");
    printf("writing regionlength into %s ... \n",fmlname);
    sp3=fopen(fmlname,"w");
    for(d=0;d<inew;d++)
      buf[d]=pop[old_ind[d]].num;
    fwrite(buf,inew,sizeof(int),sp3);
    fclose(sp3);
   
    printf("writing region mapping into %s ... (%d)\n",fmapname,run);
    if((sp3=fopen(fmapname,"w"))<0)
      printf("error opening %s\n",fmapname);
  }


  /* ------------------------------------ */
  /*      loop over remaining regions     */
  /*      to aggregate regions            */
  /* ------------------------------------ */
  for(dd=dr=sar=0;dd<inew;dd++)
  {
    d=old_ind[dd];
    find_regcell(d);/* returns position of an arbitrary cell of region */
/*if(dd==18) pos[0]=55,pos[1]=375;*/
    six[0]=dx=pos[0],siy[0]=dy=pos[1];
    occ[dx][dy]=dd+1;

   /* -------------------------- */
   /*   save mapping info        */
   /* -------------------------- */
/*    fprintf(sp3,"\n%d %d",dd,dx*DIM2+dy);*/
    buf[0]=dx*DIM2+dy;

    if(pop[d].num<ncrit*0.5)
      printf("%d %d\t%d %d\t",dd,pop[d].num,dx,dy);

    lat=lon=0;
    dn=db=1;dn0=rnin=0;
    /* ------------------------------------ */
    /*   loop to find all connected cells   */
    /* ------------------------------------ */
    while(dn>dn0 && dn<max)
      for(dnd=dn0,dn0=dn;dnd<dn0;dnd++)
        for(dx=six[dnd],dy=siy[dnd],da=1;da<9;da++)  /* scan all neighbors */
	    {
	    dx1=(dx+dirx[da]+DIM1)%DIM1;  /* x/y coordinate of neighbor */
	    dy1=(dy+diry[da]+DIM2)%DIM2;
	    if((di=occ[dx1][dy1])>0)
	      if(newocc[dx1][dy1]!=99999+d)
	        if(di==d+1)              /* found region member */
		    {
		    /* -------------------------- */
		    /*   mark and add new cells   */
		    /* -------------------------- */
		      occ[dx1][dy1]=dd+1;
		      newocc[dx1][dy1]=99999+d;
		      six[dn]=dx1,siy[dn++]=dy1;
		      if(dn>max) printf("calcreg: dn = %d \t%d %d\t%d %d\n",dn--,dx,dy,dx1,dy1);
		      lat+=dx1;               /* average position */
		      lon+=dy1;

	    /* -------------------------- */
	    /*   save mapping info        */
	    /* -------------------------- */
		      buf[db++]=dx1*DIM2+dy1;
		      if(pop[d].num<ncrit*0.5) printf("%d %d\t",dx,dy);
		     }
		     else                      /* average neighbor */
		  if(di<dd+1)
		    {
		    for(dni=found=0;dni<rnin;dni++)
		      if(rni[dni]==di-1)   /* neighbor already stored ? */
			  rnf[dni]+=weighta[da],found=1;
		    if(found==0)
		       rni[rnin]=di-1,rnf[rnin++]=weighta[da];

		    if(rnin>=2*max-1)
			printf("mem overflow rnin=%d\n",rnin--);
		    }
	  }
  if(pop[d].num<ncrit*0.5)
    printf("\n");
  for(di=buf[db-1];db<maxn;db++)
     buf[db]=di;
  if(run>=0)
    fwrite(buf,maxn,sizeof(int),sp3);

   /* ------------------------------------ */
   /*     update coordinates and area      */
   /* ------------------------------------ */
  pop[dd].lon=(int)(lon*1.0/dn);
  pop[dd].lat=(int)(lat*1.0/dn);
  pop[dd].far=sin(pop[dd].lat*3.1415/DIMW1);
  pop[dd].num=pop[d].num;
  ar=calc_area(dd);
  sar+=ar;
  if(run>=0) {
      /* -------------------------------- */
      /*       output to region file      */
      /* -------------------------------- */
    fprintf(sp,"\n%d %d\t%d ",dd,pop[dd].num,ar*AREACELL);
    fprintf(sp,"%d %d\t %d\t",pop[dd].lon,pop[dd].lat,rnin);
      /*fprintf(sp,"\n"); */
    }
  if(rnin>0)
     /* ------------------------------------------- */
     /*   append neighbor index and border-length    */
     /* ------------------------------------------- */
    for(dni=0;dni<rnin;dni++) {
      bl=sqrt(ar*AREACELL*1.0/pop[dd].num)+sqrt(calc_area(rni[dni])*AREACELL*1.0/pop[rni[dni]].num);
      bl*=0.5*rnf[dni];

      if(run>=0) fprintf(sp,"%d:%1.1f\t",rni[dni],bl);
      }
  } /* end loop regions */

memcpy(newocc,occ,DIM1*DIM2*sizeof(unsigned int));
free(rnf),free(rni),free(six),free(siy);
printf("\n%d %1.2f %d %1.0f\n",(int)fabs(run),simil,inew,sar*1.0/inew);
if(run>=0) fprintf(sp2,"%d %1.2f %d %1.0f\n",(int)fabs(run),simil,inew,sar*1.0/inew);
/*  fprintf(sp2,"%d %d %d %1.0f\n",(int)fabs(run),ngoal,inew,sar*1.0/inew);
 */
if(run>=0) fclose(sp),fclose(sp3),fclose(sp2);

}

/* ------------------------------------------------------------------------------ */

/* ----------------------------------------------------- */
/*      find position of an arbitrary cell of region     */
/* ----------------------------------------------------- */
int find_regcell(int d) {
  int dd,dl,dn,da,dx,dy,ds,ds0,dx1,dy1;
  int found,d1x,d2x,d1y,d2y;
  /* set search window for initial pop position */

  d1x=(pop[d].lat-ncrit);
  d2x=(pop[d].lat+ncrit);
  if(d1x<0) d1x=0;
  d1y=(pop[d].lon-ncrit);
  d2y=(pop[d].lon+ncrit);
  if(d1y<0) d1y=0;

  for(found=0,dx=d1x;dx<d2x;dx++)    /* scan search window  */
    for(dy=d1y;dy<d2y;dy++)
      if(occ[dx%DIM1][dy%DIM2]==d+1) /* found an arbitrary cell of region */
	{
	  pos[0]=dx%DIM1,pos[1]=dy%DIM2;
	  found=1;
	  newocc[dx%DIM1][dy%DIM2]=99999+d;
	  dx=dy=99999;
	}
  if(found==0)
    {
      printf("pop %d not found in %d-%d:%d-%d\n",d,d1x,d2x,d1y,d2y); 
      for(found=0,dx=0;dx<dlat;dx++)
	for(dy=0;dy<dlon;dy++)
	  if(occ[dx][dy]==d+1) /* found an arbitrary cell of region */
	    {
	      pos[0]=dx,pos[1]=dy;
	      found=1;
	      newocc[dx][dy]=99999+d;
	      dx=dy=99999;
	    }
      if(found==0)
	printf("pop %d not found at all (%d %d) %d\n",d,pop[d].lon,pop[d].lat,pop[d].num);
    }
  return found;
}

