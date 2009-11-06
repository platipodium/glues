/*******************************************/
/*  GLUES  Region preparation package      */
/*  Kai W. Wirtz                09.01.2003 */
/*******************************************/

/** Usage
  region fac0 fac1 dfac
  @param fac0 starting variation (default 44)
  @param fac1 end variation (default 44)
  @param dfac variation step (default unset)
*/
  
#include "defines.h"

double simil,map[DIM1][DIM2],map2[DIM1][DIM2];
int dlat,dlon,ncrit,ngoal,inum,pos[2],myindex=0;
int in,lon1=0,lon2=DIM2,lat1=0,lat2=DIM1;
/* lon1=584,lon2=670,lat1=202,lat2=272;   *//* coordinates of focus region */
int dirx[9]={0,1,0,-1,0,1,1,-1,-1},diry[9]={0,0,1,0,-1,1,-1,-1,1};
unsigned int ar,domap[DIMW1][DIMW2],occ[DIM1][DIM2],newocc[DIM1][DIM2];
float *lat,*lon,npp_c[DIMW1][DIMW2],gdd_c[DIMW1][DIMW2];
unsigned char *dfmap;
unsigned long sump,nps,end,intl,rmax;
struct {
  double newmap;
  double newmap2;
  double actmap;
  double actmap2;
  double far;
  int lat;
  int lon;
  int num;
} pop[NPOP];

