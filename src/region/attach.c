/*******************************************/
/*  GLUES  Region preparation package      */
/*  Kai W. Wirtz                09.01.2003 */
/*******************************************/
#include "defines.h"
#include "vars.h"

/**************************************************/
/*  add cells small regions to neighbor regions   */
/**************************************************/
void attach_cells(int loop, int island)
{
int found,d,dd,dl,dn,da,ia,is,dx,dy,dx0,dy0,ds0=-1,dx1,dy1,dn0,dr,dni,fds;
int *six,*siy,ncrit0;
unsigned long di,ds,irm[19600*NSTAT],im[NDIR];
double sinfl,max,af,arn,imn[NDIR],dynfac,diff1,diff2;
/*double weighta[9]={0.0,1,1,1,1,0.0,1.0,1.0,0.0};*/
double weighta[9]={0.0,1,1,1,1,0.71,0.71,0.71,0.71};
/*double weighta[9]={0.0,1,1,1,1,0.5,0.5,0.5,0.5};*/
FILE *sp;
fds=(int)(0.333*loop);  /* not used: minimium number of appications
                           before check for "steady state" */

 /* allocate cell pointer memory of connected land mass  */
di=8*ncrit*sizeof(int);
if((six=(int *)malloc(di))==NULL) err2exit("Failing mem allocation for six",di);
if((siy=(int *)malloc(di))==NULL) err2exit("Failing mem allocation for siy",di);
 
 /* ----------------------------------------------- */
 /*   store ncrit and change its effective value    */
 /* ----------------------------------------------- */
ncrit0=ncrit;

/* recursion loop until no improvement is made */  
for(dl=ds0=0;dl<=loop;dl++)
 {

 /* ------------------------------------------------------------- */
 /*   set dynamical factor to adiabatically increase patch size   */
 /* ------------------------------------------------------------- */ 
 dynfac=0.333+(double)dl/(dl+0.333*loop);
 if( dynfac>1) dynfac=1;

 ncrit=ncrit0*dynfac;

  /* copy old to new field for simultanious change */
 memcpy(newocc,occ,DIM1*DIM2*sizeof(unsigned int)); 
    /* find index of all subcritical regions */
 for(d=dr=0;d<nps;d++)
  if( pop[d].num>0 && calc_area(d)<ncrit) /* find small regions */
    if(dr++<19600*NSTAT)
      irm[dr-1]=d;
    else
      err2exit("\ntoo much cells (%d>%d) of small regions\n",dr);
 write_log("ncrit=",ncrit);
/* printf("%d %d %d %d\n",dl,loop,ncrit,ncrit0);*/
 write_log("cell based attachment of regions:",dr);

/*  printf("cell based attachment of %d regions ...\n",dr); */
/* for(da=0;da<dr;da++)  */
/* printf("%d(%d) ",irm[da],pop[irm[da]].num); */
/*  printf("\n"); */

/* find cells of all subcritical regions */

/* printf("%d ncell=%d\t",dr,ds); */
/**********************************/
/*   check for small island       */
/**********************************/
/*  if((dl==loop || (ds==ds0 && dl>fds))&&(1==1)) */
 if(dl==loop-1 && island)
  {
/*   printf("omitt %d islands smaller than %d ...\n",dr,ncrit); */
  write_log("omitt islands",dr);
  for(dx=0;dx<dlat;dx++)
   for(dy=0;dy<dlon;dy++)
    if((is=occ[dx][dy])>0)
      for(da=0;da<dr;da++)  /* scan all pops */
	if(is==irm[da]+1)
	  {
        /* ------------------------------------------------ */
        /*   find cluster of connected cells with same pop  */
        /* ------------------------------------------------ */
          dn=1;dn0=af=0;
/*   printf("search %d at %d %d\t(%d %d)\n",is,dx,dy,newocc[dx][dy],da); */
          six[0]=dx,siy[0]=dy;
          while(dn>dn0 && dn<4*ncrit && af<1.01*ncrit)  /* connected landmass below threshold ? */
            for(dd=dn0,dn0=dn;dd<dn0;dd++)
              for(dx0=six[dd],dy0=siy[dd],ia=1;ia<9;ia++)  /* scan all neighbors */
                {
                dx1=(dx0+dirx[ia]+DIM1)%DIM1;  /* x/y coordinate of neighbor */
                dy1=(dy0+diry[ia]+DIM2)%DIM2;
                di=newocc[dx1][dy1];
/*   printf("\t %d(%d) at %d %d\n",di,occ[dx1][dy1],dx1,dy1);  */
                if(di>0 && di!=199*dx+dy)
                  {
	          newocc[dx1][dy1]=199*dx+dy;
                  six[dn]=dx1,siy[dn++]=dy1;
   	          if(dn>8*ncrit-2) printf("dn = %d \t%d %d\t%d %d\n",dn--,dx,dy,dx1,dy1);
                  af+=pop[di-1].far;         /* area of cluster */
                  }
	        }
/*  printf("dn=%d dn0=%d af=%1.1f nc=%d\n",dn,dn0,af,ncrit); */
/*      if(d%50==49) getchar(); */
          if(af<0.99*ncrit)  /* small island !! */
            for(dd=0;dd<dn0;dd++)
             {
             dx1=six[dd],dy1=siy[dd];
/* 	     if(da==-137 || dd==2) */
/*   printf("omitt island cell %d/%d\t%d %d\t %d %d\t%d %d\n",dd,dn0,da,dn,dx1,dy1,irm[da],occ[dx1][dy1]);  */
	     if((di=occ[dx1][dy1])>0)
               if(di<=NPOP)
	         pop[di-1].num=0;
               else
	         printf("occ %d/%d too high %d %d\n",di,dn0,dx1,dy1);
    	     map[dx1][dy1]=occ[dx1][dy1]=newocc[dx1][dy1]=0;
             }
          da=dr;
          }
  } /* end if delete islands */
/**********************************/
/*      find best neighbor        */
/**********************************/
 else
  {
  for(dx=ds=0;dx<dlat;dx++)
   for(dy=0;dy<dlon;dy++)
    if((di=occ[dx][dy])>0)
      for(da=0;da<dr;da++)  /* scan all pops */
	if(di==irm[da]+1)
          {
          dn=0;
          if(calc_area(occ[dx][dy]-1)<ncrit) /* re-check subcritical area */
            for(ia=0;ia<NDIR;ia++)  /* scan all neighbors */
              {
              dx1=(dx+dirx[ia]+DIM1)%DIM1;  /* x/y coordinate of neighbor */
              dy1=(dy+diry[ia]+DIM2)%DIM2;
              if((is=occ[dx1][dy1])>0)
               if(pop[is-1].num>pop[di-1].num)

                {    /* similarity of locations  */
/*                 sinfl=1-simil*fabs(map[dx][dy]-map[dx1][dy1]); */
		diff1=fabs(pop[di-1].actmap-pop[is-1].actmap);
		diff2=fabs(pop[di-1].actmap2-pop[is-1].actmap2);
		sinfl=1-simil*(1-dynfac)*0.5*(diff1+diff2);
/* 		if(diff1>diff2)
 		     sinfl=1-simil*(1-dynfac)*diff1;
 		  else
 		     sinfl=1-simil*(1-dynfac)*diff2;*/
/*		sinfl=1-simil*(1-dynfac)*fabs(pop[di-1].actmap-pop[is-1].actmap);*/
                if(pop[is-1].num < 4*ncrit)
		   {
		   arn=(double)calc_area(is-1);
		   sinfl*=arn/(arn+0.5*ncrit);
                   }
                /* if(dl>fds && is==di) */  /* do not attach to same region */
                if( is==di)  /* do not attach to same region */
        	  sinfl=0;
                for(dni=found=0;dni<dn;dni++)
                   if(im[dni]==is)
                    imn[dni]+=weighta[ia]*sinfl,found=1;
                if(found==0)
        	  im[dn]=is,imn[dn++]=weighta[ia]*sinfl;
                }
/*             write_log("found small pop in region",di); */
            }
         /* --------------------------------- */
         /*   sum influence of all neighbors   */
         /* --------------------------------- */
          if(dn>0)
            {     
            for(dni=max=0,di=-1;dni<dn;dni++) 
              if(imn[dni]>max) max=imn[dni],di=dni;

            if(di>=0 && max>0.0)  /* set new pop index in region */
	       set_new_pop(dx,dy,im[di]);
            }
          }  /* end loop over lost cells */
   memcpy(occ,newocc,DIM1*DIM2*sizeof(unsigned int));
   }
 if(ds==ds0 && dl>fds &&1==0) break;  /* end loop if no change */
 ds0=ds;
 }
free(six);
free(siy);
ncrit=ncrit0;
/*     printf("attaching cells finished\n"); */
}

