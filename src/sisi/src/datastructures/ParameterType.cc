/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: ParameterType.cc,v $	
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
//  $Revision: 1.3 $
//  $Date: 1998/03/05 08:47:56 $
//
//  Description
//    Class ParameterType contains following types:
//     UNKNOWN, INT, FLOAT, CHAR, STRING, BOOLEAN, LIST, TABLE AND
//     COMMENT.
//
//  $Log: ParameterType.cc,v $
//  Revision 1.3  1998/03/05 08:47:56  kai
//  Types RESULT and PARAMETER added.
//
//  Revision 1.2  1998/02/14 22:33:22  kai
//  CHAR and BOOLEAN added.
//
//  Revision 1.1  1998/02/13 17:23:54  reinhard
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////

#include "datastructures/ParameterType.hh"

ParameterType* ParameterType::UNKNOWN   = new ParameterType((short)  0);
ParameterType* ParameterType::INT       = new ParameterType((short)  1);
ParameterType* ParameterType::FLOAT     = new ParameterType((short)  2);
ParameterType* ParameterType::CHAR      = new ParameterType((short)  3);
ParameterType* ParameterType::STRING    = new ParameterType((short)  4);
ParameterType* ParameterType::BOOLEAN   = new ParameterType((short)  5);
ParameterType* ParameterType::LIST      = new ParameterType((short)  6);
ParameterType* ParameterType::ARRAY     = new ParameterType((short)  7);
ParameterType* ParameterType::TABLE     = new ParameterType((short)  8);
ParameterType* ParameterType::RESULT    = new ParameterType((short)  9);
ParameterType* ParameterType::COMMENT   = new ParameterType((short) 10);
ParameterType* ParameterType::PARAMETER = new ParameterType((short) 11);
