/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: TwoWayList.hh,v $	
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
//  $Date: 1998/02/13 17:20:54 $
//
//  Description
//    Contains a two way list template.
//
//  $Log: TwoWayList.hh,v $
//  Revision 1.1  1998/02/13 17:20:54  reinhard
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _TwoWayList_hh_
#define _TwoWayList_hh_

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include "twowaylist/TwoWayListElement.hh"

class TwoWayList
{
public:
  ///////////////////////////////////////////////////////////////////////////
  //
  // Constructors:
  //
  /** Default constructor. */
  TwoWayList()
    : _first(0), _last(0), _actual(0)
  { }
  
  ///////////////////////////////////////////////////////////////////////////
  //
  // public access:
  //
  /** Appends TwoWayListElement to TwoWayList. */
  void appendElement(TwoWayListElement* el) {
    if( _last != 0 ) { // _last != 0
      el->predecessor  = _last;
      _last->successor = el;
    }
    else {
      _first  = el;   // anfang und ende
      el->predecessor = 0;
    }
    _last           = el;
    _last->successor = 0;
    _actual         = el;  // actual = appended element.
    _actualNumber   = -1;  // Dont't know, which number is it!
  }

  /** Inserts TwoWayListElement to TwoWayList before given position index. */
  void insertElement(TwoWayListElement *element, int index) {
    TwoWayListElement *pos = getElement(index);
    if( pos == 0 ) {         // Perhaps index out of range?
      appendElement(element);   // Then append the element.
      return;
    }
    element->predecessor  = pos->predecessor;
    pos->predecessor = element;
    element->successor  = pos;
    if( element->predecessor != 0 )
      element->predecessor->successor = element;
    else
      _first = element;
    _actual  = element;        // actual = inserted element.
    _actualNumber = -1;        // Dont't know, which number is it!
  }

  /** Removes the first TwoWayListElement from the TwoWayList. Returns
   *  the removed element or 0, if the list is empty. */
  TwoWayListElement* removeFirstElement() {
    TwoWayListElement* el = _first;
    if( el != 0 ) {            // List isn't empty.
      if( _last == _first ) {     // List contains only one element.
	_actual = 0;           // List is now empty ...
	_last   = 0;
	_first  = 0;
      }
      else {                      // There are more than one elements.
	if( _actual == _first )   // Perhaps update _actual.
	  _actual = _actual->successor;
	_first = _first->successor;
	_first->predecessor = 0;
      }
    }
    _actualNumber = -1;   // Dont't know, which number it is!
    return el;
  }

  /** Removes the last TwoWayListElement from the TwoWayList. Returns
   *  the removed element or 0, if the list is empty. */
  TwoWayListElement* removeLastElement() {
    TwoWayListElement* el = _last;
    if( el != 0 ) {            // List isn't empty.
      if( _last == _first ) {     // List contains only one element.
	_actual = 0;           // List is now empty ...
	_last   = 0;
	_first  = 0;
      }
      else {                      // There are more than one elements.
	if( _actual == _last )    // Perhaps update _actual.
	  _actual = _actual->predecessor;
	_last = _last->predecessor;
	_last->successor = 0;
      }
    }
    _actualNumber = -1;   // Dont't know, which number it is!
    return el;
  }

  /** Removes TwoWayListElement with the given identification from the
   *  TwoWayList. Returns the removed element or 0, if an element
   *  with the given id doesn't exist. */
  TwoWayListElement* removeElement(const char* identification) {
    TwoWayListElement* el = getElement(identification);
    if( el == 0 )
      return 0;
    if( el == _first )
      return removeFirstElement();
    if( el == _last )
      return removeLastElement();
    el->predecessor->successor = el->successor;
    el->successor->predecessor = el->predecessor;
    _actualNumber = -1;   // Dont't know, which number it is!
    return el;
  }

  /** Removes TwoWayListElement with at the given index position from
   *  TwoWayList. Returns the removed element or 0, if an element
   *  with at the given position doesn't exist. */
  TwoWayListElement* removeElement(int position) {
    TwoWayListElement* el = getElement(position);
    if( el == 0 )
      return 0;
    if( el == _first )
      return removeFirstElement();
    if( el == _last )
      return removeLastElement();
    el->predecessor->successor = el->successor;
    el->successor->predecessor = el->predecessor;
    _actualNumber = -1;   // Dont't know, which number it is!
    return el;
  }

  /** Gets the element with the given identification, otherwise 0. */
  TwoWayListElement* getElement(const char* identification) {
    TwoWayListElement* el = _first;
    while( el != 0 ) {
      if( el->compareTo(identification) )
	break;
      el = el->successor;
    }
    return el;
  }
  /** Gets the n-th element (0,1,...). If number is out of range, then
   *  0 will be returned. */
  TwoWayListElement* getElement(int number) {
    if( number < 0 )
      return 0;
    TwoWayListElement* el = resetIterator();
    for( int i=0; i<number && el!=0; i++ )
      el = nextElement();
    return el;
  }
  /** Sets iterator to first element and returns first element. */
  TwoWayListElement* resetIterator() {
    _actualNumber  = 0;
    return _actual = _first;
  }

  /** Has TwoWayList more TwoWayListElements? */
  bool hasMoreElements() {
    if( _actual == 0 )
      return false;
    return _actual->successor!=0 ? true: false;
  }

  /** Returns the actual TwoWayListElement. */
  TwoWayListElement* actualElement() { return _actual; }

  /** Returns the next TwoWayListElement. */
  TwoWayListElement* nextElement() {
    if( _actual != 0 ) {
      if( _actualNumber > -1 )
	_actualNumber++;
      _actual = _actual->successor;
    }
    else
      _actualNumber = -1;
    return _actual;
  }

  ///////////////////////////////////////////////////////////////////////////
  //
  // private access:
  //
private:
  TwoWayListElement *_first, *_last, *_actual;
  int         _actualNumber;
};

#endif // _TwoWayList_hh_
