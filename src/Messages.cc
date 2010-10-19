/* GLUES messages; this file is part of
   the Global Land Use and technological Evolution Simulator
   
   Copyright (C) 2007,2008,2009,2010
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
   @date   2010-02-24
   @file Messages.cc
   @brief Welcome and goodbye messages
*/

#include "Messages.h"

namespace glues {

   void Messages::Welcome()  {
    
    cout 
      << endl
      << "****************************************************************" << endl
      << "*                       Welcome to GLUES	                 *" << endl
      << "*     Global Land-Use and technological Evolution Simulator    *" << endl
      << "*                                                              *" << endl
      << "*  For information please refer to the file readme.txt         *" << endl
      << "*  This program is licensed under the GNU Public license.      *" << endl
      << "*                                                              *" << endl
      << "*  Authors Carsten Lemmen & Kai Wirtz                          *" << endl
      << "*  Contact <carsten.lemmen@hzg.de>                            *" << endl 
      << "*  Last change  2009-08-14 / Version 1.1.15                     *" << endl
      << "****************************************************************" << endl
      << endl;
    return;
  }
  
   void Messages::Goodbye()  {
    cout 
      << endl
      << "****************************************************************" << endl
      << "*                Thank you for using GLUES 1.1.15" << endl
      << "****************************************************************" << endl
      << endl;
    return;
  }
  
    int Messages::Success()   {
    cout 
      << "Your simulation ended successfully." << endl;
    return 0;
  }

    int Messages::Error()  {
	cerr 
      << "An error occurred and the simulation was terminated." << endl;
    return 1;
  }
}
