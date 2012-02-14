/* GLUES input/output routines; this file is part of
   the Global Land Use and technological Evolution Simulator
   
   Copyright (C) 2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012
   Carsten Lemmen <carsten.lemmen@hzg.de>, Kai Wirtz <kai.wirtz@hzg.de>

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

   @author Carsten Lemmen <carsten.lemmen@hzg.de>
   @author Kai W Wirtz <kai.wirtz@hzg.de
   @date   2012-02-14
   @file Input.cc 
   @brief Input/output routines 
*/

/****************************************************
 *  Preprocessor definitions and includes section   *
 ****************************************************/
#include <cstring>
#include <fstream>
#include <streambuf>
#include <vector>
#include <map>
#include <cassert>	
#include "Globals.h"
#include "AsciiTable.h"
#ifdef HAVE_NETCDF_H
#include "netcdfcpp.h"
#endif

#include "Input.h"

std::string mappingstring;
std::string regionstring;

double hyper(double,double,int);

//unsigned int read_ascii_table(std::istream& is, int** table_int); 

/**
   @brief Output of constant region properties 
*/
int out_statreg() {
  FILE *resfile;
  std::ofstream ofs;
  std::string statreg;
  unsigned int i;

  statreg.assign(datapath);
  statreg.append("regions_stat.tsv");
  
  //ofs.open(statreg.c_str(),ios::out);
  resfile=fopen(statreg.c_str(),"w");
  
  cout << _("Writing constant region properties to ") << statreg <<endl; 

  for (i=0; i<numberOfRegions; i++)
  {
    ice_fac = IceFac(regions[i].Latitude(),regions[i].Longitude());
    regions[i].Write(resfile,i+1);
  }
  fclose(resfile);

  statreg.assign(datapath);
  statreg.append("region_geography.tsv");
  resfile=fopen(statreg.c_str(),"w");
  
  cout << _("Writing geographic region properties to ") << statreg <<endl; 

  for (i=0; i<numberOfRegions; i++)
      regions[i].Write(resfile);
  fclose(resfile);
  return 0;
}


/*----------------------------------------------------*/
/*        Writing box boundaries of civ centers       */
/*----------------------------------------------------*/
int out_boxes() {
  std::ofstream ofs;
  std::string boxfile;
  double norm[5]={1E3,1,1,1,1};
  unsigned int i,j;

  boxfile.assign(datapath);
  boxfile.append("civ_boxes.tsv");

  ofs.open(boxfile.c_str(),ios::out);
  cout << _("Writing boundaries of known civ centers to ") << boxfile <<endl; 
  for(i=0;i<RowsOfdata_agri_start;i++)
  {
    ofs.precision(0);
    for(j=0;j<5;j++) ofs << data_agri_start[i][j]*norm[j];
    ofs << endl;
  }  
  ofs.close();
  return 0;
}

/*-----------------------------------------------------*/
/*     Output of NPP relations (fertility ndomax)      */
/*-----------------------------------------------------*/
int out_vegetation(){
  //ofstream file;
  FILE *sp;
  double nd,fe,npp;
  
  //file.open("npp_ndom_fert.dat",ios::out);
  sp=fopen("npp_ndom_fert.dat","w");
  for(npp=0;npp<2001;npp+=50) { 
    nd=hyper(kappa,npp,4);
    fe=hyper(kappa*2,npp,2);
    fprintf(sp,"%1.3f %1.4f %1.4f\n",npp,nd,fe);
  }
  fclose(sp);
  //file.close();
  return 0;
}


/* -------------------------------------------------- */
/*    Global function for hyperbolical relations      */
/* -------------------------------------------------- */
double hyper(double kap, double np, int n) {
  double ka=pow(kap,n-1);
  return n*ka*np/(ka*kap*(n-1)+pow(np,n));
}
/* -------------------------------------------------- */


// -------------------------------------------------------------------------------
//
// -------------------------------------------------------------------------------
// Read to the end to see how many regions there are

