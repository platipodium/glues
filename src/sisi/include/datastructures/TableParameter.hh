/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: TableParameter.hh,v $	
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
//  $Revision: 1.20 $
//  $Date: 1998/07/27 18:56:20 $
//
//  Description
//    Class TableParameter derived from Class Parameter and manages
//    tables with single types (int, float, String).
//
//
//  $Log: TableParameter.hh,v $
//  Revision 1.20  1998/07/27 18:56:20  reinhard
//  Method hasMoreElements added.
//
//  Revision 1.19  1998/07/11 18:49:49  kai
//  Method setNameOfColumn added.
//
//  Revision 1.18  1998/07/11 13:41:28  kai
//  Method getHeadParameter(const char* name) added.
//
//  Revision 1.17  1998/07/10 10:52:39  reinhard
//  Bugfix in getTypeOfColumn.
//
//  Revision 1.16  1998/07/09 23:23:32  reinhard
//  Method appendColumnHeader returns now pointer to appended ListParameter.
//
//  Revision 1.15  1998/07/08 06:12:38  reinhard
//  Method increaseColumnIterators() returns now bool.
//
//  Revision 1.14  1998/07/08 05:40:00  reinhard
//  Method getNameOfColumn added.
//
//  Revision 1.13  1998/06/11 14:09:02  kai
//  Bugfix in Constructor.
//  Using now method StringHandler.insertEscapeSequences.
//
//  Revision 1.12  1998/06/09 10:23:57  kai
//  Updated with class TableParameter of Java Version.
//
//  Revision 1.11  1998/05/13 16:12:08  reinhard
//  Bugfix in getElement.
//
//  Revision 1.10  1998/05/13 12:40:38  reinhard
//  Methods resetColumnIterators, increaseColumnIterators, getElement
//  and getTypeOfColumn added.
//
//  Revision 1.9  1998/04/06 12:58:32  kai
//  Using CharacterHandler methods instead of Character methods
//  (isIdentifierStart).
//
//  Revision 1.8  1998/03/23 14:20:12  kai
//  void appendColumnHeader(Parameter* headParameter) added.
//
//  Revision 1.7  1998/03/23 07:58:51  kai
//  Now ListParameter.hh included.
//
//  Revision 1.6  1998/03/21 17:28:24  kai
//  printHeader changed.
//
//  Revision 1.5  1998/03/20 13:32:46  reinhard
//  HeadParameter, ArrayParameter added and read/print methods changed.
//
//  Revision 1.4  1998/03/18 13:49:34  reinhard
//  TwoWayListElement::print TwoWayListElement::printValue renamed.
//
//  Revision 1.3  1998/03/16 13:21:06  kai
//  TwoWayListElement::className is now set.
//
//  Revision 1.2  1998/03/14 17:59:00  kai
//  Read... and print... structure changed.
//
//  Revision 1.1  1998/03/13 17:32:08  reinhard
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////


#ifndef _TableParameter_hh_
#define _TableParameter_hh_

#include "common/StringHandler.hh"
#include "datastructures/ListParameter.hh"

class TableParameter: public Parameter {
public:
  ///////////////////////////////////////////////////////////////////////////
  //
  // Constructors and Destructor:
  //
  /** Default constructor. */
  TableParameter()
    : Parameter(ParameterType::TABLE) {
    // Protected variable of TwoWayListElement for identification of class:
    className = "TableParameter";
    _columns = NULL;
    initialize();
  }
  
  /** Delete the containing list and give the memory free. */
  ~TableParameter() {
#ifdef __DESTRUCTOR_DEBUG__
    cout << "- Destructor for " << ParameterType::TABLE->asString()
	 << " " << getName() << " called ..." << END_OF_LINE;
#endif
    if( _columns ) {
      ListParameter* el;
      while( ( el=(ListParameter*) _columns->removeFirstElement() )
	     != NULL ) {
	delete el;
      }
      delete _columns;
    }
#ifdef __DESTRUCTOR_DEBUG__
    cout << "- Destructor for table " << getName() << " done."
	 << END_OF_LINE;
#endif
  }

  ///////////////////////////////////////////////////////////////////////////
  //
  // public access:
  //
  /** Sets the filename to the given String. The table data will then be
   *  read from the given file. */
  void setFilename(const char* name) { _filename = name; }

  /** Appends new column to the table with the given head. */
  ListParameter* appendColumnHeader(Parameter* headParameter) {
    ListParameter* col = new ListParameter();
    _columns->appendElement(col);
    col->setHeadParameter(headParameter);
    col->setName(headParameter->getName());
    return col;
  }

