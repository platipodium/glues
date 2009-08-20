/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: ResultParameter.hh,v $	
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
//  $Revision: 1.14 $
//  $Date: 1998/04/16 09:49:09 $
//
//  Description
//   Class ResutlParameter derived from Class @see Parameter and manages
//   result variables.
//
//  $Log: ResultParameter.hh,v $
//  Revision 1.14  1998/04/16 09:49:09  kai
//  Adapted to java version.
//
//  Revision 1.13  1998/04/06 18:45:19  kai
//  readHeader and printHeader changed.
//
//  Revision 1.12  1998/03/23 16:21:32  kai
//  headParameter implemented.
//
//  Revision 1.12  1998/03/23 13:51:39  kai
//  _headParameter instead of parameter type _type implemented.
//
//  Revision 1.11  1998/03/16 13:21:32  kai
//  TwoWayListElement::className is now set.
//
//  Revision 1.10  1998/03/15 10:31:22  kai
//  Read... and print... structure changed.
//
//  Revision 1.9  1998/03/13 10:52:11  reinhard
//  static String getTypeAsString(ParameterType) sustituted by
//  String asString().
//
//  Revision 1.8  1998/03/12 16:08:08  kai
//  output changed.
//
//  Revision 1.7  1998/03/12 15:56:23  kai
//  DEFAULT_PRECISION is now -1 (meaning to ignore the precision).
//
//  Revision 1.6  1998/03/12 11:54:53  kai
//  ResultParameter could now contain array.
//
//  Revision 1.5  1998/03/10 14:17:52  kai
//  MAX_PRECISION and DEFAULT_PRECISION added.
//
//  Revision 1.4  1998/03/07 23:17:17  kai
//  String _name deleted.
//
//  Revision 1.3  1998/03/07 09:16:56  kai
//  int getPrecision() and bool isActive() added.
//
//  Revision 1.2  1998/03/06 10:41:13  reinhard
//  bool _isActive added.
//
//  Revision 1.1  1998/03/05 14:18:19  kai
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _ResultParameter_hh_
#define _ResultParameter_hh_

#include "datastructures/Parameter.hh"
#include "datastructures/ParameterType.hh"
#include "iostreams/FileParser.hh"

const int MAX_PRECISION = 999;
const int DEFAULT_PRECISION = -1;

class ResultParameter: public Parameter
{
public:
  /** Default constructor. */
  ResultParameter()
    : Parameter(ParameterType::RESULT)
  {
    // Protected variable of TwoWayListElement for identification of class:
    className = "ResultParameter";

    _headParameter = Parameter::newParameter(ParameterType::FLOAT);
    _precision     = DEFAULT_PRECISION;
    _isActive      = false;
 }
  ~ResultParameter() {
    delete _headParameter;
#ifdef __DESTRUCTOR_DEBUG__
    cout << "- Destructor for "
	 << ParameterType::RESULT->asString()
	 << " " << getName() << " called.\n";
#endif
  }

  /** Gets the head parameter. This is usefully for complex containing
   *  types, e.g. arrays for get the dimension and so on. */
  Parameter* getHeadParameter() { return _headParameter; }

  /** Sets the precision to the given long value. */
  void setPrecision(int precision) {
    if( precision<0 || precision>MAX_PRECISION )
      _precision = DEFAULT_PRECISION;
    else
      _precision = precision;
  }
  /** Returns the precision value. */
  int getPrecision() { return _precision; }

  /** Returns the active value. */
  bool isActive() { return _isActive; }

  /** Reads the Parameter from an opened FileParser. */
  void read(FileParser& parser) {
    readName(parser);    // Reads the name of the parameter.
    readHeader(parser);  // reads header.
  }
  /** Reads the header from an opened FileParser. */
  void readHeader(FileParser& parser) {
    String         s;
    long           l;
    ParameterType* type;
    bool           readType      = false;     // Is type correct read?
    bool           readPrecision = false;     // Is precision correct read?
    bool           readActive    = false;     // Is active correct read?
    String         name          = getName(); // Stores name.
    readInfoType(parser);           // Reads InfoType from FileParser.
    while ( parser.good() ) { // Since FileParser readable:
      if( parser.readCommand(s) && s.length() > 0 ) {
        if( !readType && s.compareTo("type")==0 ) { // Reads type.
          parser.readIdentifier(s);                             // Reads type.
	  type = ParameterType::getStringAsType(s);
          if( type != ParameterType::INT &&
              type != ParameterType::FLOAT &&
              type != ParameterType::ARRAY ) {
            parser.error("Unsupported result type, trying float ...", s);
            type = ParameterType::FLOAT;
          }
	  delete _headParameter;
          _headParameter = Parameter::newParameter(type);
	  _headParameter->readHeader(parser);
          readType = true;                                    // Type is read.
        }
        else if( s.compareTo("active")==0 ) {
          if( readActive )
            parser.error((String) "Active overwrites old declaration ...",
			 "file");
          parser.readBoolean(_isActive);
          readActive = true;           // Active is read.
        }
        else if( s.compareTo("precision")==0 ) {
          if( readPrecision )
            parser.error((String) "Precision overwrites old declaration ...",
			 "file");
          parser.readLong(l, true);    // true: read positive long.
          setPrecision( (int) l );
        }
        else {
          parser.putBack(s);
          break;
        }
      }
    }
    if( !readType ) {
      parser.error("Missing type of result variable, trying float ...", "");
      delete _headParameter;
      _headParameter = Parameter::newParameter(ParameterType::FLOAT);
    }
    readInfoType(parser);           // Reads InfoType from FileParser.
    _headParameter->setName(name);  // Restore name.
    // Result is output variable in every case:
    _headParameter->setOutputVariable(false);
    InfoType::copyFrom(_headParameter);
  }
  
  /** Puts whole parameter in SiSi format into output stream. */
  void print(ostream& out, const char* prefix = "") {
    printPrefix(out, prefix);   // Method of Parameter class.
    out << END_OF_LINE;
    printHeader(out, prefix);
  }
  /** Puts the header and infotype into output stream. */
  void printHeader(ostream& out, const char* prefix = "") {
    out << prefix << "\ttype\t"
	<< _headParameter->getType()->asString() << END_OF_LINE;
    _headParameter->printHeader(out, prefix);
    out << prefix << "\tactive\t";
    if( _isActive )
      out << "true";
    else
      out << "false";
    out << END_OF_LINE;
    if( _precision > 0 )
      out << prefix << "\tprecision\t" << _precision << END_OF_LINE;
  }
private:
  Parameter* _headParameter;
  int        _precision;
  bool       _isActive;
};

#endif // _ResultParameter_hh_
