/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: ListParameter.hh,v $
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
//  $Revision: 1.17 $
//  $Date: 1998/07/27 18:56:53 $
//
//  Description
//   Class ListParameter derived from class Parameter and manages
//   lists with single types (int, float, String).
//   (Supports __DESTRUCTOR_DEBUG__)
//
//  $Log: ListParameter.hh,v $
//  Revision 1.17  1998/07/27 18:56:53  reinhard
//  Method hasMoreElements added.
//
//  Revision 1.16  1998/04/06 12:55:17  kai
//  Using CharacterHandler methods instead of Character methods
//  (isIdentifierStart).
//
//  Revision 1.15  1998/03/23 14:21:05  kai
//  void copyHeaderFrom(ListParameter* source) and void
//  setHeadParameter(Parameter* headParameter) added.
//
//  Revision 1.14  1998/03/21 17:29:27  kai
//  print, printHeader and readHeader changed.
//
//  Revision 1.13  1998/03/21 08:53:03  kai
//  *** empty log message ***
//
//  Revision 1.12  1998/03/21 08:11:00  kai
//  *** empty log message ***
//
//  Revision 1.11  1998/03/20 13:32:19  reinhard
//  HeadParameter, ArrayParameter added and read/print methods changed.
//
//  Revision 1.10  1998/03/16 13:21:13  kai
//  TwoWayListElement::className is now set.
//
//  Revision 1.9  1998/03/16 13:19:12  kai
//  bool _deleteListInDestructor added.
//
//  Revision 1.8  1998/03/14 17:20:31  kai
//  Read... and print... structure changed.
//
//  Revision 1.7  1998/03/13 17:32:29  reinhard
//  setTypeOfElements added.
//
//  Revision 1.6  1998/03/13 16:46:35  reinhard
//  _elements is now pointer to TwoWayList;
//
//  Revision 1.5  1998/03/13 10:52:17  reinhard
//  static String getTypeAsString(ParameterType) sustituted by
//  String asString().
//
//  Revision 1.4  1998/03/05 14:50:16  kai
//  ListParameter can now contain Parameters.
//
//  Revision 1.3  1998/02/20 09:58:41  kai
//  FileParser changed (get->read)!
//
//  Revision 1.2  1998/02/15 10:17:55  kai
//  Destructor with debug message added.
//
//  Revision 1.1  1998/02/15 10:05:00  kai
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _ListParameter_hh_
#define _ListParameter_hh_

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include "datastructures/ArrayParameter.hh"
#include "datastructures/Parameter.hh"
#include "datastructures/ParameterType.hh"
#include "iostreams/FileParser.hh"
#include "iostreams/SiSiParser.hh"
#include "twowaylist/TwoWayList.hh"
#include "twowaylist/TwoWayListIntElement.hh"
#include "twowaylist/TwoWayListFloatElement.hh"
#include "twowaylist/TwoWayListStringElement.hh"

class ListParameter: public Parameter
{
public:
  ///////////////////////////////////////////////////////////////////////////
  //
  // Constructors and Destructor:
  //
  /** Default constructor. */
  ListParameter()
    : Parameter(ParameterType::LIST)
  {
    // Protected variable of TwoWayListElement for identification of class:
    className = "ListParameter";

    _headParameter  = NULL;
    _elements       = new TwoWayList();
    _existsError    = false;

    _deleteListInDestructor = true; // Delete list if destructor called.
  }
  /** Delete the containing list and give the memory free. */
  ~ListParameter() {
#ifdef __DESTRUCTOR_DEBUG__
    cout << "- Destructor for "
	 << ParameterType::LIST->asString()
	 << " " << getName() << " called (list ";
    if( _deleteListInDestructor )
      cout << "will be deleted).\n";
    else
      cout << "won't be deleted).\n";
#endif
    if( _deleteListInDestructor ) {
      TwoWayListElement* el;
      while( ( el=(TwoWayListElement*) _elements->removeFirstElement() )
	     != NULL ) {
#ifdef __DESTRUCTOR_DEBUG__
	cout << "    ";
	el->printValue(cout);
	cout << END_OF_LINE;
#endif
	delete el;
      }
      delete _elements;
    }
    if( _headParameter != NULL )
      delete _headParameter;
#ifdef __DESTRUCTOR_DEBUG__
    cout << "- Destructor for list " << getName() << " done.\n";
#endif
  }

  ///////////////////////////////////////////////////////////////////////////
  //
  // public access:
  //

  /** Copies header from another ListParameter. */
  void copyHeaderFrom(ListParameter* source) {
    if( source != NULL ) {
      Parameter::copyFrom(source);
      _headParameter->copyHeaderFrom(source->_headParameter);
    }
  }

  /** Sets type of containing elements. */
  void setTypeOfElements(ParameterType* typeOfElements) {
    if( _headParameter != NULL )
      delete _headParameter;
    _headParameter = Parameter::newParameter(typeOfElements);
  }
  
  /** Gets type of containing elements. */
  ParameterType* getTypeOfElements() { return _headParameter->getType(); }

  /** Gets the head parameter. This is usefully for complex containing
   *  types, e.g. arrays for get the dimension and so on. */
  Parameter* getHeadParameter() { return _headParameter; }

  /** Sets the head parameter. This is usefully for complex containing
   *  types, e.g. arrays for set the dimension and so on. */
  void setHeadParameter(Parameter* headParameter) {
    if( headParameter != NULL ) {
      setTypeOfElements(headParameter->getType());
      _headParameter->copyHeaderFrom(headParameter);
    }
  }

  /** Sets iterator to first element and returns first element. */
  TwoWayListElement* resetIterator() { return _elements->resetIterator(); }

  /** Returns the actual TwoWayListElement. */
  TwoWayListElement* actualElement() { return _elements->actualElement(); }

