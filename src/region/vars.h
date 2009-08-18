extern int lon1, lon2,lat1,lat2;  /* coordinates of focus region */
extern unsigned int occ[DIM1][DIM2],newocc[DIM1][DIM2],domap[DIMW1][DIMW2];
extern unsigned long intl;
extern int dlat,dlon,ncrit,ngoal,inum,first_xcall;
extern unsigned long sump,nps,end,intl;
extern struct {double newmap;double newmap2;double actmap;double actmap2;double far;int lat;int lon;int num;} pop[NPOP];
extern int dirx[9],diry[9],pos[2],myindex;
extern double simil,map[DIM1][DIM2],map2[DIM1][DIM2];
extern unsigned char *dfmap;
void write_log(char*, int);
extern float *lat,*lon,npp_c[DIMW1][DIMW2],gdd_c[DIMW1][DIMW2];