unsigned int RegionNumber() {

  unsigned int number=0;

#ifdef HAVE_NETCDF_H
  NcFile ncin(regionstring.c_str(),NcFile::ReadOnly);
  if (ncin.is_valid()) {
    NcDim* dim=ncin.get_dim("region");
    number=(unsigned int)dim->size();
    cout << number << _(" regions") << " OK" << endl;
    return number;
  }
#endif

  static const unsigned int BUFSIZE=1024;
  static char charbuffer[BUFSIZE];
  char c;
  
  ifstream ifs;
  
  ifs.open(regionstring.c_str(),ios::in);
  if (ifs.bad() || ! ifs.is_open()) {
    cout << _("ERROR") << endl;
    cout << _("Failed to open file ") << regionstring << endl;
    return 0;
  }
  
  do {
    // Skip lines which do not commence with a digit or whitespace
    c=ifs.peek();
    if (( (c < '0') || (c > '9')) && (c!=' ') && (c!='\t') ) {
      ifs.getline(charbuffer,BUFSIZE);
      continue;  
    }
    
    ifs.getline(charbuffer,BUFSIZE);
    
    c=charbuffer[0];
    unsigned int i=0;
    while ((c!='\0') && ((c==' ') || (c=='\t'))) c=charbuffer[i++];
    if ( (c < '0') || (c > '9') ) continue;
    number++;          
  } while (!ifs.eof()) ; 
  
  cout << number << _(" regions") << " OK" << endl;
  
  ifs.close();
  return number;
}

// -------------------------------------------------------------------------------
//
// -------------------------------------------------------------------------------
int read_dim_SiteRegfile() 
{
  
  /** SiteRegfile is "EventInReg.dat", an ascii tsv file 
      with dimensions MaxProxyReg x numberOfRegions 
      This method reads only the columns of the first line */
  
  const static unsigned int BUFSIZE=1024;
  static char fname[199];
  //static char charbuffer[BUFSIZE];
 
  ifstream ifs;
  string line;
  int dummy;
  
  strcpy(fname,datapath);strcat(fname,SiteRegfile);
  cout << "Reading columns of " << fname << " ... ";
  ifs.open(fname,ios::in);
  if (ifs.bad()) {
    std::cout << "\nERROR\tTried to open file " << fname << " and failed" << endl;
    return 0;
  }
  
  getline(ifs,line);
  std::istringstream iss(line);

  while (iss >> dummy) MaxProxyReg++;

  ifs.close();
  cout << "SUCCESS" << endl;
  
  cout << line << " MaxProxyReg=" << MaxProxyReg << endl;

  return 1;
}

int read_dim_SiteRegfile_orig() {

    /** SiteRegfile is "EventInReg.dat", an ascii tsv file 
	with dimensions MaxProxyReg x numberOfRegions 
	This method reads only the columns of the first line */

    const static unsigned int BUFSIZE=1024;
    static char fname[199],charbuffer[BUFSIZE];
 
    ifstream file;
    string line;

    strcpy(fname,datapath);strcat(fname,SiteRegfile);
    cout << "Reading columns of " << fname << " ... ";
    file.open(fname,ios::in);
    if (file.bad()) {
	std::cerr << "\nERROR\tTried to open file " << fname << " and failed" << endl;
	return 0;
    }
    file.getline(charbuffer,BUFSIZE);
    file.close();
    cout << "SUCCESS" << endl;

    line=charbuffer;
    cout << line << " L=" << line.length() << endl;

    for (unsigned int i=0; i<line.length() ; i++) {
	if (line[i]==' ')  MaxProxyReg++;
    } 

    return 1;
}

/** SiteRegfile is "EventInReg.dat", an ascii tsv file 
    with dimensions MaxProxyReg x numberOfRegions 
    @return MaxProxyReg
    checks whether number of rows (should equal numberOfRegions)
*/

