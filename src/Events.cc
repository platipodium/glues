/* GLUES climate events; this file is part of
   the Global Land Use and technological Evolution Simulator
   
   Copyright (C) 2009,2010
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
   @date   2010-07-26
   @file   Events.cc
*/

#include "Events.h"

/**
   @return number of sites
*/

unsigned long int glues::Events()
{
  
    float fdummy;
    ifstream ifs;
    io io;
  
    std::cout << "Read " << eventfilename << " ";
    
    ifs.open(eventfilename.c_str(),ios::in);
    
    numberOfEvents=io.count_ascii_columns(ifs)-2;
    numberOfSites=io.count_ascii_rows(ifs);

    ifs.close();
    ifs.open(filename.c_str(),ios::in);

    std::cout << numberOfSites << " sites x " << numberOfEvents << " events\n";

    /**EventTime= (double *)(std::malloc(numberOfSites*numberOfEvents*sizeof(double)));
    EventSerMax = (double *)(std::malloc(numberOfSites*sizeof(double)));
    EventSerMin = (double *)(std::malloc(numberOfSites*sizeof(double))); */
    
    EventTime   = new double(numberOfSites*numberOfEvents);
    EventSerMax = new double(numberOfSites);
    EventSerMin = new double(numberOfSites);
    
    ifs.seekg(0);
    // Read to the end to see how many regions there are
    for (unsigned int i=0;  i<(unsigned int)numberOfSites; i++) {
	for (unsigned int j=0; j<(unsigned int)MaxEvent; j++) {
	    ifs >> fdummy;
	    *(EventTime+j+i*numberOfEvents)=fdummy;
	    //  cout <<i<<": "<< fdummy << "->" << *(EventTime+j+i*MaxEvent) <<endl;
	}
	ifs >> fdummy; EventSerMin[i]=fdummy;
	ifs >> fdummy; EventSerMax[i]=fdummy;
    }
    
    ifs.close();
    return numberOfSites;
}



