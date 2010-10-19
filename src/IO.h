/* GLUES io; this file is part of
   the Global Land Use and technological Evolution Simulator

   Copyright (C) 2009,2010
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
   @date   2010-02-21
   @file   IO.h
*/

#ifndef glues_io_h
#define glues_io_h

#include <iostream>
#include <sstream>

#ifdef HAVE_NETCDF_H
#include "netcdfcpp.h"
#endif
//#include "RegionalPopulation.h"


namespace glues {

    class IO {

    public:
	static long unsigned int count_ascii_rows(std::istream& is);
	static long unsigned int count_ascii_columns(std::istream& is) ;

	static long unsigned int read_ascii_table(std::istream& is,int**);
	static long unsigned int read_ascii_table(
	    std::istream& is,double**,
	    long unsigned int row_offset,
	    long unsigned int column_offset,
	    long unsigned int nrow,
	    long unsigned int ncol);

	static long unsigned int read_ascii_table(
	    std::istream& is,float**,
	    long unsigned int row_offset,
	    long unsigned int column_offset,
	    long unsigned int nrow,
	    long unsigned int ncol);

	static long unsigned int read_ascii_table(
	    std::istream& is,float*,
	    long unsigned int row_offset,
	    long unsigned int column_offset,
	    long unsigned int nrow,
	    long unsigned int ncol);
	static long unsigned int read_ascii_table(
	    std::istream& is,int**,
	    long unsigned int row_offset,
	    long unsigned int column_offset,
	    long unsigned int nrow,
	    long unsigned int ncol);


	static int define_resultfile(std::string,unsigned long int);
#ifdef HAVE_NETCDF_H
//	static int writeNetCDF(NcFile&,double t,RegionalPopulation* populations);
#endif
	private:
	static bool is_numeric(std::string);
	static bool is_whitespace(std::string);
    };
}
#endif
