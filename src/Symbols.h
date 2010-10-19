/* GLUES  macro declaration. This file is part of
   the Global Land Use and technological Evolution Simulator
   
   Copyright (C) 2007,2008
   Carsten Lemmen <carsten.lemmen@hzg.de>
   
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

   @author Carsten Lemmen <carsten.lemmen@hzg.de>
   @date 2008-01-08
   @file Symbols.h
   @brief Global macro declarations
*/


#ifndef glues_symbols_h
#define	glues_symbols_h

/** See whether we have macros set in the file config.h */
#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

/** See whether we include localisation/internationalisation with 
    the intl library and globally declare the _() macro*/
#ifdef HAVE_LIBINTL_H
#include <libintl.h>
#include <locale.h>
#define _(String) gettext (String)
#else
#define _(String) (String)
#endif

/** Make the iostream basic functionalities world known */
#include <iostream>
using std::cout;
using std::cerr;
using std::endl;
using std::clog;


static const double EPS=(double)1E-4;
static const double RADIUS=(double)6378.0;
static const double PI=(double)3.1415926535;


/** Compatibility with sun where min/max are missing in libmath */
#ifndef HAVE_MIN
inline static double min(double a,double b) {return (a<b?a:b); };
#endif
#ifndef HAVE_MAX
inline static double max(double a,double b) {return (a<b?b:a); };
#endif


namespace glues {	
/** Define epsilon, pi and earth radius */
#ifndef EPS		
static const double EPS=(double)1E-4;
#endif

#ifndef PI
static const double PI=(double)3.1415926535;
#endif

#ifndef RADIUS
static const double RADIUS=(double)6378.0;
#endif

}
#endif	/* glues_symbols_h */

