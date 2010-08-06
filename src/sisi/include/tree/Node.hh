/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: Node.hh,v $	
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
//  $Date: 1998/07/17 17:47:12 $
//
//  Description
//    Contains a node for the tree.
//
//  $Log: Node.hh,v $
//  Revision 1.2  1998/07/17 17:47:12  reinhard
//  Methods supressDeletingChildsInDestructor() and
//  supressDeletingSistersInDestructor() added.
//
//  Revision 1.1  1998/07/09 23:24:37  reinhard
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _Node_hh_
#define _Node_hh_

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif
#include "cppinc.h"

class Tree;

class Node
{
public:
  /** Default constructor. */
  Node()
    : className("Node"), firstChild(NULL), lastChild(NULL), nextSister(NULL),
      deleteChildsInDestructor(true), deleteSistersInDestructor(true)
  { }
  
  virtual ~Node() {
    if( deleteChildsInDestructor )
      delete firstChild;
    delete nextSister;
  }

  /** Supress deleting childs in destructor. */
  void supressDeletingChildsInDestructor() {
    deleteChildsInDestructor = false;
  }

  /** Supress deleting sisters in destructor. */
  void supressDeletingSistersInDestructor() {
    deleteSistersInDestructor = false;
  }

  void prependChild(Node* newChild) {
    newChild->nextSister = firstChild;
    if( lastChild == NULL ) // No child exists.
      lastChild = newChild;
    firstChild = newChild;
  }

  void appendChild(Node* newChild) {
    if( lastChild != NULL )
      lastChild->nextSister = newChild;
    else                     // No child exists.
      firstChild = newChild;
    lastChild = newChild;
    lastChild->nextSister = NULL;
  }

  Node* getFirstChild() const { return firstChild; }
  Node* getNextSister() const { return nextSister; }

  /** Tests if className is equal to the given name. */
  virtual bool isFromClass(const char* name) {
    return (strcmp(className, name) == 0);
  }
  /** Returns the className. */
  virtual const char* getClassName() {
    return className;
  }

protected:
  /** Compares Node's ID with the given String. */
  virtual bool compareTo(const char*) { return false; }
  /** Compares the class name of the Node with the given
   *  String. */
  const char* className;
private:
  Node* firstChild;
  Node* lastChild;   // For appending notes.
  Node* nextSister;

  bool  deleteChildsInDestructor;
  bool  deleteSistersInDestructor;

  friend class Tree; // Modified by Jan: keyword class added
};

#endif // _Node_hh_