unsigned int read_SiteRegfile() 
{

    std::string filename(datapath);
    filename += SiteRegfile;
    ifstream ifs;
    unsigned int n,j;

    std::cout << "Read " << filename;

    ifs.open(filename.c_str(),ios::in);
    assert( ifs.is_open() );
    
    MaxProxyReg=glues::IO<void>::count_ascii_columns(ifs);
    
    if (MaxProxyReg >= MAXPROXY) {
      std::cerr<< "\nERROR\t Number of proxies greater than MAXPROXY constant.\n";
      return 0;
    }
    if (MaxProxyReg == 0) {
      std::cerr<< "\nERROR\t Number of proxies cannot be zero.\n";
      return 0;
    }
    
    for (j=0; j<(unsigned int)MaxProxyReg; j++) {
      RegSiteInd[j]=(int *)(malloc(numberOfRegions*sizeof(int)));
      //RegSiteInd[j]=new int[numberOfRegions];
    }

    std::vector< std::vector<int> > data;
	n=glues::IO<int>::read_ascii_table(ifs,data);
    ifs.close();

    assert(data.size() == numberOfRegions);
    assert(data.at(1).size() == MaxProxyReg);

    std::cout << " " << data.size() << " regions x " << data.at(1).size() << " sites"; 

    for (j=0; j<(unsigned int)MaxProxyReg; j++) {
      for (unsigned int i=0; i<numberOfRegions; i++) {
        RegSiteInd[j][i]=data.at(i).at(j);
    }}

    cout << " OK" << endl;
    return MaxProxyReg;
}


/**
  @deprecated: This function replaces the deprecated read_SiteRadfile()
*/

unsigned int read_region_eventradius(const std::string & filename, int** matrix_int) 
{

  std::ifstream ifs;
  unsigned int n;
  
  std::cout << "Read  " << filename;

  std::vector< std::vector<int> > data;
  ifs.open(filename.c_str(),ios::in);
  assert(ifs.is_open());
  n=glues::IO<int>::read_ascii_table(ifs,data);
  ifs.close(); 
  
  assert(data.size() == numberOfRegions);
  assert(data.at(1).size() == MaxProxyReg);
  
  //n=read_ascii_table(ifs,matrix_int);

  for (unsigned int j=0; j<(unsigned int)MaxProxyReg; j++) {
      for (unsigned int i=0; i<numberOfRegions; i++) {
        matrix_int[j][i]=data.at(i).at(j);
    }}

  std::cout << " " << data.size() << " regions x " << data.at(1).size() << " sites"; 
  cout << " OK" << endl;
  
  return n;
}


/**
   @param none
   @return number of sites
*/

unsigned int read_proxyevents() 
{
  
    string filename(datapath);
    float fdummy;
    ifstream ifs;
  
    filename += eventfile;

    std::cout << "Read " << filename << " ";
    
    ifs.open(filename.c_str(),ios::in);
    assert(ifs.is_open());
    
    MaxEvent=glues::IO<void>::count_ascii_columns(ifs)-2;
    numberOfSites=glues::IO<void>::count_ascii_rows(ifs);
    std::cout << numberOfSites << " sites x " << MaxEvent << " events";

	std::vector< std::vector<double> > data;
	glues::IO<double>::read_ascii_table(ifs,data);
	
    assert(data.size()==numberOfSites);
    assert(data.at(1).size()==MaxEvent+2);
    //std::cout << data.size() << " sites x " << data.at(1).size()-2 << " events";

    EventTime= (double *)(malloc(numberOfSites*MaxEvent*sizeof(double)));
    EventSerMax = (double *)(malloc(numberOfSites*sizeof(double)));
    EventSerMin = (double *)(malloc(numberOfSites*sizeof(double)));
    
    //ifstream ifs2;
    //ifs2.open(filename.c_str(),ios::in);
   // Read to the end to see how many regions there are
    for (unsigned int i=0;  i<(unsigned int)numberOfSites; i++) {
	  for (unsigned int j=0; j<(unsigned int)MaxEvent; j++) {
	    //ifs >> fdummy;
	    //*(EventTime+j+i*MaxEvent)=fdummy;
	    *(EventTime+j+i*MaxEvent)=data.at(i).at(j);
	  }
	  EventSerMin[i]=data.at(i).at(MaxEvent);
	  EventSerMax[i]=data.at(i).at(MaxEvent+1);
	  //ifs >> fdummy; EventSerMin[i]=fdummy;
	  //ifs >> fdummy; EventSerMax[i]=fdummy;
    }
    
    ifs.close();
    cout << " OK" << endl;
    return numberOfSites;
}

