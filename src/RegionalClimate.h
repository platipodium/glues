/************************************************************************
 *									
 * @file  RegionalClimate.h
 * @brief Declaration of class RegionalClimate
 * @author Carsten Lemmen <c.lemmen@fz-juelich.de>
 * @author Kai Wirtz <wirtz@icbm.de>
 * @date 2008-12-17
 * 
 * This file is part of GLUES, the Global Land Use 
 * and Environmental Change Simulator					 
 *									
 ************************************************************************/

#ifndef glues_regional_climate_h
#define glues_regional_climate_h

#include "Symbols.h"
#include <iostream>
#include <cstdio>

namespace glues {
    class RegionalClimate {
    protected:
	double lai,npp,gdd,tlim,time;
	double hyper(double,double,int) const;
    public:
	RegionalClimate(double,double,double,double,double);
	RegionalClimate(double,double,double,double);
	RegionalClimate(double,double,double);
        RegionalClimate();
	~RegionalClimate();
	
	/** Accessor methods */
	double Lai(double l)	        {lai = (l > 0?l:0); return lai;}
	double Lai()	const		{return lai;}
	double Gdd(double g)	        {gdd = (g > 0?g:0); return gdd;}
	double Gdd()	const		{return gdd;}
	double Npp(double n)		{npp = (n > 0?n:0); return npp;}
	double Npp()	const		{return npp;}
	double Tlim(double t)		{tlim =(t > 0?t:0); return tlim; }
	double Tlim() const      	{return tlim;}
	double Time(double t)		{time = t; return time; }
	double Time() const      	{return time;}

	double NatFertility(double) const;
	double SuitableSpecies() const;
	double SuitableTemp() const;

	/** other methods */
	int Write(FILE*);
	friend std::ostream& operator<<(std::ostream& os, const glues::RegionalClimate& climate);
    };
}
#endif /** glues_regional_climate_h */
