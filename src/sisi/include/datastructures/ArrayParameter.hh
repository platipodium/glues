/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: ArrayParameter.hh,v $
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
//  $Revision: 1.27 $
//  $Date: 1998/07/17 08:03:42 $
//
//  Description
//   Class ArrayParameter derived from class Parameter and manages
//   arrays.
//
//  $Log: ArrayParameter.hh,v $
//  Revision 1.27  1998/07/17 08:03:42  reinhard
//  Bugfix in setLength().
//
//  Revision 1.26  1998/07/16 12:36:37  reinhard
//  Bugfix in method copyFrom.
//
//  Revision 1.25  1998/07/10 12:35:35  reinhard
//  Methods setNumberOfRows, setNumberOfColumns, setDimension and copyFrom added.
//
//  Revision 1.24  1998/07/09 23:21:35  reinhard
//  Methods setLength and setTypeOfArray added.
//
//  Revision 1.23  1998/06/11 13:19:41  kai
//  Using now method StringHandler.insertEscapeSequences.
//
//  Revision 1.22  1998/04/16 11:22:00  kai
//  Two methods createNewArray added.
//
//  Revision 1.21  1998/04/16 09:49:40  kai
//  Adapted to java version.
//
//  Revision 1.20  1998/04/06 18:40:51  kai
//  copyHeaderFrom changed.
//
//  Revision 1.19  1998/04/06 12:58:27  kai
//  Using CharacterHandler methods instead of Character methods
//  (isIdentifierStart).
//
//  Revision 1.18  1998/03/24 10:18:05  reinhard
//  Bugfix in deleteArrays.
//
//  Revision 1.17  1998/03/23 14:22:33  kai
//  initialize() and unsigned int getLength() added, _type ->
//  _typeOfArray.
//
//  Revision 1.16  1998/03/20 13:32:54  reinhard
//  HeadParameter, ArrayParameter added and read/print methods changed.
//
//  Revision 1.15  1998/03/19 10:50:00  kai
//  ReadHeader reads no more keywords 'data' and 'end'. PrintValue
//  changed.
//
//  Revision 1.14  1998/03/16 13:21:18  kai
//  TwoWayListElement::className is now set.
//
//  Revision 1.13  1998/03/14 17:20:28  kai
//  Read... and print... structure changed.
//
//  Revision 1.12  1998/03/13 14:49:29  reinhard
//  head now implemented.
//
//  Revision 1.11  1998/03/13 10:44:04  reinhard
//  static String getTypeAsString(ParameterType) sustituted by
//  String asString().
//
//  Revision 1.10  1998/03/11 14:48:19  reinhard
//  One dimensional arrays are now available.
//
//  Revision 1.9  1998/03/05 14:01:07  kai
//  prefix in output routines added.
//
//  Revision 1.8  1998/02/25 12:49:07  reinhard
//  Some includes added.
//
//  Revision 1.7  1998/02/20 11:27:30  kai
//  Array will only be deleted in destructor, if get...Array wasn't called
//  at least.
//
//  Revision 1.6  1998/02/20 11:03:23  kai
//  Directory added. Files will be handled relative to directory or
//  absolute.
//
//  Revision 1.5  1998/02/20 09:59:15  kai
//  FileParser changed (get->read)!
//
//  Revision 1.4  1998/02/20 09:16:22  kai
//  getNumberOfRows(), getNumberOfColumns(), getFloatArray(...) and
//  getIntArray(...) added.
//
//  Revision 1.3  1998/02/19 11:27:15  kai
//  Some ints to unsigned ints changed.
//
//  Revision 1.2  1998/02/19 10:05:11  kai
//  ParameterType* getTypeOfArray() added.
//
//  Revision 1.1  1998/02/19 09:29:42  kai
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _ArrayParameter_hh_
#define _ArrayParameter_hh_

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include "cppinc.h"
#include "platform.hh"
#include "common/StringHandler.hh"
#include "common/FilenameHandling.hh"
#include "datastructures/Parameter.hh"
#include "datastructures/ParameterType.hh"
#include "iostreams/FileParser.hh"

