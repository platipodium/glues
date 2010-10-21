/* GLUES io; this file is part of
   the Global Land Use and technological Evolution Simulator

   Copyright (C) 2009,2010
   Carsten Lemmen <carsten.lemmen@gkss.de>

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
   @date   2010-02-21
   @file   IO.h
*/

/* Caleb T.
Class is now a template.
read_ascii_row is still overloaded for a vector<vector<Type>>
and a vector<Type>

User can use empty or non-empty vector<vector<Type>> or vector<Type>
*/

#ifndef glues_io_h
#define glues_io_h

#include <iostream>
#include <sstream>
#include <vector>
#include <cassert>
#include <cctype>

#ifdef HAVE_NETCDF_H
#include "netcdfcpp.h"
#endif
//#include "RegionalPopulation.h"


namespace glues 
{
	template < class Type >
	class IO
	{
	public:
		//Ctor.
		IO(char commentCh = '#'){ commentChar = commentCh; }
		
		static void setComment( char commentCh = '#' ) { commentChar = commentCh; }
		static long unsigned int count_ascii_rows(std::istream& is);
		static long unsigned int count_ascii_columns(std::istream& is) ;

		static long unsigned int read_ascii_table(
			std::istream& is,
			std::vector< std::vector<Type> > &,
			long unsigned int row_offset,
			long unsigned int column_offset,
			long unsigned int nrow,
			long unsigned int ncol);


		static long unsigned int read_ascii_table(
			std::istream& is,
			std::vector<Type> &,
			long unsigned int row_offset,
			long unsigned int column_offset,
			long unsigned int nrow,
			long unsigned int ncol);


	static int define_resultfile(std::string,unsigned long int);
#ifdef HAVE_NETCDF_H
//	static int writeNetCDF(NcFile&,double t,RegionalPopulation* populations);
#endif
	private:
		static bool is_numeric(const std::string &);
		static bool is_comment_line(const std::string &);
		static char commentChar;
    };

	/**********************/
	/* Begin definitions. */
	/**********************/



	/******************************************
	read_ascii_table( vector<vector<Type>> )  */

	template< class Type>
	long unsigned int 
		glues::IO<Type>::read_ascii_table(std::istream& is,
		std::vector< std::vector<Type> > &table_double,
		long unsigned int row_offset = 0, long unsigned int column_offset = 0,
		long unsigned int max_nrow = 0, long unsigned int max_ncol = 0)

	{
	  Type dvalue;
	  std::string line, word;
	  long unsigned int icol = 0, irow = 0;

	  //Check for IO errors.
	  if( is.rdstate() & std::ios::badbit )
	  {
		  std::cerr << "ERROR: glues::IO::count_ascii_columns. "
			  << "Fatal IO error, badbit." << std::endl;
		  return 0;
	  }
	  else
	  {
		  is.clear();
	  }
  
	  is.seekg(0);

	  //assert( max_nrow - row_offset > 0 );
	  //assert( max_ncol - column_offset > 0 );
  
	  //Set size of vector.
	  table_double.clear();

	  while(is.good() && getline(is, line))
	  {
		  if( is_comment_line(line) )
			  continue;
		  ++irow;
		  icol = 0;//When each line is read, this is reset.

		  //Skip to row to start with the first time.
		  if( row_offset > 0 && row_offset >= irow )
		  {
			  continue;
		  }
		  //Exit loop if exceeded max_nrow.
		  else if( irow > max_nrow )
		  {
			  break;
		  }
		  //Else add room for this row.
		  else
		  {
			  table_double.push_back( std::vector<Type>() );
		  }

		  //Extract "words" in row.
		  std::istringstream iss(line);

		  //Skip to column/word to start with.
		  //leave get pointer before the entry needed.
		  while( iss.good() && icol < column_offset )//(icol-1)
		  {
			  if(iss >> word)
				  icol++;
		  }
	  
		  //Extract words until icol > max_ncol.
		  //Push to table_double.
		  while( iss.good() && icol < max_ncol )
		  {
			  if(iss >> word)
			  {
				  std::stringstream tss( word );
				  tss >> dvalue;
				  icol++;
				  table_double.at( irow-row_offset-1 ).push_back( dvalue );
			  }
		  }

		  //attempted to extract more words
		  //than are on one line, error.
		  if( iss.bad() )
		  {
			  std::cerr << "ERROR: in read_ascii_table. Attempted to extract"
				  << " more words than exist per line.\n";
			  return 0;
		  }
	  }

	  return irow - row_offset - 1;
	}

	/**********************************
	 read_ascii_table( vector<Type> ) */

	template <class Type>
	long unsigned int
	glues::IO<Type>::read_ascii_table(std::istream& is, std::vector<Type> & fv,
		long unsigned int row_offset = 0, long unsigned int column_offset = 0,
		long unsigned int max_nrow = 0, long unsigned int max_ncol = 0)

