/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: CommentParameter.hh,v $	
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
//  $Date: 1998/03/16 13:21:23 $
//
//  Description
//   Class CommentParameter derived from class Parameter and manages
//   comments.
//
//  $Log: CommentParameter.hh,v $
//  Revision 1.8  1998/03/16 13:21:23  kai
//  TwoWayListElement::className is now set.
//
//  Revision 1.7  1998/03/15 10:06:50  kai
//  print, printHeader, read and readHeader added.
//
//  Revision 1.6  1998/03/14 17:21:07  kai
//  Read... and print... structure changed.
//
//  Revision 1.5  1998/03/13 10:52:28  reinhard
//  static String getTypeAsString(ParameterType) sustituted by
//  String asString().
//
//  Revision 1.4  1998/03/05 14:15:30  kai
//  prefix in output routines added.
//
//  Revision 1.3  1998/02/20 09:58:57  kai
//  FileParser changed (get->read)!
//
//  Revision 1.2  1998/02/15 10:18:03  kai
//  Destructor with debug message added.
//
//  Revision 1.1  1998/02/13 17:17:44  reinhard
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _CommentParameter_hh_
#define _CommentParameter_hh_

#include "datastructures/Parameter.hh"
#include "datastructures/ParameterType.hh"
#include "datastructures/String.hh"
#include "iostreams/FileParser.hh"

class CommentParameter: public Parameter
{
public:
  /** Default constructor. */
  CommentParameter()
    : Parameter(ParameterType::COMMENT) {
      // Protected variable of TwoWayListElement for identification of class:
      className = "CommentParameter";
  }
  /** Sets the value to given string. */
  CommentParameter(const char* value)
    : Parameter(ParameterType::COMMENT) {
      // Protected variable of TwoWayListElement for identification of class:
      className = "CommentParameter";
      
      _value = value;
  }
  /** Delete the containing list and give the memory free. */
  ~CommentParameter() {
#ifdef __DESTRUCTOR_DEBUG__
    cout << "- Destructor for "
	 << ParameterType::COMMENT->asString()
	 << " " << getName() << " called.\n";
#endif
  }

  /** Sets the value to the given string. */
  void setValue(const char* value) { _value = value; }

  /** Returns the value. */
  const char* getValue() { return _value; }

  /** Reads the Parameter from an opened FileParser. */
  void read(FileParser& parser) {
    readValue(parser);   // Reads first value and then
  }
  /** Reads the comment value from an opened FileParser. */
  void readValue(FileParser& parser) {
    parser.peekChar();       // Overreads white spaces.
    parser.readLine(_value);
  }
  /** Reads the Header (InfoType etc.) from an opened FileParser. */
  void readHeader(FileParser&) { }

  /** Writes the parameter to the given stream. */
  void print(ostream& out, const char* prefix = "") {
    out << prefix << getType()->asString() << " ";
    printValue(out);
    printHeader(out, prefix);
  }
  /** Writes the header to the given stream. */
  void printHeader(ostream&, const char* = "") { }
  /** Prints the value to the given stream. */
  void printValue(ostream& out, const char* prefix = "") {
    out << prefix << _value << END_OF_LINE;
  }
private:
  String _value;
};

#endif // _CommentParameter_hh_