/* ---------------------------------------------------------------------*/

/******************************************/
/*  add small regions to bigger ones      */
/******************************************/
void attach_regions(int loop)
{
int d,dd,dl,dn,da,dx,dy,ds,ds0,dx1,dy1,dn0,dr,dni,dnd,fds;
int *six,*siy,found,d1x,d2x,d1y,d2y,ncrit0;
unsigned long di,irm[1960*NSTAT],im[NDIR],*rni,rnin;
double sinfl,max,imn[NDIR],*rnf;
double weightb[9]={0.0,1,1,1,1,0.5,0.5,0.5,0.5};
double weighta[9]={0.0,1,1,1,1,0.71,0.71,0.71,0.71};
double weightc[9]={0.0,1,1,1,1,0.0,1.0,1.0,0.0};

fds=(int)(0.333*loop);  /* minimium number of appications
                           before check for "steady state" */

 /* ----------------------------------------------------- */
 /*  allocate cell pointer memory of connected land mass  */
 /* ----------------------------------------------------- */
di=8*ncrit*sizeof(int);
if((six=(int *)malloc(di))==NULL) err2exit("Failing mem allocation for six",di);
if((siy=(int *)malloc(di))==NULL) err2exit("Failing mem allocation for siy",di);
rni=(long *)malloc(8*ncrit*sizeof(long));
rnf=(double *)malloc(8*ncrit*sizeof(double));

 /* ----------------------------------------------- */
 /*   store ncrit and change its effective value    */
 /* ----------------------------------------------- */
ncrit0=ncrit;

/* ------------------------------------------------ */
/*    recursion loop until no improvement is made   */
/* ------------------------------------------------ */
for(dl=ds0=0;dl<=loop;dl++)
 {
 ncrit=ncrit0*(0.333+(double)dl/(dl+0.333*loop));
 if(ncrit>ncrit0) ncrit=ncrit0;
/*   ncrit=ncrit0*(2.0/7+(double)dl/(dl+0.4*loop));*/
 /* ------------------------------------------------ */
 /*   copy old to new field for simultanious change  */
 /* ------------------------------------------------ */
 memcpy(newocc,occ,DIM1*DIM2*sizeof(unsigned int));
 /* ------------------------------------------ */
 /*    find index of all subcritical regions   */
 /* ------------------------------------------ */
 for(d=dr=0;d<nps;d++)
  if( pop[d].num>0 && calc_area(d)<ncrit) /* find small regions */
    if(dr++<1960*NSTAT)
      irm[dr-1]=d;
    else
      printf("\ntoo much (%d>%d) small regions\n",dr,1960*NSTAT);

 write_log("ncrit=",ncrit);
 write_log("re-attaching regions",dr);
/* printf("%d %d %d\n",dl,ncrit,ncrit0);*/

 for(d=0;d<dr;d++)
  if(calc_area(dd=irm[d])<ncrit)
   if(find_regcell(dd))
    {
    /* returns position of an arbitrary cell of region */
    six[0]=pos[0],siy[0]=pos[1];

/* ------------------------------------ */
/*   loop to find all connected cells   */
/* ------------------------------------ */
    dn=1;dn0=rnin=0;
    while(dn>dn0 && dn<5*ncrit-2)
     for(dnd=0,dn0=dn;dnd<dn0;dnd++)
       for(dx=six[dnd],dy=siy[dnd],da=1;da<9;da++)  /* scan all neighbors */
         {
	 dx1=(dx+dirx[da]+DIM1)%DIM1;  /* x/y coordinate of neighbor */
         dy1=(dy+diry[da]+DIM2)%DIM2; 
         if((di=occ[dx1][dy1])>0)
	   if(newocc[dx1][dy1]!=19999+d)
             if(di==dd+1)
	       {
	     /* ----------------------------- */
	     /*    mark new cell of cluster   */
	     /* ----------------------------- */
	       newocc[dx1][dy1]=19999+d;
	       six[dn]=dx1,siy[dn++]=dy1;
	       if(dn>8*ncrit-2) printf("dn = %d \t%d %d\t%d %d\n",dn--,dx,dy,dx1,dy1);
	       }
             else   /* average neighbor */
	       {
               for(dni=found=0;dni<rnin;dni++) 
                 if(rni[dni]==di-1)
                   rnf[dni]+=weighta[da],found=1;
               if(found==0) 
	           rni[rnin]=di-1,rnf[rnin++]=weighta[da];
               if(rnin>=8*ncrit-1)
                   printf("mem overflow rnin=%d\n",rnin--); 
               }
	 }
/*   printf("%d(%d) %d\n",dn,dn0,rnin);  */
/* -------------------------------------------- */
/*  attach cluster of cells to new population   */
/* -------------------------------------------- */
    if(rnin>0)
     {
     for(dni=max=0;dni<rnin;dni++) 
       if(rnf[dni]>max) max=rnf[dni],da=dni;
     write_log("transfer to region",rni[da]+1);

     for(dn=0;dn<dn0;dn++)     /* shift single cells to selected region */
       {
       dx=six[dn],dy=siy[dn];
/*       printf("%d %d\t",dx,dy);  */
       set_new_pop(dx,dy,rni[da]+1);
       occ[dx][dy]=rni[da]+1;
       }
    }
   else
      printf("no neighbor found for %d(%d/%d) y=%d x=%d\n",dd,pop[dd].num,
                              calc_area(dd),pop[dd].lat,pop[dd].lon);
   } /* end loop regions */

 memcpy(newocc,occ,DIM1*DIM2*sizeof(unsigned int));

 /*if(dr==ds0 && dl>fds) break; */ /* end loop if no change */
 ds0=dr;
 }/* end loop algorithm */

free(rnf);
free(rni);
free(six);
free(siy);

}
