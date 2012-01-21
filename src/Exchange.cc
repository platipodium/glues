/********************************************************
 * GLUES						*
 * Global Land-Use & technological Evolution Simulator	*
 * Program UnCRiM                                       *
 * Understanding Civilization Rise Model                *
 *						       	*
 * \author  Kai Wirtz <wirtz@icbm.de>                   *
 * \author Carsten Lemmen <c.lemmen@fz-juelich.de>      *
 *\file  spread.cpp                                     *    
 *\brief Migration Module of GLUES
 *\date  26.06.2001                                     *
 *******************************************************/
#include "Exchange.h"
#ifdef USE_EXCHANGE
//namespace glues {

Exchange::Exchange(unsigned int n) 
{
  if (exchange!=NULL) return;
  exchange=new double*[n];
  for (unsigned int i=0; i<n; i++) exchange[i]=new double[N_POPVARS];
  migration=new double[n];
}

Exchange::~Exchange()
{
  unsigned int i=0;
  while (exchange[i++,0]) delete[] exchange[i];
  delete [] exchange;
  delete [] migration;
}

  /* Calculate the twoway exchange between a regional population. 
     (source) and one of its neighbours (target). Returns the net number 
   of migrating people from/into source */

double Exchange::Twoway(RegionalPopulation& source, RegionalPopulation& target) {
  
  GeographicalNeighbour* neigh;
  PopulatedRegion* t_region,*s_region;
  unsigned int found=0;
  float s_area,t_area,s_tech,t_tech,s_dens,t_dens,s_rgr,t_rgr;
  float s_impact,t_impact,t_influence,s_influence,influencediff;
  float force,exchangerate,exporter_tech,iarea,jarea;
  float emigration,immigration,remotemigration;  
  float meaninfluence;
  
  unsigned int t_id,s_id,exporter,importer;
  

  s_region=source.Region();
  t_region=target.Region();
  t_id =  t_region->Id();
  neigh=  s_region->Neighbour();

  while (neigh)
    if(neigh->Region()->Id() == t_id) found=1; else neigh->Next();
  
  if (!found) return 0;

  s_id     = s_region->Id();
  s_area   = s_region->Area();
  t_area   = t_region->Area();
  s_tech   = source.Technology();
  t_tech   = target.Technology();
  s_dens   = source.Density();
  t_dens   = target.Density();
  s_rgr    = source.Growthrate();
  t_rgr    = target.Growthrate();
    
    /* Calculation of influence according to Hardin */
  s_influence = s_tech * s_dens;
  t_influence = t_tech * t_dens;
  
    /* Colonization pressure/impact (product of area and infuence for
       source and target regions. Impact of neighbour is set to zero
       if the source's rgr is negative and less than the neighbour's
       (for reference see WL03 p. 343)*/

    s_impact = s_influence * s_area;
    t_impact = t_area * t_influence ;
    
    
    if ( s_rgr<t_rgr && s_rgr <= EPS && LocalSpread<=1 ) t_impact=0.0;
    
    meaninfluence = (s_impact + t_impact)/(s_area+t_area);
    
    
    exchangerate    = spreadv*neigh->Length()/sqrt(s_area*t_area);
    force = exchangerate * (meaninfluence - s_influence);
    
    
    if ( t_rgr<s_rgr &&  t_rgr <= EPS && LocalSpread<=1 ) {
      force =  exchangerate * t_impact/(s_area+t_area);
    } 
    
    
    influencediff = (s_impact + t_impact)/(s_area+t_area)-s_influence;
    if ( s_rgr<t_rgr && s_rgr <= EPS && LocalSpread<=1 )  influencediff=0.0;
    else if ( t_rgr<s_rgr && t_rgr <= EPS && LocalSpread<=1 )  influencediff=0.0;
    
    exchangerate    = spreadv*neigh->Length()/sqrt(s_area*t_area);
    force = exchangerate * (influencediff);
    
    /* Migration consists of two parts, emigration (force<0) and
       immigration (force>0).  */
    
    emigration   = force;
	// TODO: iarea and jarea should be sarea or tarea
    immigration = -iarea/jarea * force;
    
    /* Identify source and target for unidirectional transport and
       for scaling with exporter's technology */
    
    if(force<0) {
      remotemigration=immigration;
      exporter_tech=s_tech;
      exporter=s_id;
      importer=t_id;
    }
    else {
      remotemigration=-emigration;
      exporter_tech=t_tech;
      exporter=t_id;
      importer=s_id;
    }
    
    emigration/=exporter_tech;
    immigration/=exporter_tech;
    
    /* Two way exchange for population */
    exchange[s_id][4]+=emigration*s_dens;
    exchange[t_id][4]+=immigration*t_dens;
    migration[s_id]+=fabs(emigration*s_dens);
    migration[t_id]+=fabs(immigration*t_dens);
       
    /* Unidirectional export to receiver region */
    exchange[importer][0]+=Traitspread(s_tech,t_tech,remotemigration);
    exchange[importer][1]+=Traitspread(source.Ndomesticated(),target.Ndomesticated(),remotemigration);
    exchange[importer][2]+=Traitspread(source.Qfarming(),target.Qfarming(),remotemigration);
    exchange[importer][5]+=Traitspread(source.Germs(),target.Germs(),remotemigration);
    
    /* Special treatment for resistance */
    exchange[importer][5]+=Genospread(source.Resist(),target.Resist(),exporter_tech,remotemigration); 
      
  return fabs(emigration*s_dens*s_area);
  
}

/*-----------------------------------------------*/
/*   calc exchange rate for adoptable  traits    */
/*-----------------------------------------------*/
inline double Exchange::Traitspread(double it,double jt, double rm) {
  return spreadm*(it-jt)*rm;
}

/*---------------------------------------------------*/
/*  calc exchange rate for genotype characteristics  */
/*---------------------------------------------------*/
inline double Exchange::Genospread(double it,double jt,double exporter_tech, double rm
) {
  return (it-jt)*rm/exporter_tech;
}

//}
#endif
/** EOF Exchange.cc */