class ArrayParameter: public Parameter
{
public:
  /** Default constructor. */
  ArrayParameter()
    : Parameter(ParameterType::ARRAY)
  {
    // Protected variable of TwoWayListElement for identification of class:
    className = "ArrayParameter";

    _head         = NULL;
    _floatArray   = NULL;
    _intArray     = NULL;
    _floatArray2D = NULL;
    _intArray2D   = NULL;
    _typeOfArray  = ParameterType::FLOAT;

    initialize();
  }
  /** Delete the containing list and give the memory free. */
  ~ArrayParameter() {
    if( _deleteArrayInDestructor )
      deleteArrays();
    if( _deleteHeadInDestructor && _head )
      delete [] _head;
#ifdef __DESTRUCTOR_DEBUG__
    cout << "- Destructor for "
	 << ParameterType::ARRAY->asString()
	 << " " << getName() << " called (array ";
    if( _deleteArrayInDestructor )
      cout << "deleted).\n";
    else
      cout << "not deleted).\n";
#endif
  }

  /** Sets length of array (one dimensional). ATTENTION: This method
   *  deletes an existing array! */
  void setLength(unsigned length) {
    deleteArrays();
    _dimension = 1;
    _rows = length;
    _columns = 0;
  }
  /** Sets number of rows of array (one dimensional). ATTENTION: This method
   *  deletes an existing array! */
  void setNumberOfRows(unsigned length) {
    deleteArrays();
    _rows = length;
  }
  /** Sets number of columns of array (one dimensional). ATTENTION: This method
   *  deletes an existing array! */
  void setNumberOfColumns(unsigned length) {
    deleteArrays();
    _columns = length;
  }
  /** Sets dimension of array (1 or 2). ATTENTION: This method
   *  deletes an existing array! */
  void setDimension(short dimension) {
    deleteArrays();
    if( dimension <= 1 )
      _dimension = 1;
    else if( dimension > 1 )
      _dimension = 2;
  }

  /** Sets the type of array. ATTENTION: This method
   *  deletes an existing array! */
  void setTypeOfArray(ParameterType* type) {
    deleteArrays();
    _typeOfArray = type;
  }

  /** Gets type of array (ParameterType::INT of ParameterType::FLOAT). */
  ParameterType* getTypeOfArray() { return _typeOfArray; }

  /** Gets dimension of array (1 or 2). */
  int getDimension() { return _dimension; }

  /** Gets the length of the array (number of rows). */
  unsigned int getLength() { return _rows; }
  
  /** Gets the number of rows. */
  unsigned int getNumberOfRows() { return _rows; }
  
  /** Gets the number of columns. */
  unsigned int getNumberOfColumns() { return _columns; }
  
  /** Gets head if exists. Otherwise null. */
  String* getHead() {
    _deleteHeadInDestructor = false; // Don't delete head in destructor.
    return _head;
  }

  /** Creates a new one dimensional array with the given properties. */
  bool createNewArray(ParameterType* type, int length) {
    if( length <= 0 )
      return false;                    // Unsupported length.
    if( type == ParameterType::INT ) {
      initialize();
      _typeOfArray = type;
      _rows        = length;
      createIntArray();
      return true;
    }
    if( type == ParameterType::FLOAT ) {
      initialize();
      _typeOfArray = type;
      _rows        = length;
      createFloatArray();
      return true;
    }
    return false;                      // Unsupported type.
  }

