/* GLUES SiSiReader; this file is part of
   the Global Land Use and technological Evolution Simulator
   
   Copyright (C) 2010
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
   @file   SiSiReader.cc
*/

//#include "config.h"

#include <iostream>
#include <fstream>
#include <map>
#include <string>

int main(int argc, char* argv[]) 
{

  std::cout << "SiSiReader 0.1" << std::endl;
  
  std::string filename="/Users/lemmen/devel/glues/examples/simulations/685/lbk.sim";

  std::ifstream ifs(filename.c_str(),std::ios::in);
  if (ifs.bad()) return 1;
  
  



}