  /** Resets all column iterators. */
  void resetColumnIterators() {
    ListParameter* col = (ListParameter*) _columns->resetIterator();
    while( col != NULL ) {
      col->resetIterator();
      col = (ListParameter*) _columns->nextElement();
    }
  }

  /** Returns true if all iterators has successors. */
  bool hasMoreElements() {
    ListParameter* col = (ListParameter*) _columns->resetIterator();
    while( col != NULL ) {
      if( !col->hasMoreElements() )
	return false;                  // Iterator points to NULL.
      col = (ListParameter*) _columns->nextElement();
    }
    return true;
  }

  /** Increases all column iterators. Returns true if all iterator
   *  succesfully increased without pointing to NULL. Otherwise false. */
  bool increaseColumnIterators() {
    ListParameter* col = (ListParameter*) _columns->resetIterator();
    while( col != NULL ) {
      if( col->nextElement() == NULL )
	return false;                  // Iterator points to NULL.
      col = (ListParameter*) _columns->nextElement();
    }
    return true;
  }

  /** Gets the actual element (iterator) of the given column. */
  TwoWayListElement* getElement(const char* name) {
    ListParameter* col = (ListParameter*) _columns->getElement(name);
    if( col != NULL )
      return col->actualElement();
    return NULL;
  }
  
  /** Gets the type of the given column (UNKNOWN if doesn't exist). */
  ParameterType* getTypeOfColumn(const char* name) {
    ListParameter* col = (ListParameter*) _columns->getElement(name);
    if( col )
      return col->getTypeOfElements();
    return ParameterType::UNKNOWN;
  }

  /** Gets the head parameter. This is usefully for complex containing
   *  types, e.g. arrays for get the dimension and so on. */
  Parameter* getHeadParameter(const char* name) {
    ListParameter* col = (ListParameter*) _columns->getElement(name);
    if( col )
      return col->getHeadParameter();
    return NULL;
  }

  /** Gets the name of the column with the given number. */
  String getNameOfColumn(int number) {
    ListParameter* col = (ListParameter*) _columns->getElement(number);
    if( col != NULL )
      return col->getName();
    return "";
  }
 
  /** Sets the name of the column with the given number. */
  bool setNameOfColumn(int number, const char* name) {
    ListParameter* col = (ListParameter*) _columns->getElement(number);
    if( col == NULL )
      return false;
    col->setName(name);
    return true;
  }
 
  /** Gets the value as String. */
  String getValueAsString() { return "(table)"; }

  /** Gets the Table as a TwoWayList of a TwoWayList. */
  TwoWayList* getValue() {
    if( _filename.length() > 0 ) {
      FileParser parser;
      String message = parser.open(_currentDirectory + FILE_SEPARATOR +
				   _filename);
      if( message.compareTo("OK") == 0 )
	readValue(parser);
      parser.close();
    }
    return _columns;
  }
  
  /** Puts whole parameter in SiSi format into output stream. */
  void print(ostream& out, const char* prefix = "") {
    printPrefix(out, prefix);   // Method of Parameter class.
    out << END_OF_LINE;
    printHeader(out, prefix);
    if( _filename.length() == 0 ) {
      out << prefix << "data" << END_OF_LINE;
      printValue(out, prefix);
      out << prefix << "end" << END_OF_LINE;
    }
  }
  /** Puts the header and infotype into output stream. */
  void printHeader(ostream& out, const char* prefix = "") {
    printInfoType(out, prefix); // Method of InfoType class.
    if( _filename.length() > 0 )
      out << prefix << "\tfile\t\t\""
	  << StringHandler::insertEscapeSequences(_filename) << "\""
	  << END_OF_LINE;
    ListParameter* col = (ListParameter*) _columns->resetIterator();
    while( col != NULL ) {
      out << prefix << "\tcolumn\t\""
	  << StringHandler::insertEscapeSequences(col->getName()) << "\"\t";
      col->printHeader(out, prefix);
      // Method of InfoType class.
      col = (ListParameter*) _columns->nextElement();
    }
  }

  /** Puts value into output stream. Prints first the given prefix at
   *  the beginning of every line. */
  void printValue(ostream& out, const char* prefix = "") {
    if( _filename.length() == 0 ) {
      TwoWayListElement* el;
      ListParameter* col;
      resetColumnIterators();
      while( true ) {
	col = (ListParameter*) _columns->resetIterator();
	if( col == NULL )
	  break;
	while( col != NULL ) {
	  el = col->actualElement();
	  if( el == NULL )
	    return;
	  if( el->isFromClass("ArrayParameter") &&
	      ((ArrayParameter*) el)->getDimension() > 1 )
	    el->printValue(out, (String) prefix + "\t");
	  else {
	    out << "\t";
	    el->printValue(out);
	  }
	  el = col->nextElement();
	  col = (ListParameter*) _columns->nextElement();
	}
	out << END_OF_LINE;
      }
    }
    else
      out << prefix << "(file: \""
	  << StringHandler::insertEscapeSequences(_filename) << "\""
	  << END_OF_LINE;
  }

