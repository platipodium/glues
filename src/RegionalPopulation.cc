/* GLUES regional population class; this file is part of
   the Global Land Use and technological Evolution Simulator
   
   Copyright (C) 2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012
   Carsten Lemmen <carsten.lemmen@hzg.de>, Kai Wirtz <kai.wirtz@hzg.de>

   This program is free software; you can redistribute it and/or modify it
   under the terms of the GNU General Public License as published by the
   Free Software Foundation; either version 2, or (at your option) any later
   version.

   This program is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
   Public License for more details.

   You should have received a copy of the GNU General Public License along
   with this program; if not, write to the Free Software Foundation, Inc.,
   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
*/
/**
   @author Carsten Lemmen <carsten.lemmen@hzg.de>
   @author Kai Wirtz <kai.wirtz@hzg.de>
   @file  RegionalPopulation.cc
   @brief  Definition of regional population
   @date 2012-05-08
   
*/

/** PREPROCESSOR section **/
#include "Symbols.h"
#include "RegionalPopulation.h"
#include "Constants.h"
#include "variables.h"
#include "Globals.h"

//namespace glues {

/**
   Constructor for creation of RegionalPopulation object without parameters
*/
RegionalPopulation::RegionalPopulation() {
  density = 0;
  growthrate = 0;
  technology = 0;
  qfarming = 0;
  ndomesticated = 0;
  ndommax = 0;
  biondommax = 1;
  region = 0;
  actualfertility=tlim=0;
  germs=1;
  resist=0;
  size=0;
}


double RegionalPopulation::Tlim() {
  //
  //return tlim;
  region->Tlim();
  }

double RegionalPopulation::SubsistenceIntensity() {
	//return sqrt(technology)*(1-qfarming)+(region->Tlim()*technology)*ndomesticated*qfarming; 
	return sqrt(technology)*(1-qfarming)+(tlim*technology)*ndomesticated*qfarming; 
}


RegionalPopulation::RegionalPopulation(double s, double f,
     double t,double nd,double ge, double re,
     double bnm,double nf,double tl, PopulatedRegion* r)
{
  density = s;
  qfarming = f;
  technology = t;
  ndomesticated = nd;
  ndommax = bnm;
  biondommax = bnm;
  region = r;
  actualfertility=0;
  germs=ge;
  tlim=tlim0=tl;
  resist=re;
  naturalfertility=nf;
  size=region->Area()*density;
}

/**
   @fn ~RegionalPopulation()
   @brief Destructor
*/
RegionalPopulation::~RegionalPopulation() { ;
}

void
RegionalPopulation::Density(double pop) 
{ 
  density = pop;
  if (region != NULL) size=region->Area()*density; 
  else size=0;
}

double
RegionalPopulation::Technology(double tech) 
{ 
  technology = (tech>EPS?tech:EPS);
  return technology;
}

void
RegionalPopulation::Size(double s) 
{ 
  size=s;
  if (region != NULL) density=size/region->Area(); 
  else density=0;
}

double
RegionalPopulation::Size() const 
{ 
  if (region != NULL) return region->Area()*density; 
  else return 0;
}

/**
   @brief Rates of change for all variables
   @return largest relative change
*/
double RegionalPopulation::RatesOfChange(double *da)
{
  double ch,change;
  unsigned int i;
  
  /** time rate of changes in technology [0], ndomesticated [1],
      qfarming [2], resistance [3], density [4], and disease [5]
  */
  da[0]= deltat*drdT();
  da[1]= deltan*ndomesticated*(ndommax-ndomesticated)*drdN();
  da[2]= deltaq*qfarming*(1-qfarming)*drdQ();
  da[3]= deltar*(germs-resist)*resist*drdR();
  da[4]= rgr*density;
  da[5]= 0; // gammad*(1+qfarming*ndomesticated);
  
#define ENABLE_LITERACY 1
#ifdef ENABLE_LITERACY

    /**
       Implementation of cultural loss according
       to Wirtz (2008) Curr. Anthropol.
    */

  double literacy,rgrloss;
      
  if (rgr < 0 && KnowledgeLoss > 0)     {
    
    literacy=technology/LiterateTechnology;
    rgrloss=rgr*KnowledgeLoss*exp(-literacy); 
    
    da[0]= da[0] + rgrloss*technology;
    da[1]= da[1] + rgrloss*ndomesticated;
  }
  
#else
  /**
     Original implementation Wirtz & Lemmen 2003
     with no change 
  */
#endif
  
  /**  	
       Calculate and return the largest relative change
  */
  change=0;
  for(i=0;i<(unsigned int)N_POPVARS;i++)
    {
      ch = fabs(da[i]/(ev[i]+EPS));
      if (ch>change) change=ch;
    }
  return change;
}