// -------------------------------------------------------------------------------
//
// -------------------------------------------------------------------------------
vector<PopulatedRegion>::size_type RegionProperties(vector<PopulatedRegion>& region) 
{
  static const unsigned int BUFSIZE=1024;
  static char charbuffer[BUFSIZE];
  ifstream ifs;
  unsigned int i=0;
  char c;
    //Input input;
    
  //numberOfRegions=input.getRegionNumber();
  numberOfRegions=RegionNumber();
  assert(numberOfRegions>0);
  
  regions = new PopulatedRegion[numberOfRegions]; // old
  region.clear();

#ifdef HAVE_NETCDF_H
  NcFile ncin(regionstring.c_str(),NcFile::ReadOnly);
  if (ncin.is_valid() ){
    // Read non-time dependent variables 
    NcVar *var=NULL;
    NcDim *rdim=ncin.get_dim("region");
    NcDim *tdim=ncin.get_dim("time");
    int nreg=rdim->size();
    assert(numberOfRegions==nreg);
 
/*    var=ncin.get_var("region"); int* region_id=new int(nreg); var->get(region_id,nreg);    
    var=ncin.get_var("region_continent");  int contid; var->get(&contid,1);
    var=ncin.get_var("area"); double area; var->get(&area,1);
    var=ncin.get_var("lat"); double lat; var->get(&lat,1);
    var=ncin.get_var("lon"); double lon; var->get(&lon,1);
    var=ncin.get_var("npp"); double* npp=new double(nreg); //var->get(npp,nreg);
    var=ncin.get_var("gdd"); double gdd; var->get(&gdd,nreg);
  
    const double lai=0;
    double tlim=gdd/365.0;
    
    for (i=0; i<numberOfRegions; i++)  {
           
      PopulatedRegion* popregion = new PopulatedRegion(npp[i],tlim,lai,(unsigned int)region_id[i],
        contid,area,lat,lon); 
      region.push_back(PopulatedRegion());
      regions[i] = *popregion;

    }
    ncin.close();
    delete region_id,delete npp;*/
    return region.size();
  }
#endif

  ifs.open(regionstring.c_str(),ios::in);
  assert(ifs.good());
  
  while (ifs.good() && !ifs.eof() && i<numberOfRegions) {
 
    c=ifs.peek();
    
    /* Eat white space */
    while ( (c == ' ') || (c == '\t') ) {
      ifs.get();
      c=ifs.peek();
    }
    /* Skip if non-numeric */
    if ( (c < '0') || (c > '9') ) {
	  ifs.getline(charbuffer,BUFSIZE);
	  continue;
    }
    
    /* Later to be replaced */
      regions[i] = PopulatedRegion(ifs);
      regions[i].Index(i);
      
      region.push_back(PopulatedRegion(regions[i]));
      // todo: add index generation
      //cout << i++ << endl;;
      //cout << region.size() << " "; 
      i++;
   }
 
  ifs.close();
  cout << " OK\n";
  return region.size();
}

// -------------------------------------------------------------------------------
//
// -------------------------------------------------------------------------------

