/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: InfoType.hh,v $	
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
//  $Revision: 1.9 $
//  $Date: 1998/06/12 10:56:56 $
//
//  Description
//    Class InfoType contains informations like name, description, unit
//    and range (used e.g. by @see Parameter).
//
//  $Log: InfoType.hh,v $
//  Revision 1.9  1998/06/12 10:56:56  reinhard
//  In method readInfoType: Use now String::trim().
//
//  Revision 1.8  1998/03/22 12:51:34  kai
//  void copyFrom(InfoType* source) added.
//
//  Revision 1.7  1998/03/16 13:22:52  kai
//  TwoWayListElement::className is now set.
//
//  Revision 1.6  1998/03/14 16:07:51  kai
//  END_OF_LINE inserted.
//
//  Revision 1.5  1998/03/13 17:12:49  reinhard
//  readInfoType is now public.
//
//  Revision 1.4  1998/03/05 14:02:16  kai
//  prefix in output routines added.
//
//  Revision 1.3  1998/03/05 07:51:20  kai
//  _isOutputVariable added.
//
//  Revision 1.2  1998/02/20 09:59:08  kai
//  FileParser changed (get->read)!
//
//  Revision 1.1  1998/02/13 17:20:06  reinhard
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _InfoType_hh_
#define _InfoType_hh_

#include "cppinc.h"
#include "datastructures/String.hh"
#include "twowaylist/TwoWayListElement.hh"
#include "iostreams/FileParser.hh"

class InfoType : public TwoWayListElement
{
public:
  ///////////////////////////////////////////////////////////////////////////
  //
  // public static access:
  //
  ///////////////////////////////////////////////////////////////////////////
  //
  // Constructors:
  //
  /** Default constructor. */
  InfoType() {
    // Protected variable of TwoWayListElement for identification of class:
    className = "InfoType";

    _name        = "noname";
    _description = "";
    _unit        = "";
    _range       = "";
    _isOutputVariable = false;
    _isVariationVariable = false;
  }
  
  ///////////////////////////////////////////////////////////////////////////
  //
  // public access (nonstatic):
  //
  /** Copies all variables from another InfoType. */
  void copyFrom(InfoType* source) {
    if( source != NULL ) {
      _name             = source->_name;
      _description      = source->_description;
      _unit             = source->_unit;
      _range            = source->_range;
      _isOutputVariable = source->_isOutputVariable;
      _isVariationVariable = source->_isVariationVariable;
    }
  }

  /** Puts InfoType into output stream. */
  void printInfoType(ostream& out, const char* prefix = "") {
    if( _unit.length() > 0 )
      out << prefix << "\t\\u " << _unit << END_OF_LINE;
    if( _range.length() > 0 )
      out << prefix << "\t\\r " << _range << END_OF_LINE;
    if( _description.length() > 0 )
      out << prefix << "\t\\d " << _description << END_OF_LINE;
    if( _isOutputVariable )
      out << prefix << "\t\\o # This is an output variable."
	  << END_OF_LINE;
    if( _isVariationVariable )
      out << prefix << "\t\\v # This is a variation variable."
	  << END_OF_LINE;
  }

  /** Set name. */
  void setName(const char* name) {
    if( name!=0 )
      _name = name;
    else
      _name = "";
  }
  
  /** Set description. */
  void setDescription(const char* description) {
    if( description!=0 )
      _description = description;
    else
      _description = "";
  }

  /** Set unit. */
  void setUnit(const char* unit) {
    if( unit!=0 )
      _unit = unit;
    else
      _unit = "";
  }

  /** Set range. */
  void setRange(const char* range) {
    if( range!=0 )
      _range = range;
    else
      _range = "";
  }

  /** Set isOutputVariable. */
  void setOutputVariable(bool b) { _isOutputVariable = b; }

  void setVariationVariable(bool b) { _isVariationVariable = b; }

  /** Get name. */
  const char* getName() { return _name; }

  /** Get description. */
  const char* getDescription() { return _description; }

  /** Get unit. */
  const char* getUnit() { return _unit; }

  /** Get range. */
  const char* getRange() { return _range; }

  /** Is this an output variable? */
  bool isOutputVariable() { return _isOutputVariable; }

  bool isVariationVariable() {return _isVariationVariable;}

  /** Reads the InfoType from an opened FileParser. */
  void readInfoType(FileParser& parser) {
    while ( parser.good() && parser.peekChar()=='\\' ) {
      String s;
      parser.readCommand(s);
      if( s.compareTo("\\u") == 0 ) { // Reads unit.
	parser.overreadCommentsAndWhiteSpaces();
	// Read sentence terminated by newline, '\\' or control character:
	parser.readSentence(s);
	_unit = s.trim();
      }
      else if( s.compareTo("\\r") == 0 ) { // Reads range.
	parser.overreadCommentsAndWhiteSpaces();
	// Read sentence terminated by newline, '\\' or control character:
	parser.readSentence(s);
	_range = s.trim();
      }
      else if( s.compareTo("\\d") == 0 ) { // Reads description.
	parser.overreadCommentsAndWhiteSpaces();
	// Read sentence terminated by newline, '\\' or control character:
	parser.readSentence(s);
	_description = s.trim();
      }
      else if( s.compareTo("\\o") == 0 ) { // Is output variable.
	_isOutputVariable = true;
      }
      else if( s.compareTo("\\v") == 0 ) {_isVariationVariable=true;}
       else
	parser.error( "Unknown SiSi command", s );
    }
  }
protected:
  ///////////////////////////////////////////////////////////////////////////
  //
  // protected access:
  //
  /** Compares the Parameter ID (name) with the given String. */
  bool compareTo(const char* identification) {
    return _name.compareTo(identification)==0 ? true : false; }

private:
  ///////////////////////////////////////////////////////////////////////////
  //
  // private access:
  //
  String _name;
  String _description;
  String _unit;
  String _range;
  bool   _isOutputVariable;
  bool   _isVariationVariable;
};

#endif // _InfoType_hh_
