#include <iostream>
#include <fstream>
#include <cmath>
#include <assert.h>

using namespace std;

int main(int argc, char* argv[]) 
{

  string filename="mapping_80_685.dat.len";
  ifstream ifs;
  ifs.open(filename.c_str(),ios::binary);
  
  // get length of file:
  ifs.seekg (0, ios::end);
  int length = ifs.tellg();
  ifs.seekg (0, ios::beg);

  // allocate memory:
  char * buffer = new char [length];
  ifs.read (buffer,length);
  ifs.close();
  // lbuffer points to length indices of each region
  int * ibuffer =(int*)buffer;
  
  int nreg=(length*sizeof(char))/sizeof(int);
  int * lbuffer=new int [nreg];
  int n=0,sum=0, i=0, lmax=0;
  for (i=0; i<nreg; i++)
  {
  	lbuffer[i]=ibuffer[i];
    sum+=lbuffer[i];
    if (lbuffer[i]>lmax) lmax=lbuffer[i];
  	//cout << i+1 << ":" << lbuffer[i] << ":" << lmax << ":" << sum << endl;
  }
  
  // There should be lmax * nreg data in the mapping file
  
  filename="mapping_80_685.dat";
  ifs.open(filename.c_str(),ios::binary);
  ifs.seekg (0, ios::end);
  length = ifs.tellg();
  ifs.seekg (0, ios::beg);
  delete[] buffer;
  buffer = new char [length];
  ifs.read (buffer,length);
  ifs.close();
 
  ibuffer =(int*)buffer;
  int nnum=(length*sizeof(char))/sizeof(int);
  
  assert(lmax*nreg==nnum);

  // print header
  cout << "# This file was automatically generated, do not edit" << endl
       << "# Creator: print_mapping.cc" << endl
       << "# File format: colon-separated value" << endl
       << "# Data format: "<< endl
       << "#    col 1 region id (greater zero)" << endl
       << "#    col 2 number of cells (n) in region" << endl
       << "#    col 3..n+2 id of cells belonging to region" << endl;

  for (i=0; i< nreg; i++) 
  {
  	n=lbuffer[i];
  	cout << i+1 << ":" << n ;
  	for (int j=0; j<n; j++)
  	{   	  
  	  cout << ":" << ibuffer[i*lmax+j]  ;
  	}  	
  	cout << endl;
  }

  // create special binary mapping files for region 271
  ofstream ofs;
  ofs.open("mapping_80_1.dat.len",ios::binary|ios::out);
  ofs.write((char*)(lbuffer+270),4);
  ofs.close();
  ofs.open("mapping_80_1.dat",ios::binary|ios::out);
  ofs.write((char*)(ibuffer+270*lmax),lbuffer[270]);
  ofs.close();

  delete[] buffer;
  delete[] lbuffer;
 
  return 0;
}