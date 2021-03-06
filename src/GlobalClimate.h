/* GLUES GlobalClimate implementation; this file is part of
   the Global Land Use and technological Evolution Simulator

   Copyright (C) 2008,2009,2010,2011
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
   @author Carsten Lemmen <carsten.lemmen@gkss.de>
   @author Kai Wirtz <kai.wirtz@gkss.de>
   @author Caleb K Taylor <calebt@users.sourceforge.net>
   @date   2010-10-26
   @file   GlobalClimate.h
   @brief  Input and update of climate data
*/

#ifndef global_climate_h
#define global_climate_h

#include "Symbols.h"
#include "Constants.h"
#include "PopulatedRegion.h"
#include <vector>

#define MAPENTRIES 360*720

extern unsigned int numberOfRegions;
extern PopulatedRegion* regions;

/** DECLARATION section **/
class GlobalClimate {
  protected:
    double timestamp;
 
    std::vector< glues::RegionalClimate > climate;
    std::vector< double > timeaxis;
    std::vector< int > map;

    double id2lat(unsigned int index) const{ return 90.0-(index/720)/2.0;}
    double id2lon(unsigned int index) const{ return (index%720)/2.0-180.; }
    unsigned int lat2x(double lat)  const { return (unsigned int)((90.-lat)*2.); }
    unsigned int lon2x(double lon)  const { return (unsigned int)((lon+180.)*2.);}
    unsigned int geo2id(double,double) const;
 
  public:
    GlobalClimate(double timestamp);
    ~GlobalClimate();

  /** Accessor methods */
    double Timestamp() { return timestamp; }
    //Need to implement own bounds checking for climate[].
    glues::RegionalClimate Climate(unsigned int i) { return climate.at(i); }
    int Update(double time);
    int UpdateNPP(int r, double npp);

    static int InitRead(char* filename);
  private:
    static int ReadTsv(const std::string& filename);
    static int ReadNetcdf(const std::string& filename);
};
#endif

/** EOF GlobalClimate.h*/