  /** Creates a new two dimensional array with the given properties. */
  bool createNewArray(ParameterType* type, int rows, int columns) {
    if( rows<=0 || columns<=0 )
      return false;                    // Unsupported dimension.
    if( type == ParameterType::INT ) {
      initialize();
      _typeOfArray = type;
      _rows        = rows;
      _columns     = columns;
      _dimension   = 2;
      createIntArray();
      return true;
    }
    if( type == ParameterType::FLOAT ) {
      initialize();
      _typeOfArray = type;
      _rows        = rows;
      _columns     = columns;
      _dimension   = 2;
      createFloatArray();
      return true;
    }
    return false;                      // Unsupported type.
  }
  
  /** Copies type and dimension from given ArrayParameter. */
  void copyHeaderFrom(Parameter* src) {
    if( src->isFromClass("ArrayParameter") ) {
      InfoType::copyFrom(src);
      _typeOfArray = ((ArrayParameter*) src)->_typeOfArray;
      _rows        = ((ArrayParameter*) src)->_rows;
      _columns     = ((ArrayParameter*) src)->_columns;
      _dimension   = ((ArrayParameter*) src)->_dimension; // 1 or 2 dimension.
    }
    Parameter::copyHeaderFrom(src);
  }
  /** Copies complete ArrayParameter excluding head. */
  void copyFrom(Parameter* src) {
    if( src->isFromClass("ArrayParameter") ) {
      copyHeaderFrom(src);
      if( _typeOfArray == ParameterType::INT )
	createIntArray();
      else
	createFloatArray();
      if( _dimension == 1 ) {
	if( _typeOfArray == ParameterType::INT ) {
	  if( ((ArrayParameter*) src)->_intArray != NULL )
	    for( unsigned row = 0; row<_rows; row++ )
	      _intArray[row]=((ArrayParameter*) src)->_intArray[row];
	}
	else {
	  if( ((ArrayParameter*) src)->_floatArray != NULL )
	    for( unsigned row = 0; row<_rows; row++ )
	      _floatArray[row]=((ArrayParameter*) src)->_floatArray[row];
	}
      }
      else {
	if( _typeOfArray == ParameterType::INT ) {
	  if( ((ArrayParameter*) src)->_intArray2D != NULL )
	    for( unsigned row = 0; row<_rows; row++ )
	      for( unsigned col = 0; col<_columns; col++ )
		_intArray2D[row][col]
		  = ((ArrayParameter*) src)->_intArray2D[row][col];
	}
	else {
	  if( ((ArrayParameter*) src)->_floatArray2D != NULL )
	    for( unsigned row = 0; row<_rows; row++ )
	      for( unsigned col = 0; col<_columns; col++ )
		_floatArray2D[row][col]
		  = ((ArrayParameter*) src)->_floatArray2D[row][col];
	}
      }
      _filename     = ((ArrayParameter*) src)->_filename;
      _directory    = ((ArrayParameter*) src)->_directory;
      _deleteArrayInDestructor
	= ((ArrayParameter*) src)->_deleteArrayInDestructor;
      _deleteHeadInDestructor = true;
    }
  }
  /** Gets the floatArray. If no float array exists and there is a
   *  reference to a float array in a file, it will be read. If no
   *  error occurs, "OK" will be returned. Otherwise the causing
   *  error. */
  String getArray(double** &floatArray) {
    floatArray = NULL;
    if( _typeOfArray != ParameterType::FLOAT ) // Is array from the right type?
      return (String) "Array not from type float!";
    if( _floatArray2D != NULL ) {   // Does an array exist?
      floatArray = _floatArray2D;
      _deleteArrayInDestructor = false; // Don't delete array in destructor.
      return (String) "OK";
    }
    String message = readFastFromFile();
    if( message.compareTo("OK") == 0 ) {
      floatArray = _floatArray2D;
      _deleteArrayInDestructor = false; // Don't delete array in destructor.
    }
    return message;
  }
  /** Gets the floatArray. If no float array exists and there is a
   *  reference to a float array in a file, it will be read. If no
   *  error occurs, "OK" will be returned. Otherwise the causing
   *  error. */
  String getArray(double* &floatArray) {
    floatArray = NULL;
    if( _typeOfArray != ParameterType::FLOAT ) // Is array from the right type?
      return (String) "Array not from type float!";
    if( _floatArray != NULL ) {   // Does an array exist?
      floatArray = _floatArray;
      _deleteArrayInDestructor = false; // Don't delete array in destructor.
      return (String) "OK";
    }
    String message = readFastFromFile();
    if( message.compareTo("OK") == 0 ) {
      floatArray = _floatArray;
      _deleteArrayInDestructor = false; // Don't delete array in destructor.
    }
    return message;
  }