int main(int argc,char **argv)
{
  double time,dt,prob,max,inv0,inv,iet,sim,diff1,diff2,imn[NDIR];
  unsigned long i,ds,cd1,cd2,step,stepf,step2,dout,im[NDIR];
  int found,fac,dx1,dy1,de,d,dd,di,dn,dni,dr;
  int dy,dx,dy0,dx0,da,*test,nn;
  /* Default parameters as arguments */
  int fac0=44,fac1=44,dfac=1;
  
  double weight[9]={0.25,1,1,1,1,0.71,0.71,0.71,0.71};
  /*double weight[9]={0.25,1,1,1,1,0.0,1.0,1.0,0.0};*/
  FILE *sp;
  char buf[99];


/*lon1=330,lon2=520,lat1=30,lat2=150;*/
  
  /* Initialize log file (to variable buf) */
  init_log();
    
/******************************************/
/*   setting of some parameters           */
/******************************************/
  step=30*(1+SAGE*7); end=13*step;
  step2=500;
  inv0=inv=1.0; /* ground probability for entering alien location */
  iet=0.0/(6*step);  /* inverse half inv time, not used */
  simil=20;  /* 234: 16,60 */
  l0=4722; /*lon2=DIM2; lat2=DIM1;*/
  ncrit=2000; ngoal=4000;
    
/*-------------------------------------------------*/
/*    define variation or type of application      */
/*-------------------------------------------------*/
/* for(i=0;i<12;i++) {
  read_gluesclimate_bin("gluesclimate.bin",i,0);
  show_map(-1,argv);} exit(0);
*/
    
  if(argc>=4) {
   fac0=atoi(argv[1]),fac1=atoi(argv[2]),dfac=atoi(argv[3]);
  } 
  else if(argc>=2) {
    convert_bin("npp_08000.tab",argv,1);  /* converts all ClimberASCCII to binary */
  }

  sprintf(buf,"variation: from %d to %d by %d\t argc=",fac0,fac1,dfac);
  write_log(buf,argc);
    
  /*************************************/
  /*   Initialising topography         */
  /*************************************/
  if(1==0) {
    read_etopo_map("ETOPO05.dat",1);
  }  
  else if(SAGE) { /*  load compiled map for new region */
    read_sage_map("hist_maps/sage/potveg/glpotveg_5min.asc",1);
  }
  else {      /*  load CLIMBER modeled map for new region */
    read_gluesclimate_bin("gluesclimate.bin",22,0);
  }
  
  /* show_map(-1,argv); */
  /*   read_climber_map("npp_08000.tab",1);*/


  /*----------------------------------*/
  /*          variation loop          */
  /*----------------------------------*/
  for(fac=fac0;fac<=fac1;fac+=dfac)
  {
    init_regions(1);
    /*----------------------------------*/
    /*      show background map         */
    /*----------------------------------*/
#ifdef HAVE_MAGICK
    show_map(-1,argv),myindex++;  /* show_map(-1,argv);*/
#endif

  /* show_map(0,argv);*/
  /*----------------------------------*/
  /*   set variation parameters       */
  /*----------------------------------*/
  if(SAGE==0)
      ngoal=10*pow(1.05,fac),ncrit=6+ngoal*ngoal/(ngoal+400);
  else
      ngoal=50*pow(1.4,fac),ncrit=ngoal*6000.0/(ngoal+3000);
  
  printf("%d goal=%d ncrit=%d simil=%1.1f\n",fac,ngoal,ncrit,simil);
  sprintf(buf,"%d goal=%d ncrit=%d\n",fac,ngoal,ncrit);
  write_log(buf,SAGE);
  
  /********************************************/
  /*   Haupt-Zeitschleife                     */
  /********************************************/
  for(ds=dout=0;ds<=end;ds++)
  {
      /*  add small regions to bigger ones after 1st steady state    */
      if(ds==8*step)
      {
/*         displaymap(argv[0],dfmap,dlat,dlon,1,0); */
    attach_cells((int)(NPOP*0.025/ncrit),1);
    attach_regions(8);
    /*     printf("attaching regions finished\n"); */
/*    dx=132;dy=437; printf("%d ... %d %d\n",occ[dx-10][dy],occ[dx][dy],occ[dx+1][dy]);
      printf("%1.3f %1.3f \n",map[dx][dy],pop[occ[dx][dy]-1].actmap);*/
      }
      if(ds==end)  /* final wash-up of small regions */
    attach_regions(4);
      
      /*******************************/
      /*     show various results    */
      /*******************************/
      if(ds%step==0)
      {
    printf("%ld/%ld start calc ...\n",ds,end);
    rmax=calc_distribution((int)ds);
    if(MAGICK &0) show_map(1+ds,argv);
      }
      
      memcpy(newocc,occ,DIM1*DIM2*sizeof(unsigned int));
      /********************************************************/
      /*   walking like an Egyptian ....                      */
      /********************************************************/
/*      inv=inv0*exp(-iet*ds);*/
      for(dx=cd1=cd2=0;dx<dlat;dx++)
    for(dy=0;dy<dlon;dy++)
        if((dd=occ[dx][dy])>0)
        {
      dn=0; found=1;
      if(ds>2*step)   /* pre-check for border cell to enhance speed */
          found=check_border(dx,dy,dd);
      if(found==1)  /* cell at region border */
          for(da=0,cd1++;da<NDIR;da++)  /* scan all neighbors */
          {
        dx1=(dx+dirx[da]+DIM1)%DIM1;  /* x/y coordinate of neighbor */
        dy1=(dy+diry[da]+DIM2)%DIM2;
        if((di=occ[dx1][dy1])>0)
        {                /* check for same population */
            /* similarity of locations  */
            diff1=fabs(pop[occ[dx][dy]-1].actmap-pop[occ[dx1][dy1]-1].actmap);
            diff2=fabs(pop[occ[dx][dy]-1].actmap2-pop[occ[dx1][dy1]-1].actmap2);
            sim=1-simil*0.5*(diff1+diff2);
/*      if(diff1>diff2)
      sim=1-simil*diff1;
      else
      sim=1-simil*diff2; */
            
/*     sim=1-simil*fabs(map[dx][dy]-map[dx1][dy1]);*/
            
            if(sim<0) sim=0;
            /*  sim*=(1.0+0.0*random2()); */ /* add randomness */
            
            /* ----------------------------- */
            /*           add influence       */
            /* ----------------------------- */
            ar=calc_area(di-1);
            sim*=(1-inv)+ar*inv/(ar+ngoal);
/*           sim*=(1-inv)+inv*sqrt(pop[di-1].num);  */
            
            for(dni=found=0;dni<dn;dni++)
          if(im[dni]==di)
              imn[dni]+=weight[da]*sim,found=1;
            if(found==0)
            {
          im[dn]=di;
          imn[dn++]=weight[da]*sim;
            }
        }
          }
      /* sum influence of all neighbors */
      if(dn>0)
      {
          for(dni=max=0,di=-1;dni<dn;dni++)
        if(imn[dni]>max) max=imn[dni],di=dni;
          /* ------------------------------------ */
          /*      set new pop myindex in region     */
          /* ------------------------------------ */
        if(di>=0 && max>0.0 && im[di]!=dd) {
          set_new_pop(dx,dy,im[di]);
        }
      }
    }
    /*   printf("%ld %ld\n",cd1,cd2); */
    memcpy(occ,newocc,DIM1*DIM2*sizeof(unsigned int));
    for(dn=0;dn<nps;dn++) {
      pop[dn].actmap=pop[dn].newmap,pop[dn].actmap2=pop[dn].newmap2;
    }  
  /* show_map(0,argv);myindex++;  */ 
      
  }
  /* displaymap(argv[0],domap,DIM1,DIM2,4,99); */
  if(MAGICK & 0)  show_map(0,argv);
  dump_map();
  /*if(MAGICK)*/
/*     displaymap(argv[0],dfmap,dlat,dlon,1,0); */
   
  /* calc center and area incl border length to neighbors  */
  calc_regions(rmax,fac);
   
  /* write average NPP and GDD to  txt files */
  out_region_npp(0);
   
  /* else displaymap(argv[0],dfmap,dlat,dlon,1,100+fac);*/
  printf("%d / %d\n",fac,fac1);
   
#ifdef HAVE_MAGICK
   show_map(0,argv);
#endif
  }
  return 0;
}

/* EOF */