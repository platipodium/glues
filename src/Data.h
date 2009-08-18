/* GLUES data temporary storage this file is part of
   the Global Land Use and technological Evolution Simulator
   
   Copyright (C) 2009
   Carsten Lemmen <carsten.lemmen@gkss.de>
   
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
   @date   2009-02-11
   @file   Data.h
   @brief  Temporary data storage for GLUES variables
*/

#ifndef glues_data_h
#define glues_data_h

#include "RegionalPopulation.h"
#include <vector>

using std::vector;

namespace glues {

    class Data {
    private:
	static unsigned long int n;

    public: 

	Data(unsigned long int n,  std::vector<RegionalPopulation> &  rp) {
	    // if (num<0) return;
	    unsigned long int i;
	    //std::vector<RegionalPopulation>::iterator ip;
	    //num;

	    id=new long int[n];
	    /*for (ip=rp.begin(); ip<rp.end(); ip++) {
		//id[i]=rp[i]->Region()->Id();
		cout << *ip  ;//[i] << id[i];
		}J*/
	    for (i=0; i<rp.size(); i++)
		cout << rp[i];
	}

	long int* id;
	static vector<double> area;
	static vector<double> lon;
	static vector<double> lat;

	// climate variables
	static vector<double> npp;
	static vector<double> gdd;
	static vector<double> tlim;

   };

}
#endif
