/* GLUES input/output routines; this file is part of
   the Global Land Use and technological Evolution Simulator
   
   Copyright (C) 2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010
   Carsten Lemmen <carsten.lemmen@gkss.de>, Kai Wirtz <kai.wirtz@gkss.de>

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

   @author Carsten Lemmen <carsten.lemmen@gkss.de>
   @author Kai W Wirtz <kai.wirtz@gkss.de
   @date   20010-02-24
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
#include "Globals.h"
#include "AsciiTable.h"

#include "Input.h"

std::string mappingstring;
std::string regionstring;

double hyper(double,double,int);

unsigned int read_ascii_table(std::istream& is, int** table_int); 
unsigned int count_ascii_rows(std::istream& is);
unsigned int count_ascii_columns(std::istream& is);

/***************************************************
   @brief Output of constant region properties 
   @date 2007-11-28 
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
  // FILE   *resfile;
  std::ofstream ofs;
  std::string boxfile;
  double norm[5]={1E3,1,1,1,1};
  unsigned int i,j;

  boxfile.assign(datapath);
  boxfile.append("civ_boxes.tsv");

  //  resfile=fopen(boxfile.c_str(),"w");
  ofs.open(boxfile.c_str(),ios::out);
  cout << _("Writing boundaries of known civ centers to ") << boxfile <<endl; 
  for(i=0;i<RowsOfdata_agri_start;i++)
    {
      ofs.precision(0);
      for(j=0;j<5;j++) ofs << data_agri_start[i][j]*norm[j];
      ofs << endl;
      
      //	fprintf(resfile,"%2.0f\t",data_agri_start[i][j]*norm[j]);
      //      fprintf(resfile,"\n");
    }  
  //  fclose(resfile);
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

  static const unsigned int BUFSIZE=1024;
  static char charbuffer[BUFSIZE];
  char c;
  unsigned int number=0;
  
  ifstream ifs;
  
  cout << _("Reading file ") << regionstring << " ... ";
  ifs.open(regionstring.c_str(),ios::in);
  if (ifs.bad() || ! ifs.is_open()) {
    cout << _("ERROR") << endl;
    cout << _("Failed to open file ") << regionstring << endl;
    return 0;
  }
  
  do {
    // Skip lines which do not commence with a digit
    c=ifs.peek();
    if ( (c < '0') || (c > '9') ) {
      ifs.getline(charbuffer,BUFSIZE);
      continue;  
    }
    
    ifs.getline(charbuffer,BUFSIZE);
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
    cerr << "\nERROR\tTried to open file " << fname << " and failed" << endl;
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
	cerr << "\nERROR\tTried to open file " << fname << " and failed" << endl;
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

    cout << "Read " << filename ;

    ifs.open(filename.c_str(),ios::in);
    MaxProxyReg=count_ascii_columns(ifs);
    ifs.close();
    
    if (MaxProxyReg >= MAXPROXY) {
      cerr<< "\nERROR\t Number of proxies greater than MAXPROXY constant.\n";
      return 0;
    }
    if (MaxProxyReg == 0) {
      cerr<< "\nERROR\t Number of proxies cannot be zero.\n";
      return 0;
    }
    
    for (j=0; j<(unsigned int)MaxProxyReg; j++) RegSiteInd[j]=(int *)(malloc(numberOfRegions*sizeof(int)));

    ifs.open(filename.c_str(),ios::in);
    n=read_ascii_table(ifs,RegSiteInd);
    ifs.close();

    if (n<numberOfRegions)  { 
	cout << "\nERROR\t NumberOfRegions != rows\t" <<  n << endl;
	return 0;  
    }

    cout << "SUCCESS" << endl;
    return MaxProxyReg;
}


/**
  @deprecated: This function replaces the deprecated read_SiteRadfile()
*/

unsigned int read_region_eventradius(const std::string & filename, int** matrix_int) 
{

  std::ifstream ifs;
  unsigned int n;
  
  cout << "Reading file " << filename << " ... ";

  ifs.open(filename.c_str(),ios::in);
  n=read_ascii_table(ifs,matrix_int);
  ifs.close(); 

  cout << "SUCCESS" << endl;
  
  return n;
}


/**
   @param is: input stream to read from
   @param table_double: pointer to integer matrix
   @return: number of lines read
*/

