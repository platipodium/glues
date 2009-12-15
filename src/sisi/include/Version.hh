/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: Version.hh,v $	
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
//  $Date: 1998/02/19 09:30:03 $
//
//  Description
//    This file contains different extern declarations containing info
//    about version and name of the programm.
//    This variables are realized in modul Version.cc.
//
//
//  $Log: Version.hh,v $
//  Revision 1.1  1998/02/19 09:30:03  kai
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _Version_hh_
#define _Version_hh_

class Version {
public:
  static const char* ProgramName;
  static const char* Number;
  static const char* Program;
  static const char* CompletionTime;
};

static char sisi_is_available() { return 1; }

#endif // _Version_hh_
