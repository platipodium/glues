#include <iostream>
#include <fstream>
#include <cmath>
#include <assert.h>

int main(int argc, char* argv[]) 
{

  std::string filename="mapping_80_685.dat.len";
  std::ifstream ifs;
  ifs.open(filename.c_str(),std::ios::binary);
  
  // get length of file:
  ifs.seekg (0, std::ios::end);
  int length = ifs.tellg();
  ifs.seekg (0, std::ios::beg);

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
  	//std::cout << i+1 << ":" << lbuffer[i] << ":" << lmax << ":" << sum << std::endl;
  }
  
  // There should be lmax * nreg data in the mapping file
  
  filename="mapping_80_685.dat";
  ifs.open(filename.c_str(),std::ios::binary);
  ifs.seekg (0, std::ios::end);
  length = ifs.tellg();
  ifs.seekg (0, std::ios::beg);
  delete[] buffer;
  buffer = new char [length];
  ifs.read (buffer,length);
  ifs.close();
 
  ibuffer =(int*)buffer;
  int nnum=(length*sizeof(char))/sizeof(int);
  
  assert(lmax*nreg==nnum);

  // print header
  std::cout << "# This file was automatically generated, do not edit" << std::endl
       << "# Creator: print_mapping.cc" << std::endl
       << "# File format: colon-separated value" << std::endl
       << "# Data format: "<< std::endl
       << "#    col 1 region id (greater zero)" << std::endl
       << "#    col 2 number of cells (n) in region" << std::endl
       << "#    col 3..n+2 id of cells belonging to region" << std::endl;

  for (i=0; i< nreg; i++) 
  {
  	n=lbuffer[i];
  	std::cout << i+1 << ":" << n ;
  	for (int j=0; j<n; j++)
  	{   	  
  	  std::cout << ":" << ibuffer[i*lmax+j]  ;
  	}  	
  	std::cout << std::endl;
  }

  // create special binary mapping files for region 271
  std::ofstream ofs;
  ofs.open("mapping_80_1.dat.len",std::ios::binary|std::ios::out);
  ofs.write((char*)(lbuffer+270),4);
  ofs.close();
  ofs.open("mapping_80_1.dat",std::ios::binary|std::ios::out);
  ofs.write((char*)(ibuffer+270*lmax),lbuffer[270]);
  ofs.close();

  delete[] buffer;
  delete[] lbuffer;
 
  return 0;
}