unsigned int read_ascii_table(std::istream& is, double** table_double) 
{

  double dummy;
  std::string line;
  unsigned int i=0,j=0;
   
  if ( is.bad() ) {
	  cout << "ERROR in read_ascii_table. Input stream not ready\n";
      }


  if (table_double==NULL) {
      cout << "ERROR in read_ascii_table.  Matrix not allocated\n" ;
      return 0;
  }
  
  while( is.good() && getline(is,line) ) {
    if ( (line[0] < '0' || line[0] > '9') ) {
      // Skip non-number lines
      continue;
    }
    
    std::istringstream ss(line);
    
    while ( ss >> dummy ) table_double[j++][i]=dummy;
    i++;
    j=0;

  }
  
  return i;
}

/**
   @param is: input stream to read from
   @param table_int: pointer to integer matrix
   @return: number of lines read
*/

unsigned int read_ascii_table(std::istream& is, int** table_int) 
{

  int dummy;
  std::string line;
  unsigned int i=0,j=0;
   
  if ( is.bad() ) {
	  cout << "ERROR in read_ascii_table. Input stream not ready\n";
      }


  if (table_int==NULL || (*table_int)==NULL) {
      cout << "ERROR in read_ascii_table.  Matrix not allocated\n" ;
      return 0;
  }
  
  while( is.good() && getline(is,line) ) {
    if ( (line[0] < '0' || line[0] > '9') && (line[0]!='-') && line [0]!='.' && line[0]!='+'  ) {
      // Skip non-number lines
      continue;
    }
    
    std::istringstream ss(line);
    
    cout << dummy;
    while ( ss >> dummy ) table_int[j++][i]=dummy;
    i++;
    j=0;

  }
  
  return i;
}

/**
   @param is: input stream to read from
   @return: number of lines read
*/

unsigned int count_ascii_rows(std::istream& is) 
{
    
  std::string line;
  unsigned int n=0;
   

  if ( is.bad() ) {
	  cout << "ERROR in count_ascii_rows. Input stream not ready\n";
      }
  
  is.seekg(0);

  while( is.good() && getline(is,line) ) {
    if ( (line[0] < '0' || line[0] > '9') ) {
      // Skip non-number lines
	continue;
    }
    n++;
  }
  
  return n;
}

/**
   @param is: input stream to read from
   @return: number of columns in first numeric line read
*/

unsigned int count_ascii_columns(std::istream& is) 
{
    
    std::string line,word;
    unsigned int n=0;
  
    if ( is.bad() ) {
	  cout << "ERROR in count_ascii_columns. Input stream not ready\n";
    }
  
   // is.seekg(0);
  
    while( is.good() && getline(is,line) ) {
	
  if ( (line[0] < '0' || line[0] > '9') && (line[0]!='-') && line [0]!='.' && line[0]!='+'  ) {	    // Skip non-number lines
	    // Skip non-number lines
	    continue;
	  }
	
	  std::istringstream iss(line);

	  while ( iss.good() && getline(iss,word,' ') ) {
	    //cout << n << " '"  << word << "'\n" ;
	      if (word.length()>0) n++;
	  }
// TODO: why n-2? The last two columns give lat lon info (or similar)
	return n;
    }
    
  return 0;
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

    cerr << "Read " << filename << " ";
    
    ifs.open(filename.c_str(),ios::in);
    
    MaxEvent=count_ascii_columns(ifs)-2;
    numberOfSites=count_ascii_rows(ifs);

    ifs.close();

    cerr << numberOfSites << " sites x " << MaxEvent << " events\n!";

    EventTime= (double *)(malloc(numberOfSites*MaxEvent*sizeof(double)));
    EventSerMax = (double *)(malloc(numberOfSites*sizeof(double)));
    EventSerMin = (double *)(malloc(numberOfSites*sizeof(double)));
    
    ifstream ifs2;
    ifs2.open(filename.c_str(),ios::in);
   // Read to the end to see how many regions there are
    for (unsigned int i=0;  i<(unsigned int)numberOfSites; i++) {
	for (unsigned int j=0; j<(unsigned int)MaxEvent; j++) {
	    ifs2 >> fdummy;
	    *(EventTime+j+i*MaxEvent)=fdummy;
	    //cout <<i<<": "<< fdummy << "->" << *(EventTime+j+i*MaxEvent) <<endl;
	}
	ifs2 >> fdummy; EventSerMin[i]=fdummy;
	ifs2 >> fdummy; EventSerMax[i]=fdummy;
    }
    
    ifs2.close();
    cout << " OK" << endl;
    return numberOfSites;
}

