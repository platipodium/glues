/************************************************************************
 *									
 * @file  GlobalClimate.h
 * @brief Declaration of class GlobalClimate
 * @author Carsten Lemmen <c.lemmen@fz-juelich.de>
 * @author Kai Wirtz <wirtz@icbm.de>
 * @date 2003-05-21
 * 
 * This file is part of GLUES, the Global Land Use 
 * and Environmental Change Simulator					 
 *									
 ************************************************************************/

#ifndef global_climate_h
#define global_climate_h

#include "Symbols.h"
#include <cstdio>
#include <cstring>
#include "Constants.h"
#include "PopulatedRegion.h"

#define MAPENTRIES 360*720

extern unsigned int numberOfRegions;
extern PopulatedRegion* regions;

/** DECLARATION section **/
class GlobalClimate {
 protected:
  double timestamp;
  glues::RegionalClimate* climate;
 
  int *map;

  double id2lat(unsigned int index) const{ return 90.0-(index/720)/2.0;}
  double id2lon(unsigned int index) const{ return (index%720)/2.0-180.; }
  unsigned int lat2x(double lat)  const { return (unsigned int)((90.-lat)*2.); } 
  unsigned int lon2x(double lon)  const { return (unsigned int)((lon+180.)*2.);}
  unsigned int geo2id(double,double) const;
  // static double *npp_store;
  //static double *gdd_store;
  
  
 public:
  GlobalClimate(double timestamp);
  ~GlobalClimate();
  
  /** Accessor methods */
  double Timestamp() { return timestamp; }
  glues::RegionalClimate Climate(unsigned int i) { return climate[i]; }
  int Update(double time);
  int UpdateNPP(int r, double npp);

  static int InitRead(char* filename);

};
#endif

/** EOF GlobalClimate.h*/