int read_neighbours() {

  maxneighbours=0;
  
  cout << _("Reading neighbor info from file ") << regionstring ;
#ifdef HAVE_NETCDF_H
  NcFile ncin(regionstring.c_str(),NcFile::ReadOnly);
  if (ncin.is_valid()) {
    NcDim* rdim=ncin.get_dim("region");
    NcDim* ndim=ncin.get_dim("neighbour");
    NcVar* var=ncin.get_var("number_of_neighbours");
    int* number_of_neighbours = new int(rdim->size());
    var->get(number_of_neighbours,rdim->size());
    std::cout << " " << rdim->size() << " x " << ndim->size() << endl;
    /* Next lines commented due to memory leak errors */
    /*var=ncin.get_var("region_neighbour");
    int* neighbour=new int(rdim->size()*ndim->size());
    var->get(neighbour,rdim->size()*ndim->size());
    var=ncin.get_var("region_boundary");
    double* boundary=new double(rdim->size()*ndim->size());
    var->get(boundary,rdim->size()*ndim->size());
    
    for (int i=0; i<rdim->size(); i++) {
      cerr << endl << i ; 
      if (number_of_neighbours[i]==0) continue ;
      for (int j=0; j<ndim->size(); j++) {
        cerr << " " << neighbour[i*ndim->size()+j] ;   
        if (neighbour[i*ndim->size()+j]==0) break;
        PopulatedRegion* neighid;
        neighid=&regions[neighbour[i*ndim->size()+j]];
        regions[i].AddNeighbour(neighid,boundary[i*ndim->size()+j],1);
        regions[j].AddNeighbour(regions+i,boundary[i*ndim->size()+j],1);
      }
    }*/
    std::cout << " OK" << std::endl;;
    return maxneighbours;
  }
#endif

  static const unsigned int BUFSIZE=1024;
  static char charbuffer[BUFSIZE];
  char c;

  ifstream ifs;

  unsigned int selfid,numneigh;
  int neighid;
  float neigh_boundary,neigh_distance;

  ifs.open(regionstring.c_str(),ios::in);
 
  if (ifs.bad()) {
    cout << "\nERROR\t[Input::read_neighbours()]\t Tried to open file " << regionstring << " and failed" << endl;
    return 0;  // The file does not exist
  }

  /** find a mapping from Id to index of all regions */
  map<unsigned int,unsigned int> idmap;
//  for (unsigned int i; i<numberOfRegions; i++) cout << regions[i].Index() << "/" << regions[i].Id() << endl; 
  for (unsigned int i; i<numberOfRegions; i++) idmap[regions[i].Id()]=i;
 
  unsigned int i=0;

  
  while (i<numberOfRegions && !ifs.eof() ) {
    // Skip lines which do not start with a number
    c=ifs.peek();
    if ( (c < '0') || (c > '9') ) {
	  ifs.getline(charbuffer,BUFSIZE);
	  continue;  
    }

    // Read id, skip four fields and read number of neighbours
    ifs >> selfid;  
    for (unsigned int j=0; j<5; j++) ifs >> numneigh;
    
    //std::cerr << i << " " << numneigh; 
    
    // For all numneighbours add them
    for (unsigned int j=0; j<numneigh; j++) {

	  // Read neighbour id, boundary length and distance 
	  /** @todo implement neighbour distance calculation */
      ifs >> charbuffer;
      sscanf(charbuffer,"%d:%f:%f",&neighid,&neigh_boundary,&neigh_distance);
     
      // neighbours with negative id are sea, positive and 0 is land area,
      // only consider land areas
      if ( neighid>=0 ) {
        //unsigned int in=idmap[neighid]; // some bug here, TODO
        unsigned int in=neighid;
        regions[i].AddNeighbour(&regions[in],neigh_boundary,1);
        if (in < i) regions[in].AddNeighbour(&regions[i],
						     neigh_boundary,1);

        //std::cerr << " " << neighid << ":" << in << ":" << regions[i].Neighbour()->Region()->Id();
    }				     
    
    }
    //std::cerr << std::endl;
    i++;
    // if (i>680 || i<10) printf("read %d %d %d \n",i,selfid,numneigh);
  }
  ifs.close();
	
  /** Make sure that neighbours are mutual neighbours, and count neighbours
	  @todo Delete duplicate neighbours 
  */
  GeographicalNeighbour *gn, *jn;
  for (unsigned int i=0; i<numberOfRegions; i++) {
    numneigh=0;
    maxneighbours=0;
    std::cerr << i; 
    if (gn=regions[i].Neighbour())  {
      numneigh++;
      unsigned int j=gn->Region()->Id();
      //std::cerr << " " << j; 
      GeographicalNeighbour *jn=regions[j].Neighbour();
      while (jn) { 
          if (jn->Region()->Id()==i) break;
          else jn=jn->Next();
      }
      if (jn==0) std::cout << "Region " << i << " is not a mutual neighbour of " << j << endl;
      while (gn=gn->Next()) {
          numneigh++;
          j=gn->Region()->Id();
          jn=regions[j].Neighbour();
          while (jn) { 
            if (jn->Region()->Id()==i) break;
            else jn=jn->Next();
          }
          if (jn==0) std::cout << "Region " << i << " is not a mutual neighbour of " << j << endl;
      }
    }
    regions[i].Numneighbours(numneigh);
    if (numneigh>maxneighbours) maxneighbours=numneigh;
    //std::cerr << std::endl;
  }
	 
 // std::cout << " OK (max=" << maxneighbours << ")" << std::endl;;
  return maxneighbours;
}


