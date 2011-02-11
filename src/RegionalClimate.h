/* GLUES regional climate implementation; this file is part of
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
   @author Kai W Wirtz <kai.wirtz@hzg.de
   @date   2010-02-24
   @file RegionalClimate.h
   @brief Reginonal climate
*/

#ifndef glues_regional_climate_h
#define glues_regional_climate_h

#include "Symbols.h"
#include <iostream>
#include <cstdio>

namespace glues 
{
  class RegionalClimate 
  {
    protected:
	  double lai,npp,tlim,time;
	  double gdd,gdd0,gdd5;
	  double hyper(double,double,int) const;
	  
    public:
	  RegionalClimate(double,double,double,double,double);
	  RegionalClimate(double,double,double,double);
	  RegionalClimate(double,double,double);
      RegionalClimate();
	  ~RegionalClimate();
	
	/** Accessor methods */
	inline double Lai(double l)  {lai = (l > 0?l:0); return lai;}
	inline double Lai()	const    {return lai;}
	inline double Gdd(double g)  {gdd = (g > 0?g:0); gdd = (gdd<360?gdd:360); return gdd;}
	inline double Gdd()	const	 {return gdd;}
	inline double Gdd0(double g) {gdd0 = (g > 0?g:0); return gdd0;}
	inline double Gdd0() const	 {return gdd0;}
	inline double Gdd5(double g) {gdd5 = (g > 0?g:0); return gdd5;}
	inline double Gdd5() const	 {return gdd5;}
	inline double Npp(double n)	 {npp = (n > 0?n:0); return npp;}
	inline double Npp()	const    {return npp;}
	inline double Tlim(double t) {tlim =(t > 0?t:0); tlim = (tlim<1?tlim:1); return tlim; }
	inline double Tlim() const   {return tlim;}
	inline double Time(double t) {time = t; return time; }
	inline double Time() const   {return time;}

	double NatFertility(double) const;
	double SuitableSpecies() const;
	double SuitableTemp() const;

	/** other methods */
	int Write(FILE*);
	friend std::ostream& operator<<(std::ostream& os, const glues::RegionalClimate& climate);
    };
}
#endif /** glues_regional_climate_h */
