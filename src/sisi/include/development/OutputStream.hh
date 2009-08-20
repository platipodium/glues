/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile$
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
//  $Revision$
//  $Date$
//
//  Description
//    This class prints messages to standard outputs and/or to specified
//    files. It's needed by MessageHandler.
//
//
//  $Log$
/////////////////////////////////////////////////////////////////////////////

#ifndef _OutputStream_hh_
#define _OutputStream_hh_

#include "cppinc.h"

class OutputStream : public ostream {
public:
  OutputStream(ostream& out, const char* filename)
    : ios(out) { 
  }
  ~OutputStream() {
  }
  ///////////////////////////////////////////////////////////////////////////
  //
  // private static access:
  //
private:
  ostream* _out;
};

#endif // _OutputStream_hh_