// -------------------------------------------------------------------------------
//
// -------------------------------------------------------------------------------
int read_neighbours_dead() {

  static const unsigned int BUFSIZE=1024;
  static char charbuffer[BUFSIZE];

  ifstream ifs;

  unsigned int selfid,neighid,numneigh;
  float neigh_boundary;

  cout << "Reading neighbor info from file " << regionstring << " ... ";
  ifs.open(regionstring.c_str(),ios::in);
  //file.open(regionstring);
  if (ifs.bad()) {
    cout << "\nERROR\t[Input::read_neighbours()]\t Tried to open file " << regionstring << " and failed" << endl;
    return 0;  // The file does not exist
  }

  // Get rid of first empty line
  ifs.getline(charbuffer,BUFSIZE);

  unsigned int count=0;
  while(ifs.good()) {
    
    ifs >> selfid;
    if (selfid != count) {
	cout << "Selfid " << selfid << " does not match count " << count << ". Exit" << endl;
	//return 0;
    }
    for (unsigned int j=0; j<5; j++) ifs >> numneigh;
    for (unsigned int j=0; j<numneigh; j++) {

    ifs >> charbuffer;
      sscanf(charbuffer,"%d:%f",&neighid,&neigh_boundary);
      regions[count].AddNeighbour(&regions[neighid],
			      neigh_boundary,1);
      if (neighid < selfid) regions[neighid].AddNeighbour(&regions[selfid],
						     neigh_boundary,1);
						     
    

    }
    printf("read %d %d \n",selfid,numneigh);
    count++;
  }
  ifs.close();

  cout << "SUCCESS\n";
  return 1;
}

int read_neighbours1() {

  static const unsigned int BUFSIZE=2048;
  static char charbuffer[BUFSIZE];
  
  ifstream ifs;

  unsigned int selfid,numneigh;
  int neighid;
	float neigh_boundary;//,neigh_dist;
 

  cout << "Reading neighbor info from file " << regionstring << " ... ";
  ifs.open(regionstring.c_str(),ios::in);
  if (ifs.bad()) {
      cout << "\nERROR\t[Input::read_neighbours()]\t Tried to open file " << regionstring << " and failed" << endl;
      return 0;  // The file does not exist
  }
 
  unsigned int i=0;
  while (!ifs.eof()) {
     // Read region id, 
     // then skip first  5 entries not related to neighbours
 
      ifs >> selfid;
 
      cout << selfid; 
    for (unsigned int j=0; j<5; j++) ifs >> numneigh;
    for (unsigned int j=0; j<numneigh; j++) {

    ifs >> charbuffer;
    //sscanf(charbuffer,"%d:%f:%f",&neighid,&neigh_dist,&neigh_boundary);
sscanf(charbuffer,"%d:%f:%f",&neighid,&neigh_boundary);
      if (neighid>=0) {
	  regions[i++].AddNeighbour(&regions[neighid],
				  neigh_boundary,1);
	  if (neighid < selfid) regions[neighid].AddNeighbour(&regions[selfid],
							      neigh_boundary,1);
      }
      // else (neighid<0) sea region TODO
      cout << " " << neighid << ":" << neigh_boundary ;
    }
    cout << endl;
  }
  ifs.close();

  cout << "SUCCESS\n";
  return 1;
}

/* -------------------------------------------------- */
/** This function is obsolete */

