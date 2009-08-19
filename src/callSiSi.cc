// C++ Code automatically generated by 'XSiSi 2.0'
// Emitted at Thu May 19 22:53:41 CEST 2005

// Please read the documentation!

#include "callSiSi.hh"

// Declaration of parameters and variables of simulation:
  double Time;
  double TimeStart;
  double TimeEnd;
  double TimeStep;
  double OutputStep;
  long RandomInit;
  long LocalSpread;
  long RemoteSpread;
  double CultIndex;
  double Space2Time;
  long MaxCivNum;
  long DataActive;
  double* err_data_weights;
  unsigned int LengthOferr_data_weights;
  long RunVarInd;
  long VarActive;
  long NumDice;
  long MonteCarlo;
  long VarOutputStep;
  String varresfile;
  double storetim;
  double RelChange;
  long NumMethod;
  double InitTechnology;
  double InitNdomast;
  double InitQfarm;
  double InitDensity;
  double InitGerms;
  double deltan;
  double deltaq;
  double deltar;
  double regenerate;
  double spreadm;
  double ndommaxvar;
  double gammad;
  double gammam;
  double NPPCROP;
  double deltat;
  double spreadv;
  double overexp;
  double kappa;
  double gdd_opt;
  double omega;
  double gammab;
  double ndommaxmean;
  double* ndommaxcont;
  unsigned int LengthOfndommaxcont;
  double LiterateTechnology;
  double KnowledgeLoss;
  double** data_agri_start_old;
  unsigned int RowsOfdata_agri_start_old;
  unsigned int ColumnsOfdata_agri_start_old;
  String*      HeadOfdata_agri_start_old;
  double** data_agri_start;
  unsigned int RowsOfdata_agri_start;
  unsigned int ColumnsOfdata_agri_start;
  String*      HeadOfdata_agri_start;
  double flucampl;
  double flucperiod;
  long CoastRegNo;
  String datapath;
  String regiondata;
  String mappingdata;
  String resultfilename;
  String watchstring;
  String spreadfile;
  long* ins;
  unsigned int LengthOfins;
  String climatefile;
  long* ClimUpdateTimes;
  unsigned int LengthOfClimUpdateTimes;
  String eventfile;
  String SiteRegfile;
  long SaharaDesert;
  long LGMHoloTrans;
  double* IceExtent;
  unsigned int LengthOfIceExtent;
  double* IceRed;
  unsigned int LengthOfIceRed;

// Declaration of additional output variables:

  double *VAR_VAL[199];
  char VAR_NAMES[199][22];
  int num_variat_parser;

// The compilers need the delcaration of static variables:
  String       SiSi::SimulationName;   // Full name of the simulation.
  String       SiSi::ModelName;        // Full name of the model.
  String       SiSi::ModelPath;        // Path of the executable model.
  TwoWayList*  SiSi::IncludeFiles;     // Names of all included files.
  TwoWayList*  SiSi::OutputVariables;  // Includes all output variables.
  TwoWayList*  SiSi::VariationVariables;  // Includes all output variables.
  LogFile      SiSi::logFile;          // The file for Job controlling system.
  ResultWriter SiSi::resultWriter;     // Declaration of ResultWriter.
  String       SiSi::resultFilename;   // Name of the result file.
  String       SiSi::simulationPath;   // Path of the simulation file.

/////////////////////////////////////////////////////////////////////////////
//
// public methods:
//
/////////////////////////////////////////////////////////////////////////////

