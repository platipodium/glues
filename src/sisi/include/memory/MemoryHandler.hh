/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: MemoryHandler.hh,v $	
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
//  $Revision: 1.2 $
//  $Date: 1998/08/18 11:52:06 $
//
//  Description
//    MemoryHandler minimize allocating memory by new. This cause a higher
//    performance if you call many deletes and news mixed.
//    MemoryHandler has no effect, if you call many news without deletes or
//    deletes only at the end of your program.
//    Usage:
//        #include "memory/MemoryHandler.hh"
//      Initialization:
//        MemoryHandler<int> intMemoryHandler(5, "int", __FILE__, __LINE__);
//          - replace int by any type or class you want!
//          - replace 5 by the number of elements you except to store
//            in this MemoryHandler.
//            (Compile your source code with the definition
//             __MEMORYHANDLER_STATISTICS__.
//             Test an high value and call 'intMemoryHandler.print(cout);'
//             at the end of your program. Take the value greater than the
//             shown value called 'Maximum stored pointers'.)
//          - If the given value (here 5) is to low, it doesn't
//            matter, but it cause a lower performance. In that case,
//            MemoryHandler will show a warning to the standard error
//            output.
//          - NOTE: MemoryHandler doesn't allocate the memory by
//                  initialization. It gets memory from system only if
//                  needed! So an high value doesn't cost much memory!
//                  MemoryHandler only reserve memory for pointers to
//                  memory (here 5 pointers)! Pointer doesn't need
//                  much memory!
//      Allocating memory:
//        int* test;
//        test = intMemoryHandler.newElement();// Instead of test = new int;
//      Deleting memory:
//        intMemoryHandler.deleteElement(test);// Instead of delete test;
//        test = NULL;                         // For avoiding multiple access!
//      Attention:
//        If you call deleteElement twice with the same variable, then
//        MemoryHandler give you twice the same memory by calling later
//        callings of newElement!
//        (Remember: Calling system's delete twice causes a
//        segmentation fault!)
//        Additional a segmentation fault or bus error could occur after
//        calling destructor of MemoryHandler.
//        example1:
//          int* test = intMemoryHandler.newElement();
//          intMemoryHandler.deleteElement(test);      // OK.
//          intMemoryHandler.deleteElement(test);      // ERROR!!!!!!!.
//        example2:
//          int* test = intMemoryHandler.newElement();
//          intMemoryHandler.deleteElement(test);      // OK.
//          test = intMemoryHandler.newElement();
//          intMemoryHandler.deleteElement(test);      // OK.
//        example3:
//          int* test = intMemoryHandler.newElement();
//          intMemoryHandler.deleteElement(test);      // OK.
//          test = NULL;                               // Great!
//          intMemoryHandler.deleteElement(test);      // Has no effect.
//      ! You should test your program of calling deleteElement twice, if
//      ! you compile your source code with the definition
//      ! __MEMORYHANDLER_CHECK_DELETES__. But notice: This cause
//      ! lower a lower performance (remove this definition after
//      ! testing!).
//      ! Do this everytime you change your programming code using
//      ! this MemoryHandler!!!!
//
//
//  $Log: MemoryHandler.hh,v $
//  Revision 1.2  1998/08/18 11:52:06  reinhard
//  It was stupid to delete const char* _className in destructor...
//
//  Revision 1.1  1998/03/12 11:13:26  kai
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _MemoryHandler_hh_
#define _MemoryHandler_hh_

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif
#include "cppinc.h"

//#define __MEMORYHANDLER_STATISTICS__
//#define __MEMORYHANDLER_CHECK_DELETES__
//#define __MEMORYHANDLER_DEVELOPER_DEBUG__