/**
   @brief Overall development
*/
int RegionalPopulation::Develop(double step) {
  static double changerate[N_POPVARS];
  //static double traitvector[N_POPVARS];

	double change,nnew;
  //double time=0,change,ch,rt,literacy,loss_red,nnew;
	unsigned long i;
	//unsigned long i0=0,ri,nrec=1,reccount;
  
  /**  save old values  */
  CreateVector();

  /*  traitvector[0]=technology;
  traitvector[1]=ndomesticated;
  traitvector[2]=qfarming;
  traitvector[3]=resist;
  traitvector[4]=density;
  traitvector[5]=germs;*/
    
  /** 
      Calculate rates of change and largest rate of 
      change; if this is larger than the allowed
      relative change (parameter RelChange) then
      iterate a recursion with adjusted step
  */
  
  RelativeGrowthrate();
  change=RatesOfChange(changerate)*step;
  
  if (change > RelChange) {
    nnew=ceil(1.0+change/RelChange);
    step=step/nnew;
    cout << "Adaptive change: iterating " << nnew << " times" << endl;
    //cout << change << "/" << RelChange << "/" << step << "/" << changerate[1] << endl;
    //for (i=0; i<6; i++) cout << changerate[i] << "/" ;
    for (i=0; i<nnew; i++) Develop(step);
    return 0; 
  }
  
  for(i=0;i<N_POPVARS;i++) ev[i]+=step*changerate[i];
  
  if ( Update() ) return 1;
  
  /**
     Calculates (over)exploitation and regeneration
  */
  newexploit=overexp*density*sqrt(technology);
  region->NewExploit(newexploit);
  
  return 0;
}


/**
   @brief recalculate the relative growth rate of human population
   split up into fertilty and food productivity
*/
double RegionalPopulation::RelativeGrowthrate() {

  double literacy;
  double expo;
  //double tlim = region->Tlim();
  
  nrat = ndomesticated/(ndomesticated+1);
  art  = max(EPS,1-omega*technology);
  teff = technology;
  
  /**
     Effect of Holocene climate fluctuations on fertility
  */
  
  expo=(gdd_opt-tlim)/(0.5*gdd_opt);
  tlim= region->Fluctuation()*exp(-expo*expo);
  
  /**
     actual fertility accounts for cropland conversion
     exploitation history
  */
  ///naturalfertility  = region->NatFertility(fluctuation);
  naturalfertility  = region->NatFertility(region->Fluctuation());
  cropfertility = region->NatFertility(region->Fluctuation()*kappa/(1+region->Npp()));
  farmfert      = naturalfertility+0*(cropfertility-naturalfertility)*qfarming*tlim*nrat;
  
  /** 
      Implementation of WL2003, Eq 4 with
      exploitation and actual fertility

  */
  actexploit= overexp*sqrt(teff)*density;      
  actualfertility = max(EPS,farmfert - actexploit);
    

  /** 
      Implementation of WL2003, Eq 2 with
      product as subsistence intensity

  */
  product   = sqrt(teff)*(1-qfarming)+
    (tlim*technology)*ndomesticated*qfarming;

  /**
     Multiplication of SI with non-artisan fraction
  */
  product = product*art;
  
  /** 
      Implementation of WL2003, Eq 4 

      disease=gammad/technology*density;
      
      replaced with literacy-dependent exponential
      function, described by Lemmen 2011
  */
    literacy = technology/LiterateTechnology;
    disease   = (germs-resist)*density*exp(-literacy);
    //disease   = density*exp(-literacy);
  
  /** 
      Implementation of WL2003, Eq 4 with
      product=si*art
      rgr = gammab*actualfertility*product-disease
  */
  birthrate = gammab*actualfertility*product;
  deathrate = disease;
  rgr = birthrate - deathrate;
  
  return rgr;
}

/**
   @brief  Calculate growth gradient dr/dT
   @return gradient
*/
double RegionalPopulation::drdT() {
  double dydT,dpdT,dmdT; 
  
  dydT=-0.5*actexploit/technology;
  //dpdT=art*((1-qfarming)*0.5/sqrt(teff)+region->Tlim()*qfarming*ndomesticated);
  dpdT=art*((1-qfarming)*0.5/sqrt(teff)+tlim*qfarming*ndomesticated);
  dpdT-=omega*product/art;
 // dmdT=1.0*disease/teff;
  //  dmdT=disease*1./(LiterateTechnology);

  /** Original WL03 formulation */
  //dmdT=-gammad*density/technology/technology;
  
  /** replaced by exponential term */
  dmdT=-disease/LiterateTechnology;
  
  return gammab*(dydT*product+actualfertility*dpdT)-dmdT;
}

