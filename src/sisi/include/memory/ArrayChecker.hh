/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: ArrayChecker.hh,v $	
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
//  $Date: 1998/03/17 09:03:32 $
//
//  Description
//    This file contains the two template classes Array and Array2D.
//    You can debug with these classes very fast your programming code
//    using one and two dimensional classes for reading from and
//    writing to arrays out of bounds!
//    Usage:
//        #include "memory/ArrayChecker.hh"
//      Initialization of one dimensional arrays:
//        Array<float> myFloatArray(10, "myFloatArray", __FILE__, __LINE__);
//          - use this instead of 'float myFloatArray[10];'.
//          - replace float by any type or class you want!
//      Initialization of two dimensional arrays:
//        Array<int> myIntArray(10, 5, "myIntArray", __FILE__, __LINE__);
//          - use this instead of 'int myIntArray[10][5];'.
//          - replace int by any type or class you want!
//      And now?
//        NOTHING! You havn't to change any other code!
//        Every construct like e.g.
//          myFloatArray[5] = 42.42;
//          myIntArray[1][2] = 42;
//          cout << myFloatArray[5] << " " << myIntArray[5] << endl;
//          float test = myFloatArray[i] * myIntArray[i];
//        works!
//    Advantage:
//      Following code produce an error message to standard error output:
//        Array<char> test(5, "test", __FILE__, __LINE__);
//        test[-1] = 'a';  // Produces an error: -1 is out of bounds (0, 4)!
//        for( unsigned int i=0; i<=5; i++ )
//          test[i] = 'a'; // Produces an error: i=5 is out of bounds (0, 4)!
//    Disadvantage:
//      An ordinary array is faster :-(
//      (But note debug tip below.)
//    Debug tip:
//      Modify your programming code like this:
//        #ifdef __ARRAY_CHECK__
//          Array<float> myArray(10, "myArray", __FILE__, __LINE__);
//        #else
//          float myArray[10];  // (old line.)
//        #endif
//      Now compile your code with the definition __ARRAY_CHECK__ if you
//      want to debug the array bounds.
//
//
//  $Log: ArrayChecker.hh,v $
//  Revision 1.1  1998/03/17 09:03:32  kai
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _ArrayChecker_hh_
#define _ArrayChecker_hh_

#include "cppinc.h"

template <class X> class Array {
public:
  /** Constructor reserves an one dimensional array with the given length to
   *  the choosen object. */
  Array(unsigned int length,  const char* arrayName,
	const char* fileOfConstructorCall,
	int lineOfConstructorCall ) {
    _length                = length;
    _arrayName             = arrayName;
    _fileOfConstructorCall = fileOfConstructorCall;
    _lineOfConstructorCall = lineOfConstructorCall;
    _array = new X[_length];
  }
  /** Destructer gives all allocated memory and memory used by this class
   *  free. */
  ~Array() {
    delete [] _array;
  }
  X& operator[](long pos) {
    if( pos<0 || pos>=(long)_length ) {
      if( strcmp(__FILE__, _fileOfConstructorCall) )
	cerr << "*** ArrayChecker: Index " << pos << " for array '"
	     << _arrayName << "' is out of bounds (0, " << _length-1
	     << ")!!!\n"
	     << "***               This array was defined in file \""
	     << _fileOfConstructorCall << "\", line " << _lineOfConstructorCall
	     << ".\n";
      return _ignore;
    }
    return _array[pos];
  }
private:
  X*           _array;
  X            _ignore;
  unsigned int _length;
  const char*  _arrayName;
  const char*  _fileOfConstructorCall;
  int          _lineOfConstructorCall;
};

template <class X> class Array2D {
public:
  /** Constructor reserves an one dimensional array with the given length to
   *  the choosen object. */
  Array2D(unsigned int rows, unsigned int columns, const char* arrayName,
	  const char* fileOfConstructorCall,
	  int lineOfConstructorCall )
    : _ignore(1, "(internal)", __FILE__, __LINE__)
  {
    _rows                  = rows;
    _columns               = columns;
    _arrayName             = arrayName;
    _fileOfConstructorCall = fileOfConstructorCall;
    _lineOfConstructorCall = lineOfConstructorCall;
    _array = new Array<X>[_rows](_columns, _arrayName,
				 _fileOfConstructorCall,
				 _lineOfConstructorCall);
  }
  /** Destructer gives all allocated memory and memory used by this class
   *  free. */
  ~Array2D() {
    delete [] _array;
  }
  Array<X>& operator[](long pos) {
    if( pos<0 || pos>=(long)_rows ) {
      cerr << "*** ArrayChecker: Index " << pos << " for array '" << _arrayName
	   << "' is out of bounds (0, " << _rows-1 << ")!!!\n"
	   << "***               This array was defined in file \""
	   << _fileOfConstructorCall << "\", line " << _lineOfConstructorCall
	   << ".\n";
      return _ignore;
    }
    return _array[pos];
  }
private:
  Array<X>*    _array;
  Array<X>     _ignore;
  unsigned int _rows;
  unsigned int _columns;
  const char*  _arrayName;
  const char*  _fileOfConstructorCall;
  int          _lineOfConstructorCall;
};

#endif // _ArrayChecker_hh_
