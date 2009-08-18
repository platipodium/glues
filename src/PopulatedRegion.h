/************************************************************************
 *									
 * @file  PopulatedRegion.
 * @brief Declaration of class PopulatedRegion
 * @author Carsten Lemmen <c.lemmen@fz-juelich.de>
 * @author Kai Wirtz <wirtz@icbm.de>
 * @date 2002-12-13
 * 
 * This file is part of GLUES, the Global Land Use 
 * and Environmental Change Simulator					 
 *
 ************************************************************************/

#ifndef glues_populated_region_h
#define glues_populated_region_h

#include "Symbols.h"
#include "VegetatedRegion.h"
#include <fstream>
#include <cstdio>
#include <string>

//namespace glues {

class RegionalPopulation;

/** DECLARATION section **/
class PopulatedRegion : public VegetatedRegion {
  private:
    long civstart;
    RegionalPopulation* population;
  public:
    PopulatedRegion();
    PopulatedRegion(std::istream&);
    PopulatedRegion(const std::string& line);
    PopulatedRegion(const PopulatedRegion&);
    ~PopulatedRegion();
    long CivStart() const		{return civstart;}
    int  CivStart(long );
    void ResetCivStart()	        {civstart=-1;};
    RegionalPopulation* Population()	{return population;}
    void Population(RegionalPopulation* pop) {population = pop;}
    int Write(FILE*,unsigned int );
    int Write(FILE*) const;
    friend std::ostream& operator<<(std::ostream& os, const PopulatedRegion& reg);

    double CheckDistCenter();
    double DistanceToKnownCenters(unsigned int, double **);
};

//}

#endif /** EOF PopulatedRegion.h*/