int read_mapping() {
  return 1;

  static const unsigned int BUFSIZE=1024;
  unsigned int* cellids=NULL;
  unsigned int num=0,selfid=0,last=0;
  static char charbuffer [BUFSIZE];

  ifstream file;

  cout << "Reading file " << mappingstring << " ... ";
  file.open(mappingstring.c_str());
  if (file.bad()) {
    cout << "\nERROR\tTried to open file " << mappingstring << " and failed" << endl;
    return 0;  // The file does not exist
  }

  // Skip first (empty line)
  file.getline(charbuffer,(int)BUFSIZE);
  
  for (unsigned int i=0; i<numberOfRegions && !file.eof(); i++) {

    if (last!=i) file >> selfid;
    else selfid=last;

    if (selfid != i) {
      cout << "Something went wrong with ids ..." << 
	i << "!=" << selfid << endl;
      return 0;
    }
    num = regions[i].CellNumber();
 //   cout << " Reading " << num << " Cells for region " << selfid <<endl;
    cellids = new unsigned int[num];
    for (unsigned int j=0; j<num; j++) {
      file >> cellids[j];
      // Temporary bugfix...
      
      last=cellids[j];
      if (last<=numberOfRegions || last>=720*360) {
	cout << " CellID out of bounds, should satisfy "
	     << numberOfRegions << " < " << last 
	     << " < " << 720*360 << " ... corrected" << endl;
	num=j+1;
	regions[i].CellNumber(num);
      }
	
    }
    regions[i].Mapping(num,cellids);
    delete [] cellids;
  }
  file.close();

  cout << "SUCCESS\n";
  return 1;
}


/*----------------------------------------------*/
/*     Prepares string for filenames            */
/*----------------------------------------------*/
int init_names() {
  char *tt;
  strcpy(resultstring,datapath);
  strcat(resultstring,resultfilename);
  strcpy(spreadstring,datapath);
  strcat(spreadstring,spreadfile);
  regionstring.assign(datapath);
  regionstring.append(regiondata);
  mappingstring.assign(datapath);
  mappingstring.append(mappingdata);
  strcpy(climatestring,datapath);
  strcat(climatestring,climatefile);
  tt=strrchr((char*)varresfile,'.');
  *(tt-1)=48+RandomInit+7*(RandomInit>9);
  strcpy(varrespath,datapath);
  strcpy(varrespath,varresfile);
  
  cout << "  Output of results to \t" << resultstring << endl;
  cout << "  Region data from   \t" << regionstring << endl;
  cout << "  Neighbour data from \t" << regionstring << endl;
  cout << "  Climate data from \t" << climatestring << endl;
 
  return 0;
}

// -------------------------------------------------------------------------------
//
// -------------------------------------------------------------------------------
int writeresultheader(FILE* resultfile, unsigned int inspectid) {
  char comsym[3]="%";

  if (!inspectid)
    strcpy(comsym,"%%");

  fprintf(resultfile,"%s Tab-separated result file for Population %3d\n",comsym,inspectid);
  fprintf(resultfile,"%s LocalSpread=%d RemoteSpread=%d\t",comsym,LocalSpread,RemoteSpread);
  fprintf(resultfile,"%s Model run from %2.0f to %6.0f at stepsize %2.0f\n",
	  comsym,TimeStart,TimeEnd,TimeStep);
  fprintf(resultfile,"%s CultIndex=%3.1f Space2Time=%3.1f RelChange=%3.f NumMethod=%d\n",
	  comsym,CultIndex,Space2Time,RelChange,NumMethod);
  fprintf(resultfile,"%s flucampl=%3.1f flucperiod=%4.0f\n",comsym,flucampl,flucperiod);
  fprintf(resultfile,"%s regenerate=%4.2f spreadm=%3.1f gammad=%7e\n",comsym,
	  regenerate,spreadm,gammad);
  fprintf(resultfile,"%s NPPCROP=%6.1f \\deltat=%4.2f overexp=%4.2f\n",
	  comsym,NPPCROP,deltat,overexp);
  fprintf(resultfile,"%s gdd_opt=%6.1f LiterateTechnology=%4.1f KnowledgeLoss=%3.1f\n",
	  comsym,gdd_opt,LiterateTechnology,KnowledgeLoss);
  fprintf(resultfile,"%s SaharaDesert=%d LGMHoloTrans=%d\n",
	  comsym,SaharaDesert,LGMHoloTrans);
  fprintf(resultfile,"%s\\kappa=%1.0f\t\\omega=%1.2f\t\\gamma_b=%1.4f\n",
	  comsym,kappa,omega,gammab);
  fprintf(resultfile,"%s\\delta_t=%1.1f\t\\ndommaxmean=%1.1f\tspreadv=%1.1f\n",
	  comsym,deltat,ndommaxmean,spreadv);
  if (inspectid)
    fprintf(resultfile,"%stime ",comsym);
  else
    fprintf(resultfile,"%sid   ",comsym);
  fprintf(resultfile,"natfr actfr prod  grow   dens  tech  ndom  ");
  fprintf(resultfile,"qfarm npp   rgr   ndomax tlim  germs resis disea\n");

  return 0;
}

