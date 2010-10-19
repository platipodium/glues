/* GLUES test; this file is part of
   the Global Land Use and technological Evolution Simulator
   
   Copyright (C) 2009,2010
   Carsten Lemmen <carsten.lemmen@hzg.de>

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
   @date   2010-10-19
   @file test_netcdf.cc
*/

#include "config.h"
#include <iostream>
#include <string>
#include <fstream>
#include <sstream>

#ifdef HAVE_NETCDF_H
#include "netcdfcpp.h"
#endif

int main(int argc, char* argv[]) 
{

#ifndef HAVE_NETCDF_H
    std::cout << " No netcdf interface defined. FAIL" << std::endl;
    return 1;
#else
 
  std::string filename="../../examples/setup/685/results.out";
   
  std::ifstream ifs(filename.c_str(),std::ios::in | std::ios::binary);
  ifs.seekg (0, std::ios::end);
  int length = ifs.tellg();
  ifs.seekg (0, std::ios::beg);

  // First byte gives the number of variables as an unsigned char
  unsigned char nvar;
  ifs >> nvar;

  int i=0;
  
  std::string *vars = new std::string[nvar];

  for (i=0; i<nvar; i++) 
  {
    ifs >> vars[i];
    //cout << vars[i] << endl;
  }
   
  float *nreg,*tstart,*tend,*tstep;
  //ifs >> nreg; 
   
  // Read float-32 data
  char * buffer = new char [length-(int)ifs.tellg()];
  ifs.read(buffer,length);
  ifs.close();
   
  nreg=(float*)buffer;tstart=(float*)(buffer+4);
  
  for (i=0; i<8; i++) 
  {
  nreg=(float*)(buffer+i);
    std::cout << i << ": " << *nreg << std::endl;
  }
 
  std::cout << (int)nvar << " x " << *nreg << " / " << *tstart << ":"
  << tend << " " << tstep << std::endl;


  return 0;
#endif
}