	{
	  Type fvalue = 0.0f;
	  std::string line, word;
	  long unsigned int icol = 0, irow = 0;

	  //Check for IO errors.
	  if( is.rdstate() & std::ios::badbit )
	  {
		  std::cerr << "ERROR: glues::IO::count_ascii_columns. "
			  << "Fatal IO error, badbit." << std::endl;
		  return 0;
	  }
	  else
	  {
		  is.clear();
	  }
	  is.seekg(0);

	  // std::cerr  << line << std::endl;
	  while (is.good() && std::getline(is, line))
	  {
		  icol = 0;
		  if( !is_comment_line(line) )
		  {
			  std::istringstream iss(line);
			  while (iss.good() && (iss >> word))
			  {
				  // Skip multi-blank and tab words, break on non-numeric
				  if (word.length() < 1)
					  continue;
				  if (isspace(word.at(0)))
					  continue;
				  if (!is_numeric(word))
					  break;

				  // Skip this line if more than max_col
				  if (max_ncol > 0 && icol >= column_offset + max_ncol)
					  break;
			  
				  icol++;

				  if (icol == column_offset + 1)
					  irow++;

				  // Skip this column if less than col-offset
				  if (icol <= column_offset)
					  continue;
			  
				  // Skip this line if less than row-offset
				  if (irow <= row_offset)
				  {
					  //icol--;
					  break;
				  }

				  //C++ portable string to int/float:
				  std::istringstream tss(word);
				  tss >> fvalue;

				  fv.push_back( fvalue );
			  }
		  }

		  if (icol > column_offset && max_nrow > 0 && irow >= row_offset + max_nrow)
			break;
		}

	  return irow - row_offset - 1;
	}

	/*******************
	count_ascii_rows() */

	template<class Type>
	unsigned long int
	glues::IO<Type>::count_ascii_rows(std::istream& is)
	{

	  std::string line, word;
	  unsigned int n = 0;

	  //Check for IO errors.
	  if( is.rdstate() & std::ios::badbit )
	  {
		  std::cerr << "ERROR: glues::IO::count_ascii_rows. "
			  << "Fatal IO error, badbit." << std::endl;
		  return 0;
	  }
	  //else if(is.rdstate() & std::ios::failbit )
	  //{
		 // std::cerr << "ERROR: glues::IO::count_ascii_rows. "
			//  << "Non-fatal IO error, failbit." << std::endl;
		 // is.clear();
	  //}
	  else
	  {
		  is.clear();
	  }

	  is.seekg(0);

	  //Read line, ensure not comment line.
	  while(is.good() && std::getline(is, line))
	  {
		  if( !is_comment_line(line) )
		  {
			  n++;
		  }
		  if( n < 1 )//error checking
			  continue;
	  }
	  return n;
	}

	/**********************
	count_ascii_columns() */

	/**
	@param is: input stream to read from
	@return: number of columns in first numeric line read
	*/

	template <class Type>
	unsigned long int
	glues::IO<Type>::count_ascii_columns(std::istream& is)
	{

	  std::string line, word;
	  unsigned int n = 0;
  
	  //Check for IO errors.
	  if( is.rdstate() & std::ios::badbit )
	  {
		  std::cerr << "ERROR: glues::IO::count_ascii_columns. "
			  << "Fatal IO error, badbit." << std::endl;
		  return 0;
	  }
	  else
	  {
		  is.clear();
	  }

	  while (is.good() && std::getline(is, line))
	  {
		  if( !is_comment_line(line) )
		  {
			  std::istringstream iss(line);
			  while (iss.good() && (iss >> word))//<-- no blank words.
			  {
				  // Skip multi-blank and tab words, break on non-numeric
				  if (word.length() < 1)
					  continue;
				  if (isspace(word.at(0)))
					  continue;
				  if (!is_numeric(word))
					  break;
				  n++;
			  }
			  return n;
		  }
	  }

	  return 0;
	}

	/**************
	 is_numeric() */

	template <class Type>
	bool
	glues::IO<Type>::is_numeric(const std::string &word)
	{
	  if (word.length() < 1)
		return false;

	  char ch = word.at(0);
	  return (isdigit(ch) || ch == '+' || ch == '.' || ch == '-');
	}


	/******************
	 is_comment_line()*/

	template<class Type>
	bool 
	glues::IO<Type>::is_comment_line(const std::string &line)
	{
		if( line.size() == 0 )
			return true;
	
		size_t pos;
		//Get index of first non-whitespace char.
		for( pos = 0; pos < line.size() && isspace(line.at(pos)); ++pos ) {}
	
	#ifdef GLUES_IO_TRIM
		std::string temp( line.begin()+pos, line.end() );
		line = temp;//copy data.
		return ( (isalpha(line.at(0)) 
			|| line.at(0) == commentChar) );
	#else
		return (isalpha(line.at(pos)) || line.at(pos) == commentChar);
	#endif
	}


	/*********************
	 define_resultfile() */

	template <class Type>
	int
	glues::IO<Type>::define_resultfile(std::string filename, unsigned long int nreg = 685)
	{

	  // NcFile ncfile(filename.c_str(),NcFile::Write);

	#ifdef HAVE_NETCDF_H
	/*NcFile ncfile("test.nc",NcFile::Replace);

	if (!ncfile.is_valid()) return 1;

	NcDim* timedim=ncfile.add_dim("time");
	NcDim* regiondim=ncfile.add_dim("region",nreg);

	NcVar* timevar=ncfile.add_var("time",ncDouble, timedim);

	ncfile.close();
	*/
	std::cerr << " Success in creating netcdf file" << std::endl;
	#endif

	return 0;

	}




	//This is some kind of odd rule due to
	//C++'s archaic compilation behavior.
	template <class Type>
	char glues::IO<Type>::commentChar = '#';
}//End namespace glues
#endif
