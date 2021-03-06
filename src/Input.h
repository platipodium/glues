
/* GLUES input routines ; this file is part of
   the Global Land Use and technological Evolution Simulator
   
   Copyright (C) 2007,2008,2009,2010,2011,2012
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
   @date   2012-02-14
   @brief Input routines
*/

#ifndef glues_input_h 
#define glues_input_h 

#include "Symbols.h"
#include <cstring>
#include <cstdlib>
#include <fstream>
#include "variables.h"
#include "IO.h"

int read_EventRegTime();

//namespace glues {
/* class Input
    {
    private:
      unsigned int number;
    public:
      unsigned int RegionNumber() const { return number; };
      int RegionProperties();

    protected:
      unsigned int RegionNumber(std::ifstream&);
      unsigned int RegionNumber(std::string);
      unsigned int RegionNumber(char*);

      int RegionProperties(std::ifstream&);
      int RegionProperties(std::string);
      int RegionProperties(char*);
    };
//}
*/
#endif

/* EOF Input.h */