template <class X> class MemoryHandler {
public:
  // Fuck this construction, but static data member templates not impemented.
  /** Constructor reserves an array with the given number of pointers to
   *  the choosen object. */
  MemoryHandler(unsigned int numberOfReservedElements, const char* className,
		const char* fileOfConstructorCall,
		int lineOfConstructorCall ) {
    _numberOfReservedElements = numberOfReservedElements;
    _className             = className;
    _fileOfConstructorCall = fileOfConstructorCall;
    _lineOfConstructorCall = lineOfConstructorCall;
    _memoryPointer = new void*[_numberOfReservedElements];
    // Initialize array:
    for(  unsigned int i=0; i<_numberOfReservedElements; i++ )
      _memoryPointer[i] = NULL;
    _index = 0;
    _error = false;
#ifdef __MEMORYHANDLER_STATISTICS__
    _numberOfCalledSystemNews       = 0;
    _maximumElementsInMemoryPointer = 0;
#endif
  }
  
  /** Destructer gives all allocated memory and memory used by this class
   *  free. */
  ~MemoryHandler() {
    for( unsigned int i=0; i<_numberOfReservedElements; i++ )
      if( _memoryPointer[i] )
	delete (X*) _memoryPointer[i];
    delete [] _memoryPointer;
  }
  
  /** Allocates new memory. If no memory is stored in the list, new will be
   *  called otherwise a previous deleted memory will be returned. */
  X* newElement() {
    X* result;
    if( _index > 0 ) {
      result = (X*) _memoryPointer[--_index];
      _memoryPointer[_index] = NULL;
    }
    else {
      result = new X;
#ifdef __MEMORYHANDLER_STATISTICS__
      _numberOfCalledSystemNews++;
#endif
    }
    return result;
  }
    
  /**  */
  void deleteElement(void* element) {
    if( !element )
      return; // Do nothing.
#ifdef __MEMORYHANDLER_CHECK_DELETES__
    // Checks the array for multiple delete!!!!
    for( unsigned int i=0; i<_index; i++ )
      if( _memoryPointer[i] == element ) {
	cerr << "*** MemoryHandler: Error! Multiple delete (memoryPointer["
	     << i << "]==" << _memoryPointer[i] << ")! ***\n";
	return; // Do nothing.
      }
#endif
    if( _index < _numberOfReservedElements ) {
      _memoryPointer[_index++] = (void*) element;
      element = NULL;
#ifdef __MEMORYHANDLER_STATISTICS__
      if( _index > _maximumElementsInMemoryPointer )
	_maximumElementsInMemoryPointer = _index;
#endif
    }
    else {
      if( !_error ) {
	cerr << "*** MemoryHandler: Warning! Please increase the number of "
	     << "reserved elements (" << _numberOfReservedElements << "):\n";
	print(cerr);
	_error = true;
      }
    }
  }
  void print(ostream& out) {
    out << "*** MemoryHandler: Type of stored elements: " << _className
	<< "\n                   Constructor call in    : file "
	<< _fileOfConstructorCall << ", line "
	<< _lineOfConstructorCall
	<< "\n                   Reserved Elements      : "
	<< _numberOfReservedElements
	<< "\n                   Number of free pointers: " << _index;
#ifdef __MEMORYHANDLER_STATISTICS__
    out << "\n                   Called system news     : "
	<< _numberOfCalledSystemNews
	<< "\n                   Maximum stored pointers: "
	<< _maximumElementsInMemoryPointer;
#endif
#ifdef __MEMORYHANDLER_DEVELOPER_DEBUG__
    for( unsigned int i=0; i<_numberOfReservedElements; i++ )
      out << "\n                   " << i << ": "
	  << (void*) _memoryPointer[i];
#endif
    out << endl;
  }
private:
  void*        *_memoryPointer;
  unsigned int _numberOfReservedElements;
  unsigned int _index;
  const char*  _className;
  const char*  _fileOfConstructorCall;
  int          _lineOfConstructorCall;
  bool         _error;
#ifdef __MEMORYHANDLER_STATISTICS__
  unsigned int _numberOfCalledSystemNews;
  unsigned int _maximumElementsInMemoryPointer;
#endif
};

#endif // _MemoryHandler_hh_
