/* GLUES messages declaration; this file is part of
   the Global Land Use and technological Evolution Simulator
   
   Copyright (C) 2007,2008
   Carsten Lemmen <carsten.lemmen@gkss.de>, Kai Wirtz <kai.wirtz@gkss.de>

   This program is free software; you can redistribute it and/or modify it
   under the terms of the GNU General Public License as published by the
   Free Software Foundation; either version 2, or (at your option) any later
   version.

   This program is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
   Public License for more details.

   You should have received a copy of the GNU General Public License along
   with this program; if not, write to the Free Software Foundation, Inc.,
   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
*/
/**
   @author Carsten Lemmen <carsten.lemmen@gkss.de>
   @author Kai W Wirtz <kai.wirtz@gkss.de
   @date   2008-01-08
   @file Messages.h
   @brief Welcome and goodby messages
*/

#ifndef glues_messages_h
#define glues_messages_h

#include "Symbols.h"

namespace glues {

  class Messages
    {
    public:
      static void Welcome() ;
      static void Goodbye() ;
      static int Success() ;
      static int Error() ;
    };
  
}

#endif /* glues_messages_h */