// -------------------------------------------------------------------------------
//
// -------------------------------------------------------------------------------
vector<PopulatedRegion>::size_type  RegionProperties(vector<PopulatedRegion> region) 
{
  static const unsigned int BUFSIZE=1024;
  static char charbuffer[BUFSIZE];
    ifstream ifs;
    unsigned int i=0;
    char c;
    //Input input;
    
  //numberOfRegions=input.getRegionNumber();
  numberOfRegions=RegionNumber();
  if (numberOfRegions < 1 ) return 0;

  regions = new PopulatedRegion[numberOfRegions];
  
  region.clear();

  ifs.open(regionstring.c_str(),ios::in);
  while (ifs.good() && !ifs.eof() && i<numberOfRegions) {
 
       c=ifs.peek();
      if ( (c < '0') || (c > '9') ) {
	  ifs.getline(charbuffer,BUFSIZE);
	  continue;
      }
      /* Later to be replaced */
      regions[i] = PopulatedRegion(ifs);
      regions[i].Index(i);
      
      region.push_back(PopulatedRegion(regions[i]));
      // todo: add index generation
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

  static const unsigned int BUFSIZE=1024;
  static char charbuffer[BUFSIZE];
  char c;

  ifstream ifs;

  unsigned int selfid,numneigh;
  int neighid;
  float neigh_boundary,neigh_distance;

  cout << "Reading neighbor info from file " << regionstring ;
  ifs.open(regionstring.c_str(),ios::in);
 
  if (ifs.bad()) {
    cout << "\nERROR\t[Input::read_neighbours()]\t Tried to open file " << regionstring << " and failed" << endl;
    return 0;  // The file does not exist
  }

  unsigned int i=0;

  /** find a mapping from Id to index of all regions */
  map<unsigned int,unsigned int> idmap;
 // TODO: for (i=0; i<numberOfRegions; i++) idmap[regions[i].Id()]=i;
 
  while ( i<numberOfRegions && !ifs.eof() ) {
    c=ifs.peek();
    if ( (c < '0') || (c > '9') ) {
	  ifs.getline(charbuffer,BUFSIZE);
	  continue;  
    }

    ifs >> selfid;
  
    for (unsigned int j=0; j<5; j++) ifs >> numneigh;
    for (unsigned int j=0; j<numneigh; j++) {

      ifs >> charbuffer;
      sscanf(charbuffer,"%d:%f:%d",&neighid,&neigh_boundary,&neigh_distance);
     
      if ( neighid>=0 ) {
        unsigned int in=neighid;//idmap[neighid];
        // rpelace neighid with in in this block
        regions[i].AddNeighbour(&regions[in],neigh_boundary,1);
        if (in < i) regions[in].AddNeighbour(&regions[i],
						     neigh_boundary,1);
    }				     
	//if (i>680) printf("read %i %d %d %d %f\n",i,selfid,numneigh,neighid,neigh_boundary);
    
    }
    i++;
    // if (i>680 || i<10) printf("read %d %d %d \n",i,selfid,numneigh);

  }
  ifs.close();

  std::cout << " OK" << std::endl;;
  return 1;
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
  //cout << "  Mapping data from \t" << mappingstring << endl;
  
  for (unsigned int i=0;i<LengthOfClimUpdateTimes; i++)
    cout << "  Climate data at "
	 << ClimUpdateTimes[i] << " from \t" << climatestring << endl;

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
    //watchreg[0]='\0';
    //if(ins[i]<1) ins[i]=1;
    //sprintf(watchreg,"%4d",ins[i]);
    //sprintf(watchreg,"%03d",i);
    //watchfilename.append(watchreg);
    //watchfilename.append(watchstring);

    sprintf(watchreg,"pop_%04d.tsv\0",ins[i]);
    watchfilename.append(watchreg);

    cout<<" writing population "<<ins[i]<<" to "<<watchreg<<endl;
    if (!(watchfile[i] = fopen(watchfilename.c_str(),"w"))) {
      cout << "\nERROR\tCould not open output file " << watchfilename << " for writing\n";
      exit(0);
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
