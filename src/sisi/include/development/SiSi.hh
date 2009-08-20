/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: SiSi.hh,v $
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
//  $Revision: 1.4 $
//  $Date: 1998/05/13 15:59:09 $
//
//  Description
//   Include this file instead of including lot of SiSi files.
//
//
//  $Log: SiSi.hh,v $
//  Revision 1.4  1998/05/13 15:59:09  reinhard
//  #include <development/ResultReader.hh> added.
//
//  Revision 1.3  1998/04/07 11:23:40  kai
//  #include <math/Random.hh> added.
//
//  Revision 1.2  1998/04/07 08:43:39  kai
//  #include <development/MessageHandler.hh> added.
//
//  Revision 1.1  1998/03/21 19:20:35  kai
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _SiSi_hh_
#define _SiSi_hh_

#include <iostreams/SiSiParser.hh>       
#include <development/LogFile.hh>        
#include <development/MessageHandler.hh> 
// For message outputs.
#include <development/ResultReader.hh>   
// Let SiSi read the results
                                         // semiautomatically for us.
#include <development/ResultWriter.hh>   
// Let SiSi write the results
                                         // semiautomatically for us.
#include <math/Random.hh>                
// Useful random functions.
                                         // (Needed for initialization.)

#include <datastructures/ArrayParameter.hh>
#include <datastructures/BooleanParameter.hh>
#include <datastructures/CommentParameter.hh>
#include <datastructures/CharParameter.hh>
#include <datastructures/IntParameter.hh>
#include <datastructures/ListParameter.hh>
#include <datastructures/FloatParameter.hh>
#include <datastructures/ResultParameter.hh>
#include <datastructures/StringParameter.hh>
#include <datastructures/TableParameter.hh>

#endif 
// _SiSi_hh_
