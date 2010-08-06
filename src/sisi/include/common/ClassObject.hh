/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile$	
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
//  $Revision$
//  $Date$
//
//  Description
//    NOT IN USE AND NOT FINISHED!!! PLEASE IGNORE!!!
//    This Object knows his name and could compare it:
//      class MyClass: public ClassObject {
//      public:
//        MyClass(...) { className = "MyClass"; }
//        bool isInstanceOf(const char* name) {
//          if ( strcmp(className, name) == 0 )
//            return true;
//          return ClassObject::isInstanceOf(name); // Call isInstanceOf
//          }                                       // of parent classes.
//        ...
//      };
//
//      ClassObject* test = ...
//      if( test->isFromClass("MyClass") )
//        ((MyClass*) test)->amethod(..);
//
//    So every child class has to declare className in his constructor and
//    the method isInstanceOf:
//      class ASecondClass: public MyClass, public ParentClass {
//      public:
//        ASecondClass(...) { className = "ASecondClass"; }
//        bool isInstanceOf(const char* name) {
//          if ( strcmp(className, name) == 0 )
//            return true;
//          if( MyClass::isInstanceOf(name) )   // Call isInstanceOf
//            return true;                      // of parent classes.
//          return ParentClass::isInstanceOf(name);
//        }
//        ...
//      };
//
//      ClassObject* test = ...
//      if( test->isInstanceOf("ParentsParentClass") )
//        ((ParentsParentClass*) test)->amethod(..);
//
//
//  $Log$
/////////////////////////////////////////////////////////////////////////////

#ifndef _ClassObject_hh_
#define _ClassObject_hh_

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include "cppinc.h"

class ClassObject
{
public:
  /** Default constructor. */
  ClassObject()
    : className("ClassObject")
  { }
  
  virtual ~ClassObject() { }
  /** Test if the class is equal the given name. */
  virtual bool isFromClass(const char* name) {
    return (strcmp(className, name) == 0);
  }
  /** Test if the class is instance of the given class(name). */
  bool isInstanceOf(const char* name) {
    className << " == " << name << endl;
    return (strcmp(ClassObject::className, name) == 0);
  }
  /** Returns the className. */
  virtual const char* getClassName() {
    return className;
  }
protected:
  /** Compares TwoWayListElement's ID with the given String. */
  virtual bool compareTo(const char*) { return false; }
private:
  /** To store the name of the class for comparing. */
  static const char* className;
};

#endif // _ClassObject_hh_
