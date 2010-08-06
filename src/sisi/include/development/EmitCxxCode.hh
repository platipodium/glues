/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: EmitCxxCode.hh,v $	
//
//  Project      SiSi
//               Wissenschaftliches Zentrum fuer
//		 Umweltsystemforschung Kassel
//               Germany
//
//               Umweltforschungszentrum Leipzig
//
//  Author       Kai Reinhard (reinhard@usf.uni-kassel.de)
//               Schoene Aussicht 39, 34317 Habichtswald, Germany
//               email: reinhard@usf.uni-kassel.de
//               URL  : http://www.usf.uni-kassel.de/~reinhard/
//
//  Copyright (C) 1997, 1998 by Kai Reinhard
//
//   This program is free software; you can redistribute it and/or modify
//   it under the terms of the GNU General Public License as published by
//   the Free Software Foundation; either version 2 of the License, or
//   (at your option) any later version.
//
//   This program is distributed in the hope that it will be useful,
//   but WITHOUT ANY WARRANTY; without even the implied warranty of
//   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//   GNU General Public License for more details.
//
//   You should have received a copy of the GNU General Public License
//   along with this program; if not, write to the Free Software
//   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
//
//  $Revision: 1.1 $
//  $Date: 1998/02/25 16:37:21 $
//
//  Description
//   This class generates the C++ code for using SiSi-parser in own
//   simulations. All variables declared as global in the header file.
//   You have to include the emitted header file in every source file
//   using these variables and to call SiSi::parseSimulation(filename) once
//   (e.g. in function main).
//
//  $Log: EmitCxxCode.hh,v $
//  Revision 1.1  1998/02/25 16:37:21  reinhard
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _EmitCxxCode_hh_
#define _EmitCxxCode_hh_

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include "platform.hh"
#include "datastructures/String.hh"
#include "twowaylist/TwoWayList.hh"

class EmitCxxCode
{
public:
  /** Emits C++ Code to the given baseFilename + suffix for the given
   *  simulation. If modul=false, only a headerfile (.hh) will be
   *  emitted. This is useful, if only one source file use the
   *  variables. Otherwise a headerfile (.hh) and a source file (.cc)
   *  will be emitted. */
  static String emit(const char* baseFilename, const char* simulation,
		     bool modul = true);

  /** What is the output format? If the given bool isn't true, than
   * the output will consider the 8 dot 3 filename convention
   * (DOS-Format) and String class will be renamed to SiSi_String. */
  static void setOutputFormat(bool unix);

private:
  /** Emits informations about the generating program. */
  static void _emitInformation(ostream& ost);
  
  /** Emits the header file depending on the switch modul. */
  static String _emitHeaderFile(TwoWayList& list, const char* filename,
				bool modul);

  /** Emits the source file. */
  static String _emitSourceFile(TwoWayList& list, const char* filename);

  /** Emits the variables with the given prefix */
  static void _emitVariables(ostream& ost, TwoWayList& list,
			     const char* prefix="");

  /** Emits the realization of the class. */
  static void _emitClass(ostream& ost, TwoWayList& list);
  
  /** Name of the class String: Normally "String", but for 8 dot 3
   *  filename convention it will be set to "SiSi_String" */
  static String _classNameOfString;
  /** True, if normal emitting, or false, if concidering 8 dot 3 filename
   *  convention. */
  static bool   _unix;
};

#endif // _EmitCxxCode_hh_
