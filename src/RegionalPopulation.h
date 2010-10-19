/* GLUES regional population class; this file is part of
   the Global Land Use and technological Evolution Simulator
   
   Copyright (C) 2001,2002,2003,2004,2005,2006,2007,2008,2009,2010
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
   @date   2010-09-24
   @file   RegionalPopulation.h
   @brief  Definition of regional population
*/

#ifndef glues_regional_population_h
#define glues_regional_population_h

#include "Symbols.h"
#include "Globals.h"
#include <cmath>

/** Prototype section */
class PopulatedRegion;
class Tracer;

/** DECLARATION section **/
class RegionalPopulation {
 private:
  double size;          /** Size of population */
  double density;       /** Density of  population */
  double growthrate;	/** Geburtsrate */
  double qfarming;      /** Farming ratio */
  double technology;    /** Technology efficiency */
  double ndomesticated; /** AAE, number of domesticated species */
  double ndommax;       /** PAE, number of domesticable species */
  double biondommax;    /** parameter not used */
  double actualfertility;   /** FEP food extraction potential */
  double tlim,tlim0;
  double naturalfertility,farmfert;
  double actexploit,newexploit;
  double germs;
  double resist;
  double product;      /** Subsistence intensity*art */
  double disease;
  double rgr;
  double art,teff,nrat;
  double civstart;
  PopulatedRegion* region;		/* the associated region */
  Tracer* origin;
  double birthrate,deathrate; 

 public:
  RegionalPopulation(double,double,double,double,double,double,double,
		     double,double,PopulatedRegion*);
  RegionalPopulation();
  ~RegionalPopulation();
  
  
  double Density()        const   {return density;}
  void   Density(double);
  void   Size(double);
  double Growthrate()     const	{return rgr;}
  double Technology()     const	{return technology;}
  double Qfarming()	const	{return qfarming;}
  double Ndomesticated() 	const   {return ndomesticated;}
  double Ndommax() 	const   {return ndommax;}
  void   Ndommax(double dm) { ndommax = ( dm > 0.01 ? dm:0.01 ); }
  double Germs() 	        const   {return germs;}
  double Resist() 	const   {return resist;}
  double Tlim() 	        const   {return tlim;}
  double ActFert()	const   {return actualfertility;}
  double CivStart()	const   {return civstart;}
  double NatFert()	const   {return naturalfertility;}
  double CultIndex() 	const   {return ndomesticated*qfarming;}
  double Biondommax()     const   {return biondommax;}
  double SubsistenceIntensity() const {return sqrt(technology)*(1-qfarming)+
    (tlim*technology)*ndomesticated*qfarming; }
  PopulatedRegion* Region() const	{return region;}
  Tracer* Origin() {return origin;}
  double Size() const;

  double RatesOfChange(double*);
  double Grow(void);
  double RelativeGrowthrate(void);
  int    Develop(double);
  double drdQ(void);
  double drdN(void);
  double drdR(void);
  double drdT(void);

  int Write(FILE* resultfile, int);
  int Write(FILE* resultfile);
  
  int  Update(void);
  void CreateVector(void);
  double IndexedValue(unsigned int);
  
  friend std::ostream& operator<<(std::ostream&, const RegionalPopulation&);
};
#endif

/** EOF RegionalPopulation.h */



