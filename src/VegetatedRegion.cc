/************************************************************************
 *									
 * @file  VegetatedRegion.cc
 * @brief Definitions for methods in  class VegetatedRegion
 * @author Carsten Lemmen <c.lemmen@fz-juelich.de>
 * @author Kai Wirtz <wirtz@icbm.de>
 * @date 2002-12-13
 * 
 * This file is part of GLUES, the Global Land Use 
 * and Environmental Change Simulator					 
 *
 ************************************************************************/

/** PREPROCESSOR section **/
#include "Symbols.h"
#include "VegetatedRegion.h"

/** Implementation section, Constructors and  Destructor **/
/** Vollst?ndiger Konstruktor */

VegetatedRegion::VegetatedRegion() 
    : GeographicalRegion(),continent(0) {}

VegetatedRegion::VegetatedRegion(std::istream& is) 
    : GeographicalRegion(is) {
    climate.Npp(0);
    climate.Tlim(0);
    climate.Lai(0);
    continent=0;
    fluctuation=1.0;
}  

VegetatedRegion::VegetatedRegion(const std::string& line ) 
  : GeographicalRegion(line)  {
  climate.Npp(0);
  climate.Tlim(0);
  climate.Lai(0);
  continent=0;
    fluctuation=1.0;
}  

VegetatedRegion::VegetatedRegion(double npp,double tlim,double lai,
  unsigned int index,unsigned int contid, double area, double lat,double lon) 
  : GeographicalRegion(index,contid,area,lat,lon) {
  climate.Npp(npp);
  climate.Tlim(tlim);
  climate.Lai(lai);  
    fluctuation=1.0;
}

VegetatedRegion::VegetatedRegion(const VegetatedRegion& vr) 
    : GeographicalRegion(vr) {
    climate=vr.climate;
    continent=vr.continent;
    contndommax=vr.contndommax;
    exploit=vr.exploit;
    icefraction=vr.icefraction;
    fluctuation=vr.fluctuation;
}  

VegetatedRegion::~VegetatedRegion() {
    delete [] continent;
  ;
}

/** Implementation section, other Methods **/
int VegetatedRegion::Climate(double l, double np, double tl) {
  climate.Npp(np);
  climate.Lai(l);
  climate.Tlim(tl);
  return 1;
}
        
int VegetatedRegion::InterpolateClimate(double time,double pasttime,double futuretime,
					const glues::RegionalClimate& pastclimate,
					const glues::RegionalClimate& futureclimate) {

  double pastweight,futureweight;

  if (pasttime==futuretime) {
    climate.Lai(pastclimate.Lai());
    climate.Npp(pastclimate.Npp());
    climate.Tlim(pastclimate.Tlim());
    //cout << "No interpolation required in climate update" << endl;
    return 1;
  }

  if (time==futuretime) {
    climate.Lai(futureclimate.Lai());
    climate.Npp(futureclimate.Npp());
    climate.Tlim(futureclimate.Tlim());
    //cout << "No interpolation required in climate update" << endl;
    return 1;
  }

  pastweight   = fabs((double)(futuretime-time))/(futuretime-pasttime);
  futureweight = fabs((double)(time-pasttime))  /(futuretime-pasttime);
  
  if (1.0-(pastweight+futureweight) > 0.001) {
    cout << "FATAL: weights "<< pastweight << " and " << futureweight 
	 << " do not add up to 1.0" << endl;
    return 0;
  }

  climate.Npp(pastweight*pastclimate.Npp()+futureweight*futureclimate.Npp());
  climate.Tlim(pastweight*pastclimate.Tlim()+futureweight*futureclimate.Tlim());
  //climate.Lai(pastweight*pastclimate.Lai()+futureweight*futureclimate.Lai());
  //climate.Gdd(pastweight*pastclimate.Gdd()+futureweight*futureclimate.Gdd());
  return 1;
}

/* ------------------------------------------------------- */
/*     Returns NPP dependend number of different 
       domesticable species = agricultural economies    */
/* ------------------------------------------------------- */
double VegetatedRegion::SuitableSpecies() const {
  return climate.SuitableSpecies();
}

double VegetatedRegion::SuitableTemp() const {
  return climate.SuitableTemp();
}
/* -------------------------------------------------- */
/*     Returns potential fertility dependend on
                       Net Primary Productivity       */
/* -------------------------------------------------- */
double VegetatedRegion::NatFertility(double factor) const {
  return climate.NatFertility(factor);
}


/* -------------------------------------------------- */
/*   Calculates (over)exploitation and regeneration   */
/* -------------------------------------------------- */
int VegetatedRegion::NewExploit(double newexp,int regon, double deltat) {
  if(newexp>exploit || regon==0)  exploit=newexp;
  else exploit+=regenerate*(newexp-exploit)*deltat;
  return 1;
}

int VegetatedRegion::Write(FILE* resfile,int id) const {
    double ndompot=ContNdommax()*SuitableSpecies()*SuitableTemp();
  double fert=NatFertility(1.0)*climate.Tlim();
  fprintf(resfile,"%3d\t",id);
  fprintf(resfile,"%1.3f %1.3f %1.1f %1.2f\n",ndompot,fert,climate.Npp(),climate.Tlim());
  //fprintf(resfile,"%1.2f\t%1.2f\t",(float)civid,ndompot);
  //fprintf(resfile,"%1.2f\t%1.2f\n",npp,tlim);
  return 1;
}

std::ostream& operator<<(std::ostream& os, const VegetatedRegion& reg) {
  return os << "R "  	<< reg.Id()
  	    << " (npp=" << reg.Npp()
  	    << "|T="	<< reg.Tlim()
  	    << "|A=" 	<< reg.Area() << ")";
}

/** EOF VegetatedRegion.cc */
