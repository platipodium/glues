#include "../IO.h"
#include <iostream>
#include <fstream>
#include <cstdio>
#include <cstdlib>

using glues::IO;
using namespace std;

int main (int argc, char* argv[]) 
{

    unsigned int i,j;

    std::string filename("test_IO.tsv");
    
    std::ifstream ifs1,ifs2,ifs;

    ifs1.open(filename.c_str(),ios::in);
    ifs2.open(filename.c_str(),ios::in);

    unsigned long int nrow, ncol;

    nrow=IO::count_ascii_rows(ifs1);
    ncol=IO::count_ascii_columns(ifs2);

    ifs1.close();
    ifs2.close();

    cout << "Number of rows: " << nrow << endl;
    cout << "Number of cols: " << ncol << endl;
   
    double** data;

    data=(double**)malloc(nrow*sizeof(double*));
			  
    for (i=0; i< nrow ; i++) {
 	data[i]=(double*)malloc(ncol*sizeof(double));
    }
    
     for (i=0; i<nrow; i++) for (j=0; j<ncol; j++) data[i][j]=0;
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
    ifs.open(filename.c_str(),ios::in);
    for (i=0; i<nrow; i++) for (j=0; j<ncol; j++) data[i][j]=0;
    nrow=IO::read_ascii_table(ifs,data,2,3,4,4);
    cout << "---------------------\n"; 
    cout << "Number of rows read, offset (2,3), max (3,5): " << nrow << endl;
    for (i=0; i< nrow ; i++) {
	for (j=0; j< ncol ; j++)
	    fprintf(stdout," %3.0f ",data[i][j]);
	cout << endl;
    }
    cout << "---------------------\n"; 

    ifs.close();
    return 0;

}
