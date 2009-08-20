/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: ResultElement.cc,v $	
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
//  $Revision: 1.8 $
//  $Date: 1998/04/17 08:06:06 $
//
//  Description
//    Manages a result entry.
//
//
//  $Log: ResultElement.cc,v $
//  Revision 1.8  1998/04/17 08:06:06  reinhard
//  Output of twodimensional arrays now implemented.
//
//  Revision 1.7  1998/04/16 08:54:41  kai
//  Bugfix: Use long instead of int.
//
//  Revision 1.6  1998/04/06 20:26:42  kai
//  Lot of changes (arrays now supported).
//
//  Revision 1.5  1998/03/12 15:54:48  kai
//  DEFAULT_PRECISION added. Negative precision values means now ignoring
//  precision. Meaning of precision changed! (See Round::doubleToString!)
//
//  Revision 1.4  1998/03/10 11:30:57  kai
//  _precision < 0 in constructor now impossible.
//
//  Revision 1.3  1998/03/10 07:50:31  kai
//  Adaption to Borland C++ Compiler 4.02.
//
//  Revision 1.2  1998/03/08 00:26:37  kai
//  *** empty log message ***
//
//  Revision 1.1  1998/03/05 08:01:33  kai
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////

#include "cppinc.h"
#include "development/ResultElement.hh"
#include "math/Round.hh"

ResultElement::ResultElement(long* value, IntParameter* par,
			     int precision)
  : _intValue(value), _precision(precision)
{
  // Protected variable of TwoWayListElement for identification of class:
  className = "ResultElement";
  _headParameter = new IntParameter();
  _headParameter->copyFrom((Parameter*) par);
  _headParameter->setOutputVariable(false);
  if( _precision > MAX_PRECISION )
    _precision = DEFAULT_PRECISION;
}
ResultElement::ResultElement(double* value, FloatParameter* par,
			     int precision)
  : _floatValue(value), _precision(precision)
{
  // Protected variable of TwoWayListElement for identification of class:
  className = "ResultElement";
  _headParameter = new FloatParameter();
  _headParameter->copyFrom((Parameter*) par);
  _headParameter->setOutputVariable(false);
  if( _precision > MAX_PRECISION )
    _precision = DEFAULT_PRECISION;
}
ResultElement::ResultElement(long** array, ArrayParameter* par,
			     int precision)
  : _intArray(array),
    _precision(precision)
{
  // Protected variable of TwoWayListElement for identification of class:
  className = "ResultElement";
  _headParameter = new ArrayParameter();
  _headParameter->copyFrom((Parameter*) par);
  _headParameter->setOutputVariable(false);
  ((ArrayParameter*) _headParameter)->copyHeaderFrom(par);
  if( _precision > MAX_PRECISION )
    _precision = DEFAULT_PRECISION;
}
ResultElement::ResultElement(double** array, ArrayParameter* par,
			     int precision)
  : _floatArray(array),
    _precision(precision)
{
  // Protected variable of TwoWayListElement for identification of class:
  className = "ResultElement";
  _headParameter = new ArrayParameter();
  _headParameter->copyFrom((Parameter*) par);
  _headParameter->setOutputVariable(false);
  ((ArrayParameter*) _headParameter)->copyHeaderFrom(par);
  if( _precision > MAX_PRECISION )
    _precision = DEFAULT_PRECISION;
}
ResultElement::~ResultElement() {
#ifdef __DESTRUCTOR_DEBUG__
    cout << "- Destructor for ResultElement " << getName() << " called.";
#endif
    delete _headParameter;
}
String ResultElement::getName() { return _headParameter->getName(); }
void ResultElement::setPrecision(int p) {
  if( _precision > MAX_PRECISION )
    _precision = DEFAULT_PRECISION;
  else
    _precision = p;
}

Parameter* ResultElement::getHeadParameter() {
  return _headParameter;
}

void ResultElement::headerOutput(ostream& out) {
  _headParameter->printHeader(out);
}
void ResultElement::valueOutput(ostream& out)
{
  if( _headParameter->getType() == ParameterType::INT )
    out << *_intValue;
  else if( _headParameter->getType() == ParameterType::FLOAT )
    out << Round::doubleToString(*_floatValue, _precision);
  else if( _headParameter->getType() == ParameterType::ARRAY ) {
    ArrayParameter* tmp = (ArrayParameter*) _headParameter;
    if( tmp->getDimension() == 1 ) {
      if( tmp->getTypeOfArray() == ParameterType::INT ) {
	if( _intArray != NULL )
	  for( unsigned int row=0; row<tmp->getLength(); row++ ) {
	    if( row > 0 )
	      out << "\t";
	    out << (*_intArray)[row];
	  }
      }
      else {
	if( _floatArray != NULL )
	  for( unsigned int row=0; row<tmp->getLength(); row++ ) {
	    if( row > 0 )
	      out << "\t";
	    out << Round::doubleToString((*_floatArray)[row], _precision);
	  }
      }
    }
    else if( tmp->getDimension() == 2 ) {
      if( tmp->getTypeOfArray() == ParameterType::INT ) {
	if( _intArray != NULL )
	  for( unsigned int row=0; row<tmp->getNumberOfRows(); row++ ) {
	    out << END_OF_LINE;
	    for( unsigned int col=0; col<tmp->getNumberOfColumns(); col++ ) {
	      out << "\t"
		  << _intArray[row][col];
	    }
	  }
	out << END_OF_LINE;
      }
      else {
	if( _floatArray != NULL )
	  for( unsigned int row=0; row<tmp->getNumberOfRows(); row++ ) {
	    out << END_OF_LINE;
	    for( unsigned int col=0; col<tmp->getNumberOfColumns(); col++ ) {
	      out << "\t"
		  << Round::doubleToString(_floatArray[row][col], _precision);
	    }
	  }
	out << END_OF_LINE;
      }
    }
  }
}