inline double RegionalPopulation::drdQ() {
    double dydQ=0,dpdQ,dmdQ=0;
  //dydQ=0.5*(cropfertility-naturalfertility)*region->Tlim()*nrat;//
  dydQ=0;
  
  dpdQ=-sqrt(teff)+(region->Tlim()*technology)*ndomesticated;
  dpdQ=-sqrt(teff)+(tlim*technology)*ndomesticated;
  return gammab*(dydQ*product+actualfertility*art*dpdQ)+dmdQ;
}

inline double RegionalPopulation::drdN() {
    double dydN=0,dpdN,dmdN=0;
  /*double nratd=ndomesticated+1;
    dydN=0.5*(cropfertility-naturalfertility)*region->Tlim()*qfarming/(nratd*nratd); */
    dpdN=(tlim*technology)*qfarming*art;
    //dpdN=(region->Tlim()*technology)*qfarming*art;
    //std::cerr << region->Tlim() << " " << tlim << std::endl;
    dpdN=(tlim*technology)*qfarming*art; // TODO for testing against 547
    return gammab*(dydN*product+actualfertility*dpdN)+dmdN; 
}

inline double RegionalPopulation::drdR() {
    return density/teff;
}

std::ostream& operator<<(std::ostream& os, const RegionalPopulation& pop) {
    return os 	<< "P " << *pop.Region() << "  B=" << pop.Growthrate()
  		<< " D=" << pop.Density() << " T=" << pop.Technology()
            	<< " F=" << pop.Qfarming() << " d=" << pop.Ndomesticated()
            	<< "/" << pop.Ndommax() << endl;
}

int RegionalPopulation::Write(FILE* resfile,int timeorid) {
  double npp 	= region->Npp();

  fprintf(resfile,"%5d ",timeorid);
  fprintf(resfile,"%5.2f %5.2f %5.2f %9.2e "
	  ,naturalfertility,actualfertility                     //2-5
	  ,product,growthrate);
  fprintf(resfile,"%5.2f %5.2f %5.2f %5.2f "  
	  ,density,technology,ndomesticated,qfarming); //6-9
  fprintf(resfile,"%5.0f %9.2e %5.2f %5.2f "
	  ,npp,rgr         //10-11
	  ,ndommax, region->Tlim()); // 12-13
  fprintf(resfile,"%5.2f %5.2f %5.2f\n"
	  ,germs,resist,disease // 14-16
	  );
  return 1;
}

/* -------------------------------------------------- */
/*      returns a indexed vector out of structure     */
/* -------------------------------------------------- */
double RegionalPopulation::IndexedValue(unsigned int index) {
double sprp;
  switch(index) {
  case 0: return technology;
  case 1: return ndomesticated;
  case 2: return qfarming;
  case 3: return resist;
  case 4: return density;
  case 5: sprp=sprdm[(region->Index()-0)]/OutputStep;
   if(sprp<0) sprp=-sprp;
   return sprp*1E3;
  case 6: return region->Npp();
  case 7: return region->CivStart();
  case 8: return germs-resist;
  case 9: return birthrate;
  }
  return -1.0;
}


/** 
    @brief updates the values of all effective
    variables and ensures that they are within bounds.
    @return 0 if successful, 1 if soft limits
    on technology, density or ndomesticated are crossed
*/
int RegionalPopulation::Update() 
{
  
  /**
     Update values of effective variables and consider
     minimum values
  */
  
  technology    = max(ev[0],0.5);
  ndomesticated = max(ev[1],minval[1]);
  qfarming      = max(ev[2],InitQfarm);
  resist        = max(ev[3],minval[3]);
  density       = max(ev[4],minval[4]);
  if (region != NULL) size=density*region->Area();
  germs         = max(ev[5],minval[5]);
  
  /** 
      Ensure we are below maximum bound 
      i.e. no more than 100% farming quota
      and minimal disease mortality
  */

  qfarming = min(qfarming,1.0);
  resist   = min(resist,germs-minval[5]);
  
  /* -------------------------------------------------- */
  /*    NEW: if ndomasticated exceeds ndomax,
	only the latter is adjusted !!!             */
  /* -------------------------------------------------- */
  ndommax=max(ndomesticated,ndommax);
  
/*  ndommax=min(ndommax,30.0);
    ndomesticated=min(ndommax,ndomesticated);
*/
  
  if ( density > 1E3 || technology> 2E2||ndomesticated>30 )
    return 1;
  else
    return 0;
}

/* -------------------------------------------------- */
/*      makes a indexed vector out of structure       */
/* -------------------------------------------------- */
void RegionalPopulation::CreateVector(void) {
  ev[0]=technology;
  ev[1]=ndomesticated;
  ev[2]=qfarming;
  ev[3]=resist;
  ev[4]=density;
  ev[5]=germs;
}

/** EOF RegionalPopulation.cc */


