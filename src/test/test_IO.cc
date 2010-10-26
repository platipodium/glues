//#include "../IO.h"
#include "IO.h"
#include <iostream>
#include <fstream>
#include <vector>
#include <cstdio>
#include <cstdlib>
#include <cassert>
#include <cstddef>

using glues::IO;
using namespace std;

template <class T>
void PrintMatrix( std::vector< std::vector<T> > &data );

template <class T>
void PrintVector( std::vector<T> &data );


#define DEBUG

int main (int argc, char* argv[]) 
{

#ifndef DEBUG_MSVC
    std::string filename("test_IO.tsv");
#else
	std::string filename("C:\\SourceForge Projects\\GLUES_driver\\test_IO.tsv");
#endif
    
    std::ifstream ifs1,ifs2,ifs;

    ifs1.open(filename.c_str(),ios::in);
	assert( ifs1.is_open() );
    ifs2.open(filename.c_str(),ios::in);
	assert( ifs2.is_open() );

    unsigned long int nrow, ncol;

	cout << "Testing repeated runs of count_ascii_rows() and "
		<< "count_ascii_columns()\n";
	for( int i =0; i < 5; i++ )
	{
		nrow=IO<void>::count_ascii_rows(ifs1);
		ncol=IO<void>::count_ascii_columns(ifs2);
		cout << "Number of rows: " << nrow << endl;
		cout << "Number of cols: " << ncol << endl;
	}

    ifs1.close();
    ifs2.close();

	//std::vector< std::vector<double> > data;
/*   ifs.open(filename.c_str(),ios::in);
    //nrow=IO::read_ascii_table(ifs,data,0,0,0,0);
    cout << "---------------------\n"; 
    cerr << "Number of rows read: " << nrow << endl;
    for (i=0; i< nrow ; i++) {
	for (j=0; j< ncol ; j++)
	    fprintf(stdout,"%5.0f ",data[i][j]);
	cout << endl;
    }
    cout << "---------------------\n"; 
    ifs.close();
    
    ifs.open(filename.c_str(),ios::in);
    for (i=0; i<nrow; i++) for (j=0; j<ncol; j++) data[i][j]=0;
    //nrow=IO::read_ascii_table(ifs,data,1,2,0,0);
    cout << "---------------------\n"; 
    cout << "Number of rows read, offset (1,2): " << nrow << endl;
    for (i=0; i< nrow ; i++) {
	for (j=0; j< ncol ; j++)
	    fprintf(stdout,"%5.0f ",data[i][j]);
	cout << endl;
    }
    cout << "---------------------\n"; 
    
    ifs.close();
*/  
    
	std::vector< std::vector<double> > data;
	std::vector<float> fvec;

	cout << "Testing read_ascii_table( vector<vector<double>> )" << endl;
	
	ifs.open(filename.c_str(),ios::in);
	assert( ifs.is_open() );

    nrow=IO<double>::read_ascii_table(ifs,data,1,0,4,4);

    cout << "---------------------\n"; 
    cout << "Number of rows read, offset (1,0), max (4,4): " << nrow << endl;
	PrintMatrix( data );
    cout << "---------------------\n"; 

	cout << "Testing read_ascii_table( vector<float> )" << endl;
	cout << "With: 1,0,4,4 " << endl;
	nrow = glues::IO<float>::read_ascii_table( ifs, fvec, 1,0,4,4 );
	cout << "Number of rows read, offset (1,0), max (4,4): " << nrow << endl;
	PrintVector( fvec );

	ifs.close();
    return 0;

}

template <class T>
void PrintVector( std::vector<T> &data )
{
	size_t i;

	for( i = 0; i < data.size(); ++i )
	{
		cout << data.at(i) << ' ';
	}
	cout << endl;
}

template <class T>
void PrintMatrix( std::vector< std::vector<T> > &data )
{
	size_t i,j;

	for( i = 0; i < data.size(); ++i )
	{
		for( j = 0; j < data.at(i).size(); j++ )
		{
			cout << data.at(i).at(j) << ' ';
		}
		cout << endl;
	}
}