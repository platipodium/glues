#include "IO.h"
#include <cstdlib>

#ifdef HAVE_NETCDF_H
#include "netcdfcpp.h"
#endif

/**
 @param is: input stream to read from
 @return: number of lines read
 */

unsigned long int
glues::IO::count_ascii_rows(std::istream& is)
{

  std::string line, word;
  unsigned int n = 0;

  if (is.bad())
    {
      std::cerr
          << "ERROR glues::IO::count_ascii_rows. Input stream not ready\n";
    }

  is.seekg(0);

  while (is.good() && getline(is, line))
    {

      std::istringstream iss(line);

      while (iss.good() && getline(iss, word, ' '))
        {

          // Skip multi-blank and tab words, break on non-numeric
          if (word.length() < 1)
            continue;
          if (is_whitespace(word))
            continue;
          if (!is_numeric(word))
            break;

          n++;
          break;
        }
    }

  return n;
}

/**
 @param is: input stream to read from
 @return: number of columns in first numeric line read
 */
unsigned long int
glues::IO::count_ascii_columns(std::istream& is)
{

  std::string line, word;
  unsigned int n = 0;

  if (is.bad())
    {
      std::cerr
          << "ERROR glues::IO::count_ascii_columns. Input stream not ready\n";
    }

  is.seekg(0);

  while (is.good() && getline(is, line))
    {

      std::istringstream iss(line);

      while (iss.good() && getline(iss, word, ' '))
        {

          // Skip multi-blank and tab words, break on non-numeric
          if (word.length() < 1)
            continue;
          if (is_whitespace(word))
            continue;
          if (!is_numeric(word))
            break;

          n++;
        }
      if (n < 1)
        continue;
      return n;
    }

  return 0;
}

/**
 @param is: input stream to read from
 @param table_double: pointer to double matrix
 @param row_offset
 @param column_offset
 @param max_nrow
 @param max_ncol
 @return: number of lines read
 */

long unsigned int
glues::IO::read_ascii_table(std::istream& is, double** table_double,
    long unsigned int row_offset = 0, long unsigned int column_offset = 0,
    long unsigned int max_nrow = 0, long unsigned int max_ncol = 0)

{
  double dvalue;
  std::string line, word;
  long unsigned int icol = 0, irow = 0;

  if (is.bad())
    {
      std::cerr << "ERROR in read_ascii_table. Input stream not ready\n";
      return 0;
    }

  if (table_double == NULL)
    {
      std::cerr << "ERROR in read_ascii_table.  Matrix not allocated\n";
      return 0;
    }

  // std::cerr  << line << std::endl;
  while (is.good() && getline(is, line))
    {

      icol = 0;
      std::istringstream iss(line);

      while (iss.good() && getline(iss, word, ' '))
        {

          // Skip multi-blank and tab words, break on non-numeric
          if (word.length() < 1)
            continue;
          if (is_whitespace(word))
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

          dvalue = strtod(word.c_str(), NULL);

          if (table_double[irow - row_offset - 1] == 0)
            {
              std::cerr << "ERROR in read_ascii_table.  Matrix not allocated\n";
              return 0;
            }

          table_double[irow - row_offset - 1][icol - column_offset - 1]
              = dvalue;

        }
      //	std::cerr << icol << "/" << column_offset << " " << irow << "/" << row_offset << std::endl;

      if (icol > column_offset && max_nrow > 0 && irow >= row_offset + max_nrow)
        break;
    }

  return irow - row_offset;
}

bool
glues::IO::is_whitespace(std::string word)
{

  if (word.length() < 1 ) return false;

  switch (word[0])
  {
      case '\t':
	  return true;
      case ' ':
	  return true;
      case '\r':
	  return true;
      case '\n':
	  return true;
  }

  return false;
}

bool
glues::IO::is_numeric(std::string word)
{

  if (word.length() < 1)
    return false;

  char ch = word[0];

  if (ch != '-'
  //&& ch != 'N' && ch != 'n' && ch != 'i' && ch !='I'
      && (word[0] < '0' || word[0] > '9'))
    return false;

  return true;
}

int
glues::IO::define_resultfile(std::string filename, unsigned long int nreg = 685)
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
