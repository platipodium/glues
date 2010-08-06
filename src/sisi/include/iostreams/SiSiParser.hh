/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: SiSiParser.hh,v $	
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
//  $Revision: 1.4 $
//  $Date: 1998/03/18 13:07:11 $
//
//  Description
//   This class parses SiSi (parameter) files and stores
//   the parameters into a TwoWayList. It uses the FileParser.
//
//
//  $Log: SiSiParser.hh,v $
//  Revision 1.4  1998/03/18 13:07:11  reinhard
//  includes at the end of file removed.
//
//  Revision 1.3  1998/03/13 16:41:17  reinhard
//  #include "datastructures/TableParameter.hh" added.
//
//  Revision 1.2  1998/03/05 14:57:11  kai
//  Parameter* parseParameter(FileParser& parser) added.
//
//  Revision 1.1  1998/02/25 12:39:55  reinhard
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _SiSiParser_hh_
#define _SiSiParser_hh_

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include "datastructures/Parameter.hh"
#include "datastructures/String.hh"
#include "twowaylist/TwoWayList.hh"

class SiSiParser
{
public:
  ///////////////////////////////////////////////////////////////////////////
  //
  // Constructors:
  //
  SiSiParser() { }

  ///////////////////////////////////////////////////////////////////////////
  //
  // public access:
  //

  /** Parses a simulationfile 'file' and all including files. Stores
   *  the read parameter to list.  Returns "OK" if no error occur or
   *  rather the errormessage. */
  String parseSimulation(TwoWayList& list, const char* filename);
  /** Parses a parameterfile 'file' and stores the read parameter to list.
   *  Returns "OK" if no error occur or rather the errormessage. */

  String parseFile(TwoWayList& list, const char* filename);

  /** Parses a parameter from an opened FileParser. Returns the parameter
   *  or NULL, if an error occurs. */
  Parameter* parseParameter(FileParser& parser);
private:
  ///////////////////////////////////////////////////////////////////////////
  //
  // private access:
  //
  /** Parses a parameterstream from an opened FileParser and stores the
   *  read parameter to list.
   *  Returns "OK" if no error occur or rather the errormessage. */
  String read(TwoWayList& list, FileParser& parser);
};

#endif // _SiSiParser_hh_
