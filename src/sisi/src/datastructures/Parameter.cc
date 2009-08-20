/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: Parameter.cc,v $	
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
//  $Date: 1998/03/19 09:59:07 $
//
//  Description
//    Class Parameter derived from class InfoType.
//    Available Types are: UNKNOWN, INT, FLOAT, STRING,
//                         LIST, TABLE and COMMENT.<br>
//
//  $Log: Parameter.cc,v $
//  Revision 1.1  1998/03/19 09:59:07  kai
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////

#include "datastructures/ArrayParameter.hh"
#include "datastructures/BooleanParameter.hh"
#include "datastructures/CommentParameter.hh"
#include "datastructures/CharParameter.hh"
#include "datastructures/IntParameter.hh"
#include "datastructures/ListParameter.hh"
#include "datastructures/FloatParameter.hh"
#include "datastructures/ResultParameter.hh"
#include "datastructures/StringParameter.hh"
#include "datastructures/TableParameter.hh"

/** Creates a new parameter from the given type via new. */
Parameter* Parameter::newParameter(ParameterType* type) {
  Parameter* result = NULL;
  if( type == ParameterType::INT )
    result = new IntParameter();
  else if ( type == ParameterType::FLOAT )
    result = new FloatParameter();
  else if ( type == ParameterType::CHAR )
    result = new CharParameter();
  else if ( type == ParameterType::STRING )
    result = new StringParameter();
  else if ( type == ParameterType::BOOLEAN )
    result = new BooleanParameter();
  else if ( type == ParameterType::COMMENT )
    result = new CommentParameter();
  else if ( type == ParameterType::ARRAY )
    result = new ArrayParameter();
  else if ( type == ParameterType::LIST )
    result = new ListParameter();
  else if ( type == ParameterType::TABLE )
    result = new TableParameter();
  else if ( type == ParameterType::RESULT )
    result = new ResultParameter();
  else if ( type == ParameterType::PARAMETER )
    result = new Parameter(ParameterType::PARAMETER);
  return result;
}