  /** Has TwoWayList more TwoWayListElements? */
  bool hasMoreElements() { return _elements->hasMoreElements(); }

  /** Returns the next TwoWayListElement. */
  TwoWayListElement* nextElement() { return _elements->nextElement(); }

  /** Appends @see TwoWayListElement to the list. */
  void appendElement(TwoWayListElement* el) { _elements->appendElement(el); }

  /** Returns the value (containing list). */
  TwoWayList* getValue() {
    _deleteListInDestructor = false; // Don't delete list in destructor.
    return _elements;
  }

  /** Puts whole parameter in SiSi format into output stream. */
  void print(ostream& out, const char* prefix = "") {
    printPrefix(out, prefix);   // Method of Parameter class.
    out << END_OF_LINE;
    printInfoType(out, prefix); // Method of InfoType class.
    out << prefix << "\t";
    printHeader(out, prefix);
    out << prefix << "data" << END_OF_LINE;
    printValue(out, prefix);
    out << prefix << "end" << END_OF_LINE;
  }
  /** Puts the header and infotype into output stream. */
  void printHeader(ostream& out, const char* prefix = "") {
    out << "type\t" << _headParameter->getType()->asString() << END_OF_LINE;
    _headParameter->printHeader(out, (String) prefix + "\t" );
  }
  /** Puts value into output stream. */
  void printValue(ostream& out, const char* prefix = "") {
    String pref = (String) prefix + "\t";
    TwoWayListElement* el = _elements->resetIterator();
    while( el != 0 ) {
      if( _headParameter->isFromClass("Parameter") )
	((Parameter*) el)->print(out, pref);
      else {
	el->printValue(out, pref);
	if( !el->isFromClass("ArrayParameter") ||
	    ((ArrayParameter*) el)->getDimension() == 1 )
	  out << END_OF_LINE;
      }
      el = _elements->nextElement();
    }
  }

  /** Reads the Parameter from an opened FileParser. */
  void read(FileParser& parser) {
    String s;
    readName(parser);    // Reads the name of the parameter.
    readHeader(parser);  // reads header.

    if( !_existsError )
      if( parser.readCommand(s) && s.compareTo("data")!=0 ) {
	parser.error((String) "Missing keyword 'data' or declaration of " +
		     "reference to file", "");
	_existsError = true;
      }
      else {
	readValue(parser);   // Reads first value and then
      }
    _existsError = false;
  }
  /** Reads the header from an opened FileParser. */
  void readHeader(FileParser& parser) {
    String s;
    ParameterType* type;
    bool readType      = false; // Is type correct read?

    _existsError       = false; // Does an unrecoverable error occur?
    readInfoType(parser);           // Reads InfoType from FileParser.
    while ( parser.good() ) { // Since FileParser readable:
      if( parser.readCommand(s) && s.length() > 0 ) {
        if( !readType && s.compareTo("type")==0 ) {
          parser.readIdentifier(s);                             // Reads type.
	  type = ParameterType::getStringAsType(s);
          if( type == ParameterType::INT ||
              type == ParameterType::FLOAT ||
              type == ParameterType::STRING ||
	      type == ParameterType::ARRAY ||
	      type == ParameterType::PARAMETER ) {
	    readType = true;                                 // Type is read.
	    setTypeOfElements(type);
	    _headParameter->readHeader(parser);
	  }
        }
        else {
          parser.putBack(s);
          break;
        }
      }
    }
    if( !readType ) {
      parser.error("Unsupported list type, trying float ...",
                   s);
      setTypeOfElements(ParameterType::FLOAT);
    }
    if( _existsError ) {
      parser.error("Ignoring list data ...", "");
      return;
    }
  }
  /** Reads the list data from an opened FileParser. */
  void readValue(FileParser& parser) {
    if( _headParameter == NULL ) {
      parser.error("Sorry, no type for this list defined ..." , "");
      return;
    }
    String s;
    SiSiParser sisiParser;
    long l;
    double d;
    int c;
    TwoWayListElement* el = NULL;
    while ( parser.good() ) { // Since FileParser readable:
      c = parser.peekChar();
      if( CharacterHandler::isIdentifierStart(c) ) {
        parser.readIdentifier(s);
        if( s.compareTo("end") == 0 )
          return;
        else
          parser.putBack(s);
      }
      if( _headParameter->getType() == ParameterType::INT ) {
        parser.readLong(l);
        el = new TwoWayListIntElement( l );
      }
      else if( _headParameter->getType() == ParameterType::FLOAT ) {
        parser.readDouble(d);
        el = new TwoWayListFloatElement( d );
      }
      else if( _headParameter->getType() == ParameterType::STRING ) {
        parser.readString(s);
        el = new TwoWayListStringElement( s );
      }
      else if( _headParameter->getType() == ParameterType::ARRAY ) {
        el = new ArrayParameter();
	((ArrayParameter*) el)->copyHeaderFrom((ArrayParameter*) _headParameter);
	((ArrayParameter*) el)->readValue(parser);
	
      }
      else if( _headParameter->getType() == ParameterType::PARAMETER ) {
	el = sisiParser.parseParameter(parser);
      }
      else {
	cerr << "*** Internal Error in '" << __FILE__ << "', line " << __LINE__
	     << ", $Revision: 1.17 $ ***\n";
	break;
      }
      if( el != NULL ) {
	_elements->appendElement(el);
	el = NULL;
      }
    }
  }

  ///////////////////////////////////////////////////////////////////////////
  //
  // private access:
  //
private:
  TwoWayList*    _elements;
  Parameter*     _headParameter;
  bool           _existsError;
  bool           _deleteListInDestructor;
};

#endif // _ListParameter_hh_
