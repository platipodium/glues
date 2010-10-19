/* GLUES climate events; this file is part of
   the Global Land Use and technological Evolution Simulator
   
   Copyright (C) 2009
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
   @date   2009-01-30
   @file   Events.h
*/

#ifndef glues_events_h
#define glues_events_h
//#include "Symbols.h"
//#include "Globals.h"

#include <iostream>
#include <fstream>
#include <sstream>
#include <cstdlib>
#include "IO.h"

namespace glues {
    
    static class Events {
	
    private:
	std::string datapath;
	std::string eventfilename; // eventname
	std::string regioneventfilename;
	std::string regionradiusfilename;

        unsigned long int numberOfSites;
	unsigned long int numberOfEvents;
	unsigned long int numberOfEventsInRegion;
	unsigned long int numberOfRegions;

	unsigned long int read_proxies();

	unsigned long int count_ascii_columns(std::ifstream &);
	unsigned long int count_ascii_rows(std::ifstream &);

	/*double** EventTime; // numberOfSites * MaxEvent
	double* EventSerMax; // numberofSites
	double* EventSerMin; // numberofSites*/
    };
}
#endif