  /** Reads the Parameter from an opened FileParser. */
  void read(FileParser& parser) {
    String s;
    readName(parser);    // Reads the name of the parameter.
    readHeader(parser);  // reads header.
    if( !_existsError && _filename.length() == 0 )
      if( parser.readCommand(s) && s.compareTo("data")!=0 ) {
	parser.error((String) "Missing keyword 'data' or declaration of " +
		     "reference to file", "");
	_existsError = true;
      }
    if( !_existsError && _filename.length() == 0 ) {
      readValue(parser);   // Reads first value and then
      parser.readCommand(s);
      if( s.compareTo("end") != 0 )
	parser.error("Keyword 'end' expected", s);
    }
    _existsError = false;
  }
  /** Reads the header from an opened FileParser. */
  void readHeader(FileParser& parser) {
    String s;
    String name;
    ListParameter* col = NULL;
    bool readFilename  = false; // Is keyword file read?

    initialize();
    readInfoType(parser);           // Reads InfoType from FileParser.
    while ( parser.good() ) { // Since FileParser readable:
      if( parser.readCommand(s) && s.length() > 0 ) {
	if( s.compareTo("column")==0 ) { // Reads column's head.
	  if( col != NULL )
	    _columns->appendElement(col);
	  col = new ListParameter();
	  parser.readString(name);                   // Reads name.
	  col->setName( name );                      // Sets name.
	  col->readHeader(parser); // Gets Header and InfoType from FileParser.
	} // if( s.compareTo("column")==0 )
	else if( s.compareTo("file")==0 ) {
	  if( readFilename )
	    parser.error((String) "Reference to file already exists, " +
			 "overwriting old declaration ...", "file");
	  parser.readString(s);
	  _filename = s;
	  _currentDirectory = parser.getDirectory();
	  readFilename = true;             // Filename is read.
	}
	else {
	  parser.putBack(s);
	  break;
	}
      } // if( parser.readCommand(s.ref) && s.length() > 0 )
    } // while ( parser.good() )
    if( col != NULL )
      _columns->appendElement(col);
  }
  /** Reads the list data from an opened FileParser. */
  void readValue(FileParser& parser) {
    String s;
    long   l;
    double d;
    Parameter* el;
    ListParameter* col = NULL;
    TwoWayListIntElement*    intel;
    TwoWayListFloatElement*  floatel;
    TwoWayListStringElement* stringel;
    int c;
    while( parser.good() ) {
      c = parser.peekChar();
      if( CharacterHandler::isIdentifierStart(c) )
	return;
      col = (ListParameter*) _columns->resetIterator();
      if( col == NULL ) {
	parser.error("Oups, no columns defined ...", "");
	break;
      }
      while( parser.good() && col != NULL ) {
	if( col->getTypeOfElements() == ParameterType::INT ) {
	  parser.readLong(l);
	  intel = new TwoWayListIntElement(l);
	  col->appendElement(intel);
	}
	else if( col->getTypeOfElements() == ParameterType::FLOAT ) {
	  parser.readDouble(d);
	  floatel = new TwoWayListFloatElement(d);
	  col->appendElement(floatel);
	}
	else if( col->getTypeOfElements() == ParameterType::STRING ) {
	  parser.readString(s);
	  stringel = new TwoWayListStringElement(s);
	  col->appendElement(stringel);
	}
	else if( col->getTypeOfElements() == ParameterType::ARRAY ) {
	  el = new ArrayParameter();
	  ((ArrayParameter*) el)->copyHeaderFrom((ArrayParameter*)
						 col->getHeadParameter());
	  ((ArrayParameter*) el)->readValue(parser);
	  col->appendElement(el);
	}

	col = (ListParameter*) _columns->nextElement();
      }
    }
  }
private:
  ///////////////////////////////////////////////////////////////////////////
  //
  // private access:
  //
  /** Initializes all variables for new array (e.g. called by constructor
   *  and setTypeOfElements...) */
  void initialize() {
    if( _columns ) {
      ListParameter* el;
      while( ( el=(ListParameter*) _columns->removeFirstElement() )
	     != NULL ) {
	delete el;
      }
      delete _columns;
    }
    _columns          = new TwoWayList();
    _filename         = "";
    _currentDirectory = "";
    _existsError      = false;
  }

  TwoWayList* _columns;
  String      _filename;
  String      _currentDirectory;
  bool        _existsError;
};

#endif // _TableParameter_hh_
