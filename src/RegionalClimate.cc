/************************************************************************
 *									
 * @file  RegionalClimate.cc
 * @brief Definitions for methods in  class RegionalClimate
 * @author Carsten Lemmen <c.lemmen@fz-juelich.de>
 * @author Kai Wirtz <wirtz@icbm.de>
 * @date 2003-05-21
 * 
 * This file is part of GLUES, the Global Land Use 
 * and Environmental Change Simulator					 
 *
 ************************************************************************/

/** PREPROCESSOR section **/
#include "RegionalClimate.h"
#include "Globals.h"
#include "variables.h" // for variable kappa
#include "Constants.h" // for EPS

/** Implementation section, Constructors and  Destructor **/
/** Vollst?ndiger Konstruktor */

glues::RegionalClimate::RegionalClimate(double l,double np,double tl,double g, double t) {
  lai = (l  > 0 ? l :0);
  npp = (np > 0 ? np:0);
  tlim =(tl > 0 ? tl:0);
  gdd = (g  > 0 ? g:0);
  time = t;
}

glues::RegionalClimate::RegionalClimate(double l,double np,double tl,double g) {
    RegionalClimate(l,np,tl,g,0);
}

glues::RegionalClimate::RegionalClimate(double l,double np,double tl) {
    RegionalClimate(l,np,tl,0,0);

}

glues::RegionalClimate::RegionalClimate()  {
    RegionalClimate(0,0,1,0,0);
}

glues::RegionalClimate::~RegionalClimate() {
  ;
}

/** Implementation section, other Methods **/

/* -------------------------------------------------- */
/*     Returns potential fertility dependend on
                       Net Primary Productivity       */
/* -------------------------------------------------- */
double glues::RegionalClimate::NatFertility(double factor) const {
  return hyper(kappa*1.5,factor*npp,2);
  //return 4*nppt*kappa/(kappa*kappa*4+nppt*nppt); // sqrt(2)
}

/* ------------------------------------------------------- */
/*     Returns NPP dependend number of different
          domasticable species = agricultural economies    */
/* ------------------------------------------------------- */
double glues::RegionalClimate::SuitableSpecies() const {
  return hyper(kappa,ice_fac*npp,4);
}

/* ------------------------------------------------------- */
/*     Returns effect of GDD on number of
          domasticable species (annuals)   */
/* ------------------------------------------------------- */
/*?
double RegionalClimate::SuitableTemp2() const {
  double tlm,norm,tl1=1.5;
  
  norm=sqrt(tl1/2)*(tl1-sqrt(tl1/2));
  tlm=tlim;
  if (ice_fac<1) tlm*=ice_fac,tlm-=(1-ice_fac)*0.25;
  if (tlm<EPS) tlm=EPS;
  if (tlm>1-EPS) tlm=1-EPS;
return tlm*(tl1-tlm)/norm;
}
*/
double glues::RegionalClimate::SuitableTemp() const {
  double tlm;
 
// if (npp<700 && tlim>0.9) tl1=0.9;  // tropical grass 
 
  tlm=tlim;
  if (ice_fac<1) tlm*=ice_fac,tlm-=(1-ice_fac)*0.4;
  if (tlm<EPS) tlm=EPS;
  double expo=(gdd_opt-tlm)/(0.5*gdd_opt);

/*  return 2*tl2*tlm2/(tlm2*tlm2+tl2*tl2);*/
/*if(tlim<tlm) return tlim/tlm;*/
/*if(tlim<tlm) return tlim/tlm*tlim/tlm;
else return 1.0;*/
return exp(-expo*expo);
}


/**
 * @brief Calculates a hyperbolic function 
 */
double glues::RegionalClimate::hyper(double kap, double np, int n) const {
  double ka=pow(kap,n-1);
  return n*ka*np/(ka*kap*(n-1)+pow(np,n));
}

int glues::RegionalClimate::Write(FILE* resfile) {
  double nsuit=SuitableSpecies()*SuitableTemp();
  double fert =NatFertility(1.0)*tlim;
  fprintf(resfile,"%1.3f\t%1.3f\t%1.3f\t%1.3f\t%1.3f\n",npp,tlim,nsuit,fert,ice_fac);
  return 1;
}

std::ostream& operator<<(std::ostream& os, const glues::RegionalClimate& climate) {
  return os << " (npp=" << climate.Npp()
  	    << "|T="	<< climate.Tlim() << ")";
}
/** EOF RegionalClimate.cc */

