/* GLUES local climate specification; this file is part of
   the Global Land Use and technological Evolution Simulator
   
   Copyright (C) 2007,2008
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
   @author Kai W Wirtz <kai.wirtz@gkss.de
   @file  LandRegion.h
   @brief Declaration of class LocalClimate (before:RegionalCimate)
   @date 2008-08-12
*/

#ifndef glues_local_climate_h
#define glues_local_climate_h

#include "Symbols.h"
#include "Constants.h" // for EPS

namespace glues {

  class LocalClimate {
    public:
	  double lai,npp,tlim;
	  double gdd0; // not yet used and implemented
    public:
	  static double gdd_opt;
    public:
	  static void Init(const double);
	  LocalClimate(double,double,double);
      LocalClimate();
	
	/** Accessor methods */
	//double Lai(double l)	        {return lai = (l > 0?l:glues::EPS);}
	  double Lai()	const		{return lai;}
	  double Npp(double n)		{return npp = (n > 0?n:glues::EPS);}
	  double Npp()	const		{return npp;}
	//double Tlim(double tl)		{return tlim = tl;}
	  double Tlim() const      	{return tlim;}
	  static double GddOpt() {return gdd_opt;}
   };
	
	/** other methods */
    std::ostream& operator<<(std::ostream&, const LocalClimate&);
}
#endif
