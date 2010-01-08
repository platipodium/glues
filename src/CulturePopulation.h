/* GLUES culture population class; this file is part of
   the Global Land Use and technological Evolution Simulator
   
   Copyright (C) 2001,2002,2003,2004,2005,2006,2007,2008
   Carsten Lemmen <carsten.lemmen@gkss.de>, Kai Wirtz <kai.wirtz@gkss.de>

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
   @author Carsten Lemmen <carsten.lemmen@gkss.de>
   @author Kai Wirtz <kai.wirtz@gkss.de>
   @date   2008-08-21
   @file   CulturePopulation.h
   @brief  Definition of CulturePopulation
*/

#ifndef glues_culture_population_h
#define glues_culture_population_h

#include "Symbols.h"
#include "TechnologyTrait.h"
#include "FarmingQuotaTrait.h"
#include "DomesticationFractionTrait.h"
#include "CultureRegion.h"
#include "Population.h"
#include <vector>

namespace glues {

    class CultureRegion;

/** @class CulturePopulation
    @brief A population asscociated with a land region
    A CulturePopulation is a Population which is associated with a region.
    This implies that space-related properties such as population density can be introduced.
    Also, the migration of population can be described only with the association to a
    LandRegion
*/  
    
    class CulturePopulation : public Population {
    protected:
	double density;
	CultureRegion* region;
	
	double civstarttime; /** Timing of civilization */
	//vector<EffectiveVariable&> trait;
	TechnologyTrait technology;
	FarmingQuotaTrait qfarming;
	DomesticationFractionTrait fdomesticated;
	static double literatetechnology;
	static double artisancoefficient;
	static double exploitationcoefficient;
	
    public:
	//CulturePopulation();
	CulturePopulation(CultureRegion*);
	CulturePopulation(CultureRegion*, const double);

	static double LiterateTechnology(const double);
	static double ArtisanCoefficient(const double);
	static double ExploitationCoefficient(const double);

	/*CulturePopulation(double,double,double,double,double,double,double,
	  double,double,const CultureRegion*);*/
	~CulturePopulation();
	
	TechnologyTrait& Technology()  {return technology;}
	FarmingQuotaTrait& FarmingQuota()  {return qfarming;}
	DomesticationFractionTrait& DomesticationFraction() {return fdomesticated;}

	double Density()        const   {return density;}
	double Density(const double d) { return density = d; }
	
//	double Growthrate()     const	{return rgr;}
	/*double Technology()     const	{return technology;}
	double Qfarming()	const	{return qfarming;}
	double Ndomesticated() 	const   {return ndomesticated;}
	double Ndommax() 	const   {return ndommax;}
	void   Ndommax(double dm) { ndommax = ( dm > 0.01 ? dm:0.01 ); }
	double Germs() 	        const   {return germs;}
	double Resist() 	const   {return resist;}
	double Tlim() 	        const   {return tlim;}
	double ActFert()	const   {return actualfertility;}
	double CivStart()	const   {return civstarttime;}
	double NatFert()	const   {return naturalfertility;}
	double CultIndex() 	const   {return ndomesticated*qfarming;}
	PopulatedRegion* Region() const	{return region;}
	Tracer* Origin() {return origin;}
	
	double RatesOfChange(double*);
	double RelativeGrowthrate(void);
	int    Develop(double);
	
	int Write(FILE* resultfile, int);
	int Write(FILE* resultfile);
	
	int  Update(void);
	void CreateVector(void);
	double IndexedValue(unsigned int); */
	
	friend std::ostream& operator<<(std::ostream&, CulturePopulation&);

 	double Grow();
	double RelativeGrowthrate();
 	double TechnologyGradient();
	double FarmingQuotaGradient();
	double DomesticationFractionGradient();
	double Capacity();
	double SubsistenceIntensity();
	double ResistanceGradient();
 
	double DeathFunction();
	double BirthFunction();
  	double ResourceAvailability();
	double LabourAvailability();
	double Exploitation();
 };
}

#endif

/** EOF CulturePopulation.h */