/*----------------------------------------------*/

int cleanup() {
  unsigned int i=0;
  while (climatedata[i]) delete[] climatedata[i++];
  delete climatedata;
  delete[] DISTANCEMATRIX;

  return 0;
}


/*----------------------------------------------------*/
/*      Stores last states  into ascii file           */
/*----------------------------------------------------*/
int write_result() {
  FILE  *resultfile;
  resultfile=fopen(resultstring,"w");
  cout << "\nWriting final states after "<< TimeEnd << " years to ";
  cout <<  resultstring <<" ...\n";
  writeresultheader(resultfile,0);
  for (unsigned int i=0; i<numberOfRegions; i++)
    populations[i].Write(resultfile,i+1);
  fclose(resultfile);

  return 0;
}

/*---------------------------------------------------------*/
/*                 open array of result files             */
/*---------------------------------------------------------*/
int open_watchfiles() {
  std::string watchfilename;
  char watchreg[256];
  unsigned int i;

  for(i=0; i<LengthOfins; i++) {
    watchfilename.assign(datapath);
 
    sprintf(watchreg,"pop_%04d.tsv\0",ins[i]);
    watchfilename.append(watchreg);

    cout<<" writing population "<<ins[i]<<" to "<<watchreg<<endl;
    if (!(watchfile[i] = fopen(watchfilename.c_str(),"w"))) {
      cout << "\nERROR\tCould not open output file " << watchfilename << " for writing\n";
      return 1;
    }
    writeresultheader(watchfile[i],ins[i]);
  }

  return 0;
}

// -------------------------------------------------------------------------------
int ReadLines(char* filename){

  static const unsigned int BUFSIZE=40024;
  static char charbuffer [BUFSIZE];
  unsigned int num=0;
  ifstream file;

  file.open(filename,ios::in);
  if (file.bad()) {
    cout << "\nERROR\tTried to open file " << filename << " and failed" << endl;
    return 0;  // The file does not exist
  }
  while (!file.eof() ) {
    file.getline(charbuffer, BUFSIZE);
    if(strlen(charbuffer)>1) num++;
  }
  file.close();
 //   printf("\n read from file %d lines\n\n",num);
return num;
}
 
//namespace glues {
  
/*
unsigned int Input::RegionNumber() 
{ 
    
  cout << "Reading " << regionstring << " ... ";
  number=getRegionNumber(regionstring);
  cout << number << " regions ...\n ";
  
}
  
  unsigned int Input::getRegionNumber(std::ifstream & ifs)
  {
    
    unsigned int number=0;
    static string line;
    
    do
      {
	getline(ifs,line);
	if (line.length()!=0) number++;
      }
    while ( !ifs.eof() );
    
    return number;
  }


  unsigned int Input::getRegionNumber(char* filename)
  {
    return getRegionNumber(string(filename));
  }
  
  unsigned int Input::getRegionNumber(std::string filename)
  {
    std::ifstream ifs;
    unsigned int number;
    
    ifs.open(filename.c_str(),std::ios::in);
    if ( ifs.good() )
      {
	number=getRegionNumber(ifs);
	ifs.close();
	return number;
      }
    else return 0;
    
  }

  int Input::getRegionProperties(char* filename) 
  {
    return Input::getRegionProperties(string(filename));
  }

  int Input::getRegionProperties(std::string filename)
  {
    std::ifstream ifs;
        
    ifs.open(filename.c_str(),std::ios::in);
    if ( ifs.good() )
      {
	Input::getRegionProperties(ifs);
	ifs.close();
	return 0;
      }
    else return 1;
  }

  
  int Input::getRegionProperties(std::ifstream& ifs)
  {
    static string line;
    unsigned int i=0;
    
    do
      {
	getline(ifs,line);
	if (line.length()==0) continue;
	regions[i]=PopulatedRegion(line);
	i++;
      }
    while ( !ifs.eof() );
    
    return 0;
  }
*/
//}
