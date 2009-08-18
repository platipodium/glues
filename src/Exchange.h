/* GLUES  exchange declaration. This file is part of
   the Global Land Use and technological Evolution Simulator
   
   Copyright (C) 2001,2002,2003,2004,2005,2006,2007,2008
   Carsten Lemmen <carsten.lemmen@gkss.de>
   Kai W. Wirtz <kai.wirtz@gkss.de>

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
   @author Kai W. Wirtz <kai.wirtz@gkss.de>
   @date 2008-01-08
   @file Exchange.h
   @brief Declaration of class Exchange
   @todo recursive method if change>RelChange
*/

#ifndef glues_exchange_h
#define glues_exchange_h

#include "Symbols.h"
#include "RegionalPopulation.h"


class PopulatedRegion;
class RegionalPopulation;
class GeographicalNeighbour;

//namespace glues {  

class Exchange {
 private:
  double** exchange;
  double*  migration;
  
  public:
    Exchange(unsigned int);
    ~Exchange();
    
    double Twoway(RegionalPopulation&,RegionalPopulation&);
    static double Traitspread(double,double,double);
    static double Genospread(double,double,double,double);
    
  };
//}

#endif /* glues_exchange_h */