bool SiSi::parseSimulation(int argc, char* argv[])
{
  if (argc == 1) {                   // --- no file spcified ---
    cerr << "*** Please specify an input file!\n"
         << "*** Sorry, no output :-(\n";
    return false;
  }
  return parseSimulation(argv[1], argv[0]);
}
bool SiSi::parseSimulation(const char* simulationFile, const char* program)
{
  TwoWayList list;                   // List of parameters and variables.
  TwoWayList tempList;               // List of all output variables in list.
  TwoWayListElement* el;             // Pointer to TwoWayListElement.
  //Parameter* par;                    // Pointer to Parameter.
  ResultElement* resultElement;      // Pointer to ResultElement.
  SiSiParser parser;                 // The SiSi parser.
  String message;                    // For messages.
  bool result = true;                // Result of function.

  String pathWithoutSuffix
    = FilenameHandling::getPathWithoutSuffix(simulationFile);
  simulationPath = FilenameHandling::getName(simulationFile);
  resultFilename = pathWithoutSuffix + ".res";
  resultWriter.setFilename(resultFilename);
  MessageHandler::setBaseFilename(pathWithoutSuffix);
  logFile.initialize(pathWithoutSuffix, program); // Initialize log file

  // Parse simulation parameters:
  message = parser.parseSimulation(list, simulationFile);
  if( message.compareTo("OK") != 0 ) {           // Does an error occur?.
    MessageHandler::error(message);
    MessageHandler::error("Sorry, no output :-(");
    abort();
    return false;                                // An error occurs! :-(
  }

  ///////////////////////////////////////////////////////////////////////////
  //
  // Gets all parameters:
  //
  el = list.getElement("IncludeFiles");
  if( el && el->isFromClass("ListParameter") ) {
    if( ((ListParameter*) el)->getTypeOfElements() == ParameterType::STRING )
      IncludeFiles = ((ListParameter*) el)->getValue();
    else {
      MessageHandler::error("The list \"IncludeFiles\" doesn't contain strings!");
      result = false;
    }
  }
  else {
    IncludeFiles = new TwoWayList(); 
    MessageHandler::error("'list IncludeFiles' not found!?!");
    result = false;
  }

  el = list.getElement("OutputVariables");
  if( el && el->isFromClass("ListParameter") ) {
    if( ((ListParameter*) el)->getTypeOfElements() == ParameterType::PARAMETER )
      OutputVariables = ((ListParameter*) el)->getValue();
    else {
      MessageHandler::error("The list \"OutputVariables\" doesn't contain parameters!");
      result = false;
    }
  }
  else {
    OutputVariables = new TwoWayList(); 
    MessageHandler::error("'list OutputVariables' not found!?!");
    result = false;
  }

  el = list.getElement("VariationVariables");
  if( el && el->isFromClass("ListParameter") ) {
    if( ((ListParameter*) el)->getTypeOfElements() == ParameterType::PARAMETER )
      VariationVariables = ((ListParameter*) el)->getValue();
    else {
      MessageHandler::error("The list \"VariationVariables\" doesn't contain parameters!");
      result = false;
    }
  }
  else {
    VariationVariables = new TwoWayList(); 
    MessageHandler::error("'list VariationVariables' not found!?!");
    result = false;
  }

  el = list.getElement("err_data_weights");
  if( el && el->isFromClass("ArrayParameter") ) {
    message = ((ArrayParameter*) el)->getArray(err_data_weights);
    LengthOferr_data_weights = ((ArrayParameter*) el)->getNumberOfRows();
    if( message.compareTo("OK") != 0 )
      MessageHandler::error(message);
    if( err_data_weights == NULL )
      result = false;
  }
  else {
    MessageHandler::error("'array err_data_weights' not found!?!");
    result = false;
  }

  el = list.getElement("ndommaxcont");
  if( el && el->isFromClass("ArrayParameter") ) {
    message = ((ArrayParameter*) el)->getArray(ndommaxcont);
    LengthOfndommaxcont = ((ArrayParameter*) el)->getNumberOfRows();
    if( message.compareTo("OK") != 0 )
      MessageHandler::error(message);
    if( ndommaxcont == NULL )
      result = false;
  }
  else {
    MessageHandler::error("'array ndommaxcont' not found!?!");
    result = false;
  }

  el = list.getElement("data_agri_start_old");
  if( el && el->isFromClass("ArrayParameter") ) {
    message = ((ArrayParameter*) el)->getArray(data_agri_start_old);
    HeadOfdata_agri_start_old    = ((ArrayParameter*) el)->getHead();
    RowsOfdata_agri_start_old    = ((ArrayParameter*) el)->getNumberOfRows();
    ColumnsOfdata_agri_start_old = ((ArrayParameter*) el)->getNumberOfColumns();
    if( message.compareTo("OK") != 0 )
      MessageHandler::error(message);
    if( data_agri_start_old == NULL )
      result = false;
  }
  else {
    MessageHandler::error("'array data_agri_start_old' not found!?!");
    result = false;
  }

  el = list.getElement("data_agri_start");
  if( el && el->isFromClass("ArrayParameter") ) {
    message = ((ArrayParameter*) el)->getArray(data_agri_start);
    HeadOfdata_agri_start    = ((ArrayParameter*) el)->getHead();
    RowsOfdata_agri_start    = ((ArrayParameter*) el)->getNumberOfRows();
    ColumnsOfdata_agri_start = ((ArrayParameter*) el)->getNumberOfColumns();
    if( message.compareTo("OK") != 0 )
      MessageHandler::error(message);
    if( data_agri_start == NULL )
      result = false;
  }
  else {
    MessageHandler::error("'array data_agri_start' not found!?!");
    result = false;
  }

  el = list.getElement("ins");
  if( el && el->isFromClass("ArrayParameter") ) {
    message = ((ArrayParameter*) el)->getArray(ins);
    LengthOfins = ((ArrayParameter*) el)->getNumberOfRows();
    if( message.compareTo("OK") != 0 )
      MessageHandler::error(message);
    if( ins == NULL )
      result = false;
  }
  else {
    MessageHandler::error("'array ins' not found!?!");
    result = false;
  }

  el = list.getElement("ClimUpdateTimes");
  if( el && el->isFromClass("ArrayParameter") ) {
    message = ((ArrayParameter*) el)->getArray(ClimUpdateTimes);
    LengthOfClimUpdateTimes = ((ArrayParameter*) el)->getNumberOfRows();
    if( message.compareTo("OK") != 0 )
      MessageHandler::error(message);
    if( ClimUpdateTimes == NULL )
      result = false;
  }
  else {
    MessageHandler::error("'array ClimUpdateTimes' not found!?!");
    result = false;
  }

  el = list.getElement("IceExtent");
  if( el && el->isFromClass("ArrayParameter") ) {
    message = ((ArrayParameter*) el)->getArray(IceExtent);
    LengthOfIceExtent = ((ArrayParameter*) el)->getNumberOfRows();
    if( message.compareTo("OK") != 0 )
      MessageHandler::error(message);
    if( IceExtent == NULL )
      result = false;
  }
  else {
    MessageHandler::error("'array IceExtent' not found!?!");
    result = false;
  }

  el = list.getElement("IceRed");
  if( el && el->isFromClass("ArrayParameter") ) {
    message = ((ArrayParameter*) el)->getArray(IceRed);
    LengthOfIceRed = ((ArrayParameter*) el)->getNumberOfRows();
    if( message.compareTo("OK") != 0 )
      MessageHandler::error(message);
    if( IceRed == NULL )
      result = false;
  }
  else {
    MessageHandler::error("'array IceRed' not found!?!");
    result = false;
  }

// lists of doubles, strings and longs ...
struct ParDoubleElem{ char parname[22]; double *paraddr; char test; };
struct ParStringElem{ char parname[22]; String *paraddr; char test; };
struct ParLongElem{ char parname[22]; long *paraddr; char test; };

int i;
String errorstr;
struct ParDoubleElem parDlist[36]={{"Time",&Time},{"TimeStart",&TimeStart},{"TimeEnd",&TimeEnd},{"TimeStep",&TimeStep},{"OutputStep",&OutputStep},{"CultIndex",&CultIndex},{"Space2Time",&Space2Time},{"storetim",&storetim},{"RelChange",&RelChange},{"InitTechnology",&InitTechnology},{"InitNdomast",&InitNdomast},{"InitQfarm",&InitQfarm},{"InitDensity",&InitDensity},{"InitGerms",&InitGerms},{"deltan",&deltan},{"deltaq",&deltaq},{"deltar",&deltar},{"regenerate",&regenerate},{"spreadm",&spreadm},{"ndommaxvar",&ndommaxvar},{"gammad",&gammad},{"gammam",&gammam},{"NPPCROP",&NPPCROP},{"deltat",&deltat},{"spreadv",&spreadv},{"overexp",&overexp},{"kappa",&kappa},{"gdd_opt",&gdd_opt},{"omega",&omega},{"gammab",&gammab},{"ndommaxmean",&ndommaxmean},{"LiterateTechnology",&LiterateTechnology},{"KnowledgeLoss",&KnowledgeLoss},{"flucampl",&flucampl},{"flucperiod",&flucperiod},{"END"}};
struct ParLongElem parLlist[15]={{"RandomInit",&RandomInit},{"LocalSpread",&LocalSpread},{"RemoteSpread",&RemoteSpread},{"MaxCivNum",&MaxCivNum},{"DataActive",&DataActive},{"RunVarInd",&RunVarInd},{"VarActive",&VarActive},{"NumDice",&NumDice},{"MonteCarlo",&MonteCarlo},{"VarOutputStep",&VarOutputStep},{"NumMethod",&NumMethod},{"CoastRegNo",&CoastRegNo},{"SaharaDesert",&SaharaDesert},{"LGMHoloTrans",&LGMHoloTrans},{"END"}};
struct ParStringElem parSlist[14]={{"SimulationName",&SimulationName},{"ModelName",&ModelName},{"ModelPath",&ModelPath},{"varresfile",&varresfile},{"datapath",&datapath},{"regiondata",&regiondata},{"mappingdata",&mappingdata},{"resultfilename",&resultfilename},{"watchstring",&watchstring},{"spreadfile",&spreadfile},{"climatefile",&climatefile},{"eventfile",&eventfile},{"SiteRegfile",&SiteRegfile},{"END"}};

 /////////////////////////////////////////////////
 // Input Loop over all pars of same type
 for(i=0;strstr(parDlist[i].parname,"END") == NULL ;i++)
  {
  el = list.getElement(parDlist[i].parname);
  if( el && el->isFromClass("FloatParameter") )
    *parDlist[i].paraddr= ((FloatParameter*) el)->getValue();
  else
    {
    strcpy(errorstr,parDlist[i].parname);
    strcat(errorstr," not found!!!");
    MessageHandler::error(errorstr); 
    result = false;
    }
  }

 /////////////////////////////////////////////////
 // Input Loop over all pars of same type
 for(i=0;strstr(parSlist[i].parname,"END") == NULL ;i++)
  {
  el = list.getElement(parSlist[i].parname);
  if( el && el->isFromClass("StringParameter") )
    *parSlist[i].paraddr= ((StringParameter*) el)->getValue();
  else
    {
    strcpy(errorstr,parSlist[i].parname);
    strcat(errorstr," not found!!!");
    MessageHandler::error(errorstr); 
    result = false;
    }
  }

 /////////////////////////////////////////////////
 // Input Loop over all pars of same type
 for(i=0;strstr(parLlist[i].parname,"END") == NULL ;i++)
  {
  el = list.getElement(parLlist[i].parname);
  if( el && el->isFromClass("IntParameter") )
    *parLlist[i].paraddr= ((IntParameter*) el)->getValue();
  else
    {
    strcpy(errorstr,parLlist[i].parname);
    strcat(errorstr," not found!!!");
    MessageHandler::error(errorstr); 
    result = false;
    }
  }
struct ParDoubleElem parVlist[1]={{"END"}};

 /////////////////////////////////////////////////
 // Input Loop over all pars of same type
 for(i=0;strstr(parVlist[i].parname,"END") == NULL ;i++)
  {
  strcpy(VAR_NAMES[i],parVlist[i].parname);
  VAR_VAL[i] = parVlist[i].paraddr;
  }
  num_variat_parser = 0;
  ///////////////////////////////////////////////////////////////////////////
  //
  // Puts active output variables to result list and deletes tempList:
  //
  while( (resultElement=(ResultElement*) tempList.removeFirstElement())
	 != NULL ) {
    el = OutputVariables->getElement( resultElement->getName() );
    if( el && el->isFromClass("ResultParameter") ) {
      if( ((ResultParameter*) el)->isActive() ) {
	resultElement->setPrecision( ((ResultParameter*) el)->getPrecision() );
	resultWriter.appendElement(resultElement);
      }
      else
	delete resultElement; // Not needed anymore.
    }
  }

  ///////////////////////////////////////////////////////////////////////////
  //
  // Appends additional output variables to result list:
  //

  ///////////////////////////////////////////////////////////////////////////
  //
  // Deletes parameter list:
  //
  while( (el=(Parameter*) list.removeFirstElement()) != NULL )
    delete el;

  ///////////////////////////////////////////////////////////////////////////
  //
  // Does an error occur?
  //
  if( !result ) {
    cerr << "*** Something is wrong in the simulation files!\n"
         << "*** Please read the file '" << pathWithoutSuffix + ".err"
         << "' for details!\n"
         << "*** Sorry, no output :-(\n";
    abort();
  }
  resultWriter.setTimeStep(OutputStep);    // Set time step of output.
  Random::initialize(RandomInit);          // Initialize random generator.
  return result;
}

/////////////////////////////////////////////////////////////////////////////
//
// private methods:
//
/////////////////////////////////////////////////////////////////////////////

void SiSi::abort() {
  SiSi::resultWriter.close();              // Closes result file.
  SiSi::logFile.abort();                   // Toggle status to aborted.
  MessageHandler::finalize();              // Closes opened message files.
}
void SiSi::finalize() {
  SiSi::resultWriter.close();              // Closes result file.
  SiSi::logFile.finish();                  // Toggle status to finished.
  MessageHandler::finalize();              // Closes opened message files.
}