  /** Gets the intArray. If no int array exists and there is a
   *  reference to a int array in a file, it will be read. If no
   *  error occurs, "OK" will be returned. Otherwise the causing
   *  error. */
  String getArray(long** &intArray) {
    intArray = NULL;
    if( _typeOfArray != ParameterType::INT ) // Is array from the right type?
      return (String) "Array not from type int!";
    if( _intArray2D != NULL ) {   // Does an array exist?
      intArray = _intArray2D;
      _deleteArrayInDestructor = false; // Don't delete array in destructor.
      return (String) "OK";
    }
    String message = readFastFromFile();
    if( message.compareTo("OK") == 0 ) {
      intArray = _intArray2D;
      _deleteArrayInDestructor = false; // Don't delete array in destructor.
    }
    return message;
  }

  /** Gets the intArray. If no int array exists and there is a
   *  reference to a int array in a file, it will be read. If no
   *  error occurs, "OK" will be returned. Otherwise the causing
   *  error. */
  String getArray(long* &intArray) {
    intArray = NULL;
    if( _typeOfArray != ParameterType::INT ) // Is array from the right type?
      return (String) "Array not from type int!";
    if( _intArray != NULL ) {   // Does an array exist?
      intArray = _intArray;
      _deleteArrayInDestructor = false; // Don't delete array in destructor.
      return (String) "OK";
    }
    String message = readFastFromFile();
    if( message.compareTo("OK") == 0 ) {
      intArray = _intArray;
      _deleteArrayInDestructor = false; // Don't delete array in destructor.
    }
    return message;
  }

