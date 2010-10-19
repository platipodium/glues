/* GLUES land region specification; this file is part of
   the Global Land Use and technological Evolution Simulator
   
   Copyright (C) 2007,2008,2009,2010
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
   @author Kai W Wirtz <kai.wirtz@hzg.de
   @file  LandRegion.cc
   @brief Definition of class LandRegion, based on the prior VegetatedRegion
   @date 2008-08-12
*/

/** PREPROCESSOR section */
#include "Symbols.h"
#include "LandRegion.h"

// void glues::LandRegion::Init(const double ice[4])
glues::LandRegion::LandRegion() 
    : GeoRegion(),continent(0) {}

glues::LandRegion::LandRegion(std::istream& is) 
    : GeoRegion(is),continent(0),climate(0.0,0.0,0.0) {
}  

glues::LandRegion::LandRegion(const std::string& line ) 
    : GeoRegion(line),continent(0),climate(0.0,0.0,0.0)  {
}  

glues::LandRegion::LandRegion(const glues::LandRegion& lr) 
    : GeoRegion(lr) {
    climate=lr.climate;
    continent=lr.continent;
    icefreefraction=lr.icefreefraction;
}  

glues::LandRegion::~LandRegion() {
    continent=0;
}

/** Implementation section, other Methods **/
/*int glues::LandRegion::Climate(double l, double np, double tl) {
  climate.Npp(np);
  climate.Lai(l);
  climate.Tlim(tl);
  return 1;
}
        
int glues::LandRegion::InterpolateClimate(int time,int pasttime,int futuretime,
					const LocalClimate& pastclimate,
					const LocalClimate& futureclimate) {

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

  //  climate.Lai(pastweight*pastclimate.Lai()+futureweight*futureclimate.Lai());
  if( climate.Npp()<-6500)
    printf("%1.1f %d\t%1.1f %d\t%d\t\t",pastweight,pasttime,futureweight,futuretime,time);

  climate.Npp(pastweight*pastclimate.Npp()+futureweight*futureclimate.Npp());
  climate.Tlim(pastweight*pastclimate.Tlim()+futureweight*futureclimate.Tlim());
  //climate.Lai(pastweight*pastclimate.Lai()+futureweight*futureclimate.Lai());
  return 1;
}


/* -------------------------------------------------- */
/*   Calculates (over)exploitation and regeneration   */
/* -------------------------------------------------- */
/*int glues::LandRegion::NewExploit(double newexp,int regon, double deltat) {
  if(newexp>exploit || regon==0)  exploit=newexp;
  else exploit+=regenerate*(newexp-exploit)*deltat;
  return 1;
  }*/



/**
   @function hyper
   @brief Calculates a hyperbolic function 
   @param n the order of the hyperbolic function
   @nppmaxlae the variable 
   @K the reference value
   @description The hyperbolic function of order n evaluates
   to 1 for all n if nppmaxlai=K
   $hyper = n*\nppmaxlai^(n-1)*K/(\nppmaxlai^n*(n-1)+K^n$
   

 */
double glues::LandRegion::hyper(double xmax, double x, unsigned int n)  {
    double tmp=pow(xmax,n-1);
    return n*tmp*x/(tmp*xmax*(n-1)+pow(x,n));
}

/*std::ostream& glues::operator<<(std::ostream& os,const glues::LandRegion& lr) {
    double nsuit=lr.SuitableSpecies()*lr.SuitableTemperature();
    double fert =lr.NaturalFertility(1.0)*lr.climate.Tlim();
    return os << lr.climate.Npp() << " " << lr.climate.Tlim() << " " << " " 
	      << nsuit << " " << fert << " " << lr.icefreefraction << " "
	      << nppmaxlae << " ";
	      }*/

std::ostream& glues::operator<<(std::ostream& os, const glues::LandRegion& lr) {
    /*  return os << (glues::GeoRegion)lr << " " << lr.climate.Npp() << " " 
	      << lr.climate.Tlim() << " " << lr.climate.Lai() << " " 
	      << lr.numcoasts ;*/
    return os << (glues::GeoRegion)lr ;
}

/**
   @return ice-free fraction within region
   
   From *.sce file:
   array   IceExtent
   d 1:rlat0  2:rlat2 3:lat_off 4:lon_off
   50.0	80.0	80.0	45.0
   typeOfArray     float
   dimension       4
*/
double glues::LandRegion::IceFraction() {
    double lat0=50,lat2=75;
    double fac,fac2;
    
    fac2 = hypot(iceextent[2]-latitude,iceextent[3]+longitude)/iceextent[1];
    fac = (90.-latitude)/iceextent[0];
    if(fac2<fac) fac=fac2;
	    if(fac>1)  { 
		fac = (90+latitude)/iceextent[0]; 
		if(fac>1)fac=1;
	    }
	    return icefreefraction=fac;
}

/**
   @return potential fertility
   dependent on Net Primary Productivity   
*/
double glues::LandRegion::NaturalFertility(double factor) {
    return hyper(nppmaxlae*1.5,factor*climate.Npp(),2);
}

/**
   @return food extraction potential
   dependent on Net Primary Productivity  
   with fep=2*x / (x^2 + 1) and 
   x=NPP/NPPf 
   NPPf= most profitable NPP for hunting
*/
double glues::LandRegion::FoodExtractionPotential() {
    return hyper(nppmaxfep,climate.Npp(),2);
}

/**
   @return local diversity in domesticables
   dependent on Net Primary Productivity  and temperature limitation
   with lae=tlim*(4*x) / (x^3 + 3) (WRONG in WL03)
   with lae=tlim*(3*x) / (x^3 + 2) better
   x=NPP/NPP*
   NPP*=npplaemax maximum diversity NPP
*/
double glues::LandRegion::LocalSpeciesDiversity() {
    return climate.Tlim()*hyper(nppmaxlae,climate.Npp(),3);
}

/**
   Returns NPP dependend number of different
   domesticable species = agricultural economies  
*/
double glues::LandRegion::SuitableSpecies() {
    return hyper(nppmaxlae,icefreefraction*climate.Npp(),4);
}


double glues::LandRegion::SuitableTemperature()  {
    double tlm;
    double gddopt;
    
// if (npp<700 && tlim>0.9) tl1=0.9;  // tropical grass 
	    
    tlm=climate.Tlim();
    gddopt=climate.GddOpt();
    
    if (icefreefraction<1) {
	tlm=tlm*icefreefraction;
	tlm=tlm-(1-icefreefraction)*0.4;
    }
    if (tlm<EPS) tlm=EPS;
    
    return exp ( -(gddopt-tlm)/(0.5*gddopt) );
}

/**
static methods and variables 
*/

double glues::LandRegion::NppMaxLae(const double d) {
    nppmaxlae=d;
    nppmaxfep=2*nppmaxlae;
};

double* glues::LandRegion::IceExtent(const double ice[4]) {
    for (int i=0; i<4; i++) iceextent[i]=ice[i];
};

double glues::LandRegion::nppmaxlae=550.0;
double glues::LandRegion::nppmaxfep=1100.0;
double glues::LandRegion::iceextent[]={50,80,80,45};

/** EOF LandRegion.cc */
