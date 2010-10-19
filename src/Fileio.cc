/* GLUES i/o declaration; this file is part of
   the Global Land Use and technological Evolution Simulator
   
   Copyright (C) 2007
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
   @date   30.11.2007
   @file   Fileio.cc
   @brief File Input/Output definitions

   Routines in this file are based on the InputOutput.cpp of prior versions
   and slowly undergo transition to C++.
*/

#include "Fileio.h"

//namespace glues {
  
  Fileio::writeStaticRegionProperties() 
  {
    
    ofstream ofs;
    
    statreg.assign(datapath);
    statreg.append("regions_static_properties.tsv");
    
    ofs.open(statreg.c_str());
    if (ofs.fail()) return 0;
    
    /*ofs << regions[0].DataHeader() << endl;
      for (unsigned int i=0; i<numberOfRegions; i++)
      ofs << regions[i].DataValues() << endl;*/
    
    ofs.close();
    return 0;
  }
  
}