  /** Puts whole parameter in SiSi format into output stream. */
  void print(ostream& out, const char* prefix = "") {
    printPrefix(out, prefix);   // Method of Parameter class.
    out << END_OF_LINE;
    printHeader(out, prefix);
    if( _filename.length() > 0 )
      out << prefix << "\tfile\t\t\""
	  << StringHandler::insertEscapeSequences(_filename) << "\""
	  << END_OF_LINE;
    else {
      out << prefix << "data";
      if( _dimension == 1 )
	out << END_OF_LINE;
      printValue(out, (String) prefix + "\t");
      if( _dimension == 1 )
	out << END_OF_LINE;
      out << prefix << "end" << END_OF_LINE;
    }
  }
  /** Puts the header and infotype into output stream. */
  void printHeader(ostream& out, const char* prefix = "") {
    printInfoType(out, prefix); // Method of InfoType class.
    String tmp = (String) "\tdimension\t" + _rows;
    if( _columns > 0 )
      tmp += (String) " " + _columns;
    out << prefix << "\ttypeOfArray\t" << _typeOfArray->asString()
	<< END_OF_LINE;
    out << prefix << tmp << END_OF_LINE;
    if( _head != NULL && _columns > 0 ) {
      out << prefix << "\thead\t\t\""
	  << StringHandler::insertEscapeSequences(_head[0]) << "\""
	  << END_OF_LINE;
      for( unsigned int i=1; i<_columns; i++ )
	out << prefix << "\t\t\t\""
	    << StringHandler::insertEscapeSequences(_head[i]) << "\""
	    << END_OF_LINE;
    }
  }
  /** Puts value into output stream. */
  void printValue(ostream& out, const char* prefix = "") {
    if( _filename.length() == 0 ) {
      if( _dimension == 1 ) {
	if( _typeOfArray == ParameterType::INT ) {
	  out << prefix;
	  if( _intArray != NULL )
	    for( unsigned int row=0; row<_rows; row++ ) {
	      if( row > 0 )
		out << "\t";
	      out << _intArray[row];
	    }
	  else
	    out << "\t(Not correct read!)" << END_OF_LINE;
	}
	else {
	  out << prefix;
	  if( _floatArray != NULL )
	    for( unsigned int row=0; row<_rows; row++ ) {
	      if( row > 0 )
		out << "\t";
	      out << _floatArray[row];
	    }
	  else
	    out << "\t(Not correct read!)";
	}
      }
      else {
	if( _typeOfArray == ParameterType::INT ) {
	  if( _intArray2D != NULL )
	    for( unsigned int row=0; row<_rows; row++ ) {
	      out << END_OF_LINE << prefix;
	      for( unsigned int col=0; col<_columns; col++ ) {
		if( col > 0 )
		  out << "\t";
		out << _intArray2D[row][col];
	      }
	    }
	  else
	    out << prefix << "\t(Not correct read!)" << END_OF_LINE;
	}
	else {
	  if( _floatArray2D != NULL )
	    for( unsigned int row=0; row<_rows; row++ ) {
	      out << END_OF_LINE << prefix;
	      for( unsigned int col=0; col<_columns; col++ ) {
		if( col > 0 )
		  out << "\t";
		out << _floatArray2D[row][col];
	      }
	    }
	  else
	    out << prefix << "\t(Not correct read!)" << END_OF_LINE;
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
    if( !_existsError && _filename.length()==0 ) {
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
    long   l;
    bool readDimension = false; // Is dimension correct read?
    bool readType      = false; // Is type correct read?
    bool readHead      = false; // Is head read?
    bool readFilename  = false; // Is keyword file read?

    initialize();
    readInfoType(parser);           // Reads InfoType from FileParser.
    while ( parser.good() ) { // Since FileParser readable:
      if( parser.readCommand(s) && s.length() > 0 ) {
        if( !readType && s.compareTo("typeOfArray")==0 ||    // Reads type.
	    s.compareTo("type")==0 ) {                          // Old style.
          parser.readIdentifier(s);                             // Reads type.
          _typeOfArray = ParameterType::getStringAsType(s);
          if( _typeOfArray!=ParameterType::INT &&
	      _typeOfArray!=ParameterType::FLOAT ) {
            parser.error("Unsupported array type, trying float ...", s);
            _typeOfArray = ParameterType::FLOAT;
          }
          readType = true;                                     // Type is read.
        }
        else if( s.compareTo("dimension")==0 ) {
          if( readDimension )
            parser.error((String) "Dimension already declared, " +
                         "overwriting old declaration ...", "dimension");
          parser.readLong(l, true);       // true: read positive long.
          _rows = (int) l;
	  if( isdigit(parser.peekChar()) ) {
	    parser.readLong(l, true);     // true: read positive long.
	    _columns = (int) l;
	    _dimension = 2;
	  }
	  else {
	    _dimension = 1;
	    _columns = 0;
	  }
          readDimension = true;             // Dimension is read.
        }
	else if( s.compareTo("head")==0 ) {
	  if( readHead )
	    parser.error((String) "Head already exists, " +
			 "overwriting old declaration ...", "file");
	  if( !readDimension )
	    parser.error((String) "Please define first dimension! " +
			 "(Lot of errors follows ...)", "file");
	  else if( _columns <= 0 )
	    parser.error((String) "No columns found (perhaps 1 dimensional " +
			 "array!?) (Lot of errors follows ...)", "file");
	  else{
	    _head = new String[_columns];
	    for( unsigned int i=0; i<_columns; i++ ) {
	      parser.readString(s);
	      _head[i] = s;
	    }
	    readHead = true;             // Head is read.
	  }
	}
        else if( s.compareTo("file")==0 ) {
          if( readFilename )
            parser.error((String) "Reference to file already exists, " +
                         "overwriting old declaration ...", "file");
          parser.readString(s);
          _filename = s;
	  _directory = parser.getDirectory();
          readFilename = true;             // Filename is read.
        }
        else {
          parser.putBack(s);
          break;
        }
      }
      else // ( !parser.readCommand(s) || s.length() == 0 )
	break;
    }
    if( !readDimension ) {
      parser.error("Missing definition of array dimension", "");
      _existsError = true;
    }
    if( _rows <= 0 || _dimension == 2 && _columns <= 0 ) {
      parser.error((String) "Wrong array dimension (" + _rows + ", " +
		   _columns + ")", "");
      _existsError = true;
    }
    if( !readType ) {
      parser.error("Unsupported array type, trying float ...", s);
      _typeOfArray = ParameterType::FLOAT;
    }

    if( _existsError ) {
      parser.error("Ignoring array data ...", "");
      _typeOfArray = ParameterType::FLOAT;
    }
  }
  /** Reads the list data from an opened FileParser. */
  void readValue(FileParser& parser) {
    String s;
    long   l;
    unsigned int row, col;
    double d;
    int c;

    if( _typeOfArray == ParameterType::INT )
      createIntArray();
    else
      createFloatArray();

    // Initializing array:
    if( _dimension == 1 )
      for( row=0; row<_rows; row++ )
	if( _typeOfArray == ParameterType::INT )
	  _intArray[row]=0;
	else
	  _floatArray[row]=0;
    else
      for( row=0; row<_rows; row++ )
	for( col=0; col<_columns; col++ )
	  if( _typeOfArray == ParameterType::INT )
	    _intArray2D[row][col]=0;
	  else
	    _floatArray2D[row][col]=0;
    
    // Parsing arra:
    if( _dimension == 1 )
      for( row=0; row<_rows; row++ ) {
	c = parser.peekChar();
	if( isalpha(c) || c=='_' ) {
	  parser.readIdentifier(s);
	  if( s.compareTo("end") == 0 ) {
	    parser.error((String) "Unexpected 'end'. Element (" + (row+1) +
			 ") expected. Dimension is (" + _rows + ")", s);
	    return;
	  }
	  else
	    parser.putBack(s);
	}
	if( _typeOfArray == ParameterType::INT ) {
	  parser.readLong(l);
	  _intArray[row]=l;
	}
	else {
	  parser.readDouble(d);
	  _floatArray[row]=d;
	}
      }
    else
      for( row=0; row<_rows; row++ ) {
	for( col=0; col<_columns; col++ ) {
	  c = parser.peekChar();
	  if( CharacterHandler::isIdentifierStart(c) ) {
	    parser.readIdentifier(s);
	    if( s.compareTo("end") == 0 ) {
	      parser.error((String) "Unexpected 'end'. Element (" + (row+1) +
			   ", " + (col+1) + ") expected. Dimension is (" +
			   _rows + ", " + _columns + ")", s);
	      return;
	    }
	    else
	      parser.putBack(s);
	  }
	  if( _typeOfArray == ParameterType::INT ) {
	    parser.readLong(l);
	    _intArray2D[row][col]=l;
	  }
	  else {
	    parser.readDouble(d);
	    _floatArray2D[row][col]=d;
	  }
	}
      }
  }

private:
  /** Initializes all variables for new array (e.g. called by constructor
   *  and setTypeOfElements...) */
  void initialize() {
    _rows         = 0;
    _columns      = 0;
    _dimension    = 1;
    deleteArrays();
    _filename     = "";
    _directory    = ".";
    _existsError  = false;

    _deleteArrayInDestructor = true; // Delete array if destructor called.
    _deleteHeadInDestructor = true;  // Delete head if destructor called.
  }

  /** Read array from filename. (Fast read without FileParser!) */
  String readFastFromFile() {
    // OK, array doesn't exist:
    if( _filename.length() == 0 ) // Does a reference to a file exist?
      return (String) "Array doesn't exist " +
	"and I don't know how to create it!";
    // OK, array doesn't exist but a reference to a file:
    String name = _directory + FILE_SEPARATOR + _filename;
    if( FilenameHandling::isAbsolute(_filename) )
      name = _filename;
    ifstream* input = new ifstream(name);
    if( input == NULL || !input->good() )
      return (String) "Error while opening file \"" + name +
	"\" as readable (" + strerror(errno) + ")!";
    double d;
    long   l;
    bool error = false;
    String message = "OK";
    unsigned int row = 0;
    unsigned int col = 0;
    if( _typeOfArray == ParameterType::INT )
      createIntArray();
    else
      createFloatArray();
    if( _dimension == 1 )
      for( ; row<_rows; row++ ) {
	d = 0;
	l = 0;
	if( !error ) {
	  *input >> d;
	  if( !input->good() ) {
	    error = true;
	    message = (String) "Missing element at position (" + (row+1) +
	      "). Filling following elements with '0'!";
	  }
	}
	if( _typeOfArray == ParameterType::INT )
	  _intArray[row]=l;
	else
	  _floatArray[row]=d;
      }
    else {
      for( ; row<_rows; row++ )
	for( col = 0; col<_columns; col++ ) {
	  d = 0;
	  l = 0;
	  if( !error ) {
	    *input >> d;
	    if( !input->good() ) {
	      error = true;
	      message = (String) "Missing element at position (" + (row+1) +
		", " + (col+1) + "). Filling following elements with '0'!";
	    }
	  }
	  if( _typeOfArray == ParameterType::INT )
	    _intArray2D[row][col]=l;
	  else
	    _floatArray2D[row][col]=d;
	}
    }
    if( !error && input->good() ) {
      *input >> d;
      if( !input->eof() )
	message = (String) "File doesn't end after last element (" + row +
	  ", " + col + ")!?";
    }
    delete input;
    return message;
  }
  /** Delete the existing arrays. */
  void deleteArrays() {
    _deleteArrayInDestructor = true; // Delete array if destructor called.
    if( _intArray != NULL ) {
      delete[] _intArray;
      _intArray = NULL;
    }
    if( _floatArray != NULL ) {
      delete[] _floatArray;
      _floatArray = NULL;
    }
    if( _intArray2D != NULL ) {
      for( unsigned i=0; i<_rows; i++ )
	delete[] _intArray2D[i];
      delete[] _intArray2D;
      _intArray2D = NULL;
    }
    if( _floatArray2D != NULL ) {
      for( unsigned i=0; i<_rows; i++ )
	delete[] _floatArray2D[i];
      delete[] _floatArray2D;
      _floatArray2D = NULL;
    }
  }
  /** Create a new integer array with the given size. */
  void createIntArray() {
    deleteArrays();
    if( _dimension == 1 ) {
      _intArray = new long[_rows];
    }
    else {
      _intArray2D = new long* [_rows];
      for( unsigned i=0; i<_rows; i++ )
	_intArray2D[i] = new long[_columns];
    }
  }
  /** Create a new float array with the given size. */
  void createFloatArray() {
    deleteArrays();
    if( _dimension == 1 ) {
      _floatArray = new double[_rows];
    }
    else {
      _floatArray2D = new double* [_rows];
      for( unsigned i=0; i<_rows; i++ )
	_floatArray2D[i] = new double[_columns];
    }
  }

  long   *_intArray;
  double *_floatArray;

  long   **_intArray2D;
  double **_floatArray2D;

  ParameterType* _typeOfArray;
  unsigned       _rows;
  unsigned       _columns;
  int            _dimension; // One or two dimensional.
  String         _filename;
  String*        _head;
  String         _directory;
  bool           _deleteArrayInDestructor;
  bool           _deleteHeadInDestructor;
  bool           _existsError;
};

#endif // _ArrayParameter_hh_
