/************************************************************************
 *									
 * @file  VegetatedRegion.h
 * @brief Declaration of class VegetatedRegion
 * @author Carsten Lemmen <c.lemmen@fz-juelich.de>
 * @author Kai Wirtz <wirtz@icbm.de>
 * @date 2002-12-13
 * 
 * This file is part of GLUES, the Global Land Use 
 * and Environmental Change Simulator					 
 *									
 ************************************************************************/

#ifndef glues_vegetated_region_h
#define glues_vegetated_region_h

#include "Symbols.h"
#include <cstdio>
#include <cstring>
#include "GeographicalRegion.h"
#include "Continent.h"
#include "RegionalClimate.h"
#include "Constants.h"
#include "variables.h" // for variable kappa and regenerate

//namespace glues {

/** DECLARATION section **/
class VegetatedRegion: public GeographicalRegion {
  protected:
    glues::RegionalClimate climate;
    double contndommax;
    double exploit;
    double icefraction;
    glues::Continent* continent;
public:

    VegetatedRegion();
    VegetatedRegion(std::istream&);
    VegetatedRegion(const std::string&);
    VegetatedRegion(const VegetatedRegion&); 
    VegetatedRegion(double,double,double,
      unsigned int,unsigned int,double,double,double);
    ~VegetatedRegion();
    
	/** Accessor methods */
    double Exploit()     const     	{return exploit;}
	int    Exploit(double e)      	{exploit = e; return 0;}
	int    Lai(double l)	        {climate.Lai(l); return 0;}
	double Lai()	const		{return climate.Lai();}
	int    Npp(double n)		{climate.Npp(n); return 0;}
	double Npp()	const		{return climate.Npp();}
	int    Tlim(double tl)		{climate.Tlim(tl); return 0;}
	double Tlim() const      	{return climate.Tlim();}
	double ContNdommax() const	{return contndommax;}
	int    ContNdommax(double cn)	{contndommax=cn; return 0;}
	double NatFertility(double) const;
	double SuitableSpecies() const;
	double SuitableTemp() const;
        double IceFraction() const      {return icefraction;}
        int    IceFraction(double i)    {icefraction = i; return 0;}

	glues::RegionalClimate Climate() const { return climate; }
	int  Climate(glues::RegionalClimate rc) {climate=rc; return 0;}
	int  Climate(double,double,double);
        int  InterpolateClimate(double,double,double,const glues::RegionalClimate&,const glues::RegionalClimate&);

	/** other methods */
	int  NewExploit(double,int,double);
	int  NewExploit(double newexploit) {exploit=newexploit; return 0;}
	int  Write(FILE* ,int ) const;
	friend std::ostream& operator<<(std::ostream& os,const VegetatedRegion& reg);
	const  char* DataHeader();
	char*  DataValues() const;
};
//}
#endif /** glues_vegetated_region_h */
