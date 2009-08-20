/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: Parameter.hh,v $	
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
//  $Revision: 1.15 $
//  $Date: 1998/04/07 09:07:27 $
//
//  Description
//    Class Parameter derived from class InfoType.
//    Available Types are: UNKNOWN, INT, FLOAT, STRING,
//                         LIST, TABLE and COMMENT.<br>
//
//  $Log: Parameter.hh,v $
//  Revision 1.15  1998/04/07 09:07:27  kai
//  copyFrom and copyHeaderFrom changed.
//
//  Revision 1.14  1998/04/06 18:39:05  kai
//  CopyFrom and CopyHeaderFrom are now virtual.
//
//  Revision 1.13  1998/04/06 13:15:16  kai
//  readName changed (readSpecifier instead of readIdentifier).
//
//  Revision 1.12  1998/03/23 13:15:25  kai
//  void copyHeaderFrom(Parameter* source) added.
//
//  Revision 1.11  1998/03/22 12:52:09  kai
//  void copyFrom(Parameter* source) added.
//
//  Revision 1.10  1998/03/19 09:05:56  kai
//  static Parameter* newParameter(ParameterType* type) added.
//
//  Revision 1.9  1998/03/16 13:21:35  kai
//  TwoWayListElement::className is now set.
//
//  Revision 1.8  1998/03/15 09:57:51  kai
//  Parameter::COMMENT in readName(...) removed.
//
//  Revision 1.7  1998/03/15 07:56:27  kai
//  *** empty log message ***
//
//  Revision 1.6  1998/03/14 17:20:38  kai
//  Read... and print... structure changed.
//
//  Revision 1.5  1998/03/13 10:42:25  reinhard
//  static String getTypeAsString(ParameterType) sustituted by
//  String asString().
//
//  Revision 1.4  1998/03/05 14:01:56  kai
//  prefix in output routines added.
//
//  Revision 1.3  1998/02/20 09:59:04  kai
//  FileParser changed (get->read)!
//
//  Revision 1.2  1998/02/19 11:24:48  kai
//  Some unused parameters removed.
//
//  Revision 1.1  1998/02/13 17:18:03  reinhard
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _Parameter_hh_
#define _Parameter_hh_

#include "common/CharacterHandler.hh"
#include "datastructures/InfoType.hh"
#include "datastructures/ParameterType.hh"
#include "iostreams/FileParser.hh"


class Parameter: public InfoType
{
public:
  ///////////////////////////////////////////////////////////////////////////
  //
  // Constructors:
  //
  /** Default constructor (Unknown-Parameter). */
  Parameter() {
    // Protected variable of TwoWayListElement for identification of class:
    _type = ParameterType::UNKNOWN;
  }

  /** Constructor Parameter from type short. */
  Parameter(ParameterType* type) {
    // Protected variable of TwoWayListElement for identification of class:
    className = "Parameter";
    _type = type;
  }

  ///////////////////////////////////////////////////////////////////////////
  //
  // public static access:
  //
  /** Creates a new parameter from the given type via new. */
  static Parameter* newParameter(ParameterType* type);
  ///////////////////////////////////////////////////////////////////////////
  //
  // public access:
  //
  /** Copies all variables from another Parameter. */
  virtual void copyFrom(Parameter* source) {
    InfoType::copyFrom(source);
    _type = source->_type;
  }

  /** Copies header from another Parameter. */
  virtual void copyHeaderFrom(Parameter* source) {
    InfoType::copyFrom(source);
    _type = source->_type;
  }

  /** Gets the type of parameter. */
  ParameterType* getType() { return _type; }

  /** Sets the value to the given String. */
  virtual void setValue(const char*) { };

  /** Reads the name of the parameter from the given FileParser. */
  void readName(FileParser& parser) {
    String name;
    parser.readSpecifier(name);           // Reads name.
    setName(name);                        // Sets the name in InfoType.
  }
  /** Reads the Parameter from an opened FileParser. This method
   *  should be overwritten by complex parameters like lists, tables and
   *  so on. It mustn't be overwritten for single parameters like ints,
   *  floats, chars and so on. */
  virtual void read(FileParser& parser) {
    readName(parser);    // Reads the name of the parameter.
    readValue(parser);   // Reads first value and then
    readHeader(parser);  // reads header.
  }
  /** Reads the value of the parameter from an opened FileParser.<BR>
   *  (This method isn't defined for class Parameter and produces an
   *  internal error if called. Childs have to overwrite this method!) */
  virtual void readValue(FileParser&) {
    cerr << "*** Internal Error in '" << __FILE__ << "', line " << __LINE__
	 << ", $Revision: 1.15 $ ***\n*** (Method readValue isnt't declared "
	 << "for parameter from type " << _type->asString() << ".)\n";
  }
  /** Reads the Header (InfoType etc.) from an opened FileParser. This
   *  method should be overwritten by complex parameters like lists,
   *  tables and so on. It mustn't be overwritten for single parameters
   *  like ints, floats, chars and so on. */
  virtual void readHeader(FileParser& parser) {
    readInfoType(parser);           // Reads InfoType from FileParser.
  }
  /** Writes the parameter to the given stream (Should be overwritten by
   *  complex parameters). */
  virtual void print(ostream& out, const char* prefix = "") {
    printPrefix(out, prefix);
    out << "\t";
    printValue(out);
    printHeader(out, prefix);
  }
  /** Prints the value of the parameter.<BR>
   *  (This method isn't defined for class Parameter and produces an
   *  internal error if called. Childs have to overwrite this method!) */
  virtual void printValue(ostream&, const char* = "") {
    cerr << "*** Internal Error in '" << __FILE__ << "', line " << __LINE__
 	 << ", $Revision: 1.15 $ ***\n*** (Method printValue isnt't declared "
 	 << "for parameter from type " << _type->asString() << ".)\n";
  }
  /** Writes the parameter to the given stream (Should be overwritten by
   *  complex parameters). */
  virtual void printHeader(ostream& out, const char* prefix = "") {
    printInfoType(out, prefix);           // Method of InfoType class.
  }

protected:
  ///////////////////////////////////////////////////////////////////////////
  //
  // private access:
  //
  /** Writes the parameter to the given stream (Should be overwritten by
   *  complex parameters). */
  virtual void printPrefix(ostream& out, const char* prefix = "") {
    out << prefix << _type->asString() << "\t" << getName();
  }

private:
  ///////////////////////////////////////////////////////////////////////////
  //
  // private access:
  //
  ParameterType* _type;
};

#endif // _Parameter_hh_
