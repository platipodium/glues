/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: EmitCxxCode.cc,v $	
//
//  Project      SiSi
//               Wissenschaftliches Zentrum fuer
//		 Umweltsystemforschung Kassel
//               Germany
//
//               Umweltforschungszentrum Leipzig
//
//  Author       Kai Reinhard (reinhard@usf.uni-kassel.de)
//               Schoene Aussicht 39, 34317 Habichtswald, Germany
//               email: reinhard@usf.uni-kassel.de
//               URL  : http://www.usf.uni-kassel.de/~reinhard/
//
//  Copyright (C) 1997, 1998 by Kai Reinhard
//
//   This program is free software; you can redistribute it and/or modify
//   it under the terms of the GNU General Public License as published by
//   the Free Software Foundation; either version 2 of the License, or
//   (at your option) any later version.
//
//   This program is distributed in the hope that it will be useful,
//   but WITHOUT ANY WARRANTY; without even the implied warranty of
//   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//   GNU General Public License for more details.
//
//   You should have received a copy of the GNU General Public License
//   along with this program; if not, write to the Free Software
//   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
//
//  $Revision: 1.2 $
//  $Date: 1998/02/27 09:04:42 $
//
//  Description
//   This class generates the C++ code for using SiSi-parser in own
//   simulations. All variables declared as global in the header file.
//   You have to include the emitted header file in every source file
//   using these variables and to call SiSi::parseSimulation(filename) once
//   (e.g. in function main).
//
//  $Log: EmitCxxCode.cc,v $
//  Revision 1.2  1998/02/27 09:04:42  reinhard
//  Borland doesn't aim redeclaration of function parameters ...
//
//  Revision 1.1  1998/02/25 16:37:12  reinhard
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////

#include "cppinc.h"
#include "Version.hh"
#include "datastructures/String.hh"
#include "common/FilenameHandling.hh"
#include "development/EmitCxxCode.hh"
#include "iostreams/SiSiParser.hh"

String EmitCxxCode::_classNameOfString = "String";
bool   EmitCxxCode::_unix = true;

String EmitCxxCode::emit(const char* baseFilename, const char* simulation,
			 bool modul) {
  TwoWayList list;
  SiSiParser parser;
  String message = parser.parseSimulation(list, simulation);
  if( message.compareTo("OK") != 0 )
    return message;
  message = _emitHeaderFile(list, (String) baseFilename + ".hh", modul);
  if( message.compareTo("OK") != 0 )
    return message;
  if( modul )
    _emitSourceFile(list, (String) baseFilename + ".cc");
  return (String) "OK";
}

/** What is the output format? If the given bool isn't true, than
 * the output will consider the 8 dot 3 filename convention
 * (DOS-Format) and String class will be renamed to SiSi_String. */
void EmitCxxCode::setOutputFormat(bool unix) {
  _unix = unix;
  if( _unix )
    _classNameOfString = "String";
  else
    _classNameOfString = "SiSi_String";
}

/** Emits informations about the generating program. */
void EmitCxxCode::_emitInformation(ostream& ost) {
  ost << "// C++ Code automatically generated by '" << Version::Program
      << "'\n\n"
      << "//   Wissenschaftliches Zentrum fuer\n"
      << "//   Umweltsystemforschung Kassel\n//\n"
      << "//   Germany\n\n"
      << "// Please read the documentation!\n\n";
}

/** Emits the header file depending on the switch modul. */
String EmitCxxCode::_emitHeaderFile(TwoWayList& list, const char* filename,
				    bool modul) {
  String file = FilenameHandling::getName(filename);
  String define = file.replace('.', '_');
  ofstream out(filename);
  if( !out.good() )
    return (String) "Error while opening file \"" + filename +
      "\" as writeable (" + strerror(errno) + ")!";
  _emitInformation(out);
  out << "#ifndef _" << define << "_\n#define _" << define << "_"
      << "\n\n#include \"";
  if( _unix )
    out << "iostreams/SiSiParser.hh";
  else
    out << "io/sisipars.hh";
  out << "\"     "
      << "// Header-File of parser.\n"
      << "#include \"";
  if( _unix )
    out << "development/LogFile.hh";
  else
    out << "develop/logfile.hh";
  out << "\"      "
      << "// Header-File for writing log files.\n\n";
  if( modul )   // Modul selected.
    _emitVariables(out, list, "extern ");
  else
    _emitVariables(out, list);
  
  out << "class SiSi\n"
      << "{\n"
      << "public:\n"
      << "  static bool parseSimulation(int argc, char* argv[]);\n"
      << "  static bool parseSimulation(const char* simulationFile, "
      << "const char* program);\n"
      << "  static LogFile logFile;      "
      << "// The log file for Job controlling system.\n"
      << "private:\n"
      << "  static ostream* _ost;                    // Output stream.\n"
      << "  static void _printError(" << _classNameOfString << " message); "
      << "// For printing errors.\n"
      << "};\n\n";
  
  if( !modul )   // Header selected.
    _emitClass(out, list);
  
  out << "#endif // _" << define << "_\n";
  if( !out.good() )
    return (String) "Error while writing to file \"" + filename +
      "\" (" + strerror(errno) + ")!";
  out.close();
  return (String) "OK";
}

/** Emits the source file. */
String EmitCxxCode::_emitSourceFile(TwoWayList& list, const char* filename) {
  ofstream out(filename);
  if( !out.good() )
    return (String) "Error while opening file \"" + filename +
      "\" as writeable (" + strerror(errno) + ")!";
  _emitInformation(out);
  out << "#include \""
      << FilenameHandling::getNameWithoutSuffix(filename) << ".hh\"\n\n";
  _emitVariables(out, list);
  _emitClass(out, list);
  if( !out.good() )
    return (String) "Error while writing to file \"" + filename +
      "\" (" + strerror(errno) + ")!";
  out.close();
  return (String) "OK";
}

/** Emits the variables with the given prefix */
void EmitCxxCode::_emitVariables(ostream& ost, TwoWayList& list,
				 const char* prefix) {
  Parameter* el = NULL;
  ost << "// Declaration of parameters of simulation:\n";
  el = (Parameter*) list.resetIterator();
  while( el ) {
    if( el->getType() == ParameterType::INT ) {
      ost << "  " << prefix << "int " << el->getName()
	  << ";\n";
    }
    else if( el->getType() == ParameterType::FLOAT ) {
      ost << "  " << prefix << "double " << el->getName()
	  << ";\n";
    }
    else if( el->getType() == ParameterType::CHAR ) {
      ost << "  " << prefix << "char " << el->getName()
	  << ";\n";
    }
    else if( el->getType() == ParameterType::STRING ) {
      ost << "  " << prefix << _classNameOfString << " " << el->getName()
	  << ";\n";
    }
    else if( el->getType() == ParameterType::BOOLEAN ) {
      ost << "  " << prefix << "bool " << el->getName()
	  << ";\n";
    }
    else if( el->getType() == ParameterType::TABLE ) {
      ost << "  " << prefix << "Table* " << el->getName() << ";\n";
    }
    else if( el->getType() == ParameterType::ARRAY ) {
      if( ((ArrayParameter*) el)->getTypeOfArray()==ParameterType::INT ) {
	ost << "  " << prefix << "long** " << el->getName() << ";\n"
	    << "  " << prefix << "unsigned int RowsOf" << el->getName()
	    << ";\n"
	    << "  " << prefix << "unsigned int ColumnsOf" << el->getName()
	    << ";\n";
      }
      else {
	ost << "  " << prefix << "double** " << el->getName() << ";\n"
	    << "  " << prefix << "unsigned int RowsOf" << el->getName()
	    << ";\n"
	    << "  " << prefix << "unsigned int ColumnsOf" << el->getName()
	    << ";\n";
      }
    }
    else if( el->getType() == ParameterType::LIST ) {
      ost << "  " << prefix << "TwoWayList " << el->getName() << ";\n";
    }
    el = (Parameter*) list.nextElement();
  }
  ost << "\n// Declaration of reserved SiSi parameters:\n"
      << "  " << prefix << _classNameOfString << " __ResultFile__;       "
      << "// Name of the result file.\n"
      << "  " << prefix << _classNameOfString << " __SimulationPath__;   "
      << "// Path of the simulation file.\n"
      << "  " << prefix << _classNameOfString << " __ErrorFilename__;    "
      << "// Name of the file for error messages.\n\n";
}

/** Emits the realization of the class. */
void EmitCxxCode::_emitClass(ostream& ost, TwoWayList& list) {
  Parameter* el = NULL;
  ost << "// The compilers need the delcaration of static variables:\n"
      << "  LogFile SiSi::logFile;       "
      << "// The log file for Job controlling system.\n\n"
      << "///////////////////////////////////////"
      << "//////////////////////////////////////\n"
      << "//\n"
      << "// public methods:\n"
      << "//\n"
      << "///////////////////////////////////////"
      << "//////////////////////////////////////\n\n"
      << "bool SiSi::parseSimulation(int argc, char* argv[])\n"
      << "{\n"
      << "  if (argc == 1) {             // --- no file spcified ---\n"
      << "    cerr << \"*** Please specify an input file!\\n\"\n"
      << "         << \"*** Sorry, no output :-(\\n\";\n"
      << "    return false;\n"
      << "  }\n"
      << "  return parseSimulation(argv[1], argv[0]);\n"
      << "}\n"
      << "bool SiSi::parseSimulation(const char* simulationFile, "
      << "const char* program)\n"
      << "{\n"
      << "  TwoWayList list;             // List of parameters.\n"
      << "  Parameter* el;               // Pointer to parameter.\n"
      << "  SiSiParser parser;           // The SiSi parser.\n"
      << "  " << _classNameOfString << " message;              "
      << "// For messages.\n"
      << "  bool result = true;          // Result of function.\n\n"
      << "  " << _classNameOfString << " fileWithoutSuffix\n"
      << "    = FilenameHandling::getNameWithoutSuffix("
      << "simulationFile);\n"
      << "  __SimulationPath__\n"
      << "    = FilenameHandling::getName(simulationFile);\n"
      << "  __ResultFile__     = fileWithoutSuffix + \".res\";\n"
      << "  __ErrorFilename__  = fileWithoutSuffix + \".err\";\n"
      << "  logFile.initialize(simulationFile, program); "
      << "// Initialize log file\n\n"
      << "  // Parse simulation parameters:\n"
      << "  message = parser.parseSimulation(list, simulationFile);\n"
      << "  if( message.compareTo(\"OK\") != 0 ) {           "
      << "// Does an error occur?.\n"
      << "    _printError(message);\n"
      << "    _printError(\"Sorry, no output :-(\");\n"
      << "    logFile.abort();\n"
      << "    return false;                                "
      << "// An error occurs! :-(\n"
      << "  }\n\n";
  el = (Parameter*) list.resetIterator();
  while( el ) {
    if( el->getType() == ParameterType::INT ||
	el->getType() == ParameterType::FLOAT ||
	el->getType() == ParameterType::CHAR ||
	el->getType() == ParameterType::STRING ||
	el->getType() == ParameterType::BOOLEAN ||
	el->getType() == ParameterType::TABLE ||
	el->getType() == ParameterType::ARRAY ||
	el->getType() == ParameterType::LIST ) {
      ost << "  el = (Parameter*) list.getElement(\"" << el->getName()
	  << "\");\n"
	  << "  if( el && el->getType() == ParameterType::";
      if( el->getType() == ParameterType::INT )
	ost << "INT )\n    " << el->getName()
	    << " = ((IntParameter*) el)->getValue();\n";
      else if( el->getType() == ParameterType::FLOAT )
	ost << "FLOAT )\n    " << el->getName()
	    << " = ((FloatParameter*) el)->getValue();\n";
      else if( el->getType() == ParameterType::CHAR )
	ost << "CHAR )\n    " << el->getName()
	    << " = ((CharParameter*) el)->getValue();\n";
      else if( el->getType() == ParameterType::STRING )
	ost << "STRING )\n    " << el->getName()
	    << " = ((StringParameter*) el)->getValue();\n";
      else if( el->getType() == ParameterType::BOOLEAN )
	ost << "BOOLEAN )\n    " << el->getName()
	    << " = ((BooleanParameter*) el)->getValue();\n";
      else if( el->getType() == ParameterType::TABLE )
	ost << "TABLE )\n    " << el->getName()
	    << " = ((TableParameter*) el)->getValue();\n";
      else if( el->getType() == ParameterType::ARRAY ) {
	ost << "ARRAY ) {\n    message = ((ArrayParameter*) el)->get";
	if( ((ArrayParameter*) el)->getTypeOfArray()==ParameterType::INT )
	  ost << "IntArray(";
	else
	  ost << "FloatArray(";
	ost << el->getName() << ");\n"
	    << "    RowsOf" << el->getName()
	    << " = ((ArrayParameter*) el)->getNumberOfRows();\n"
	    << "    ColumnsOf" << el->getName()
	    << " = ((ArrayParameter*) el)->getNumberOfColumns();\n"
	    << "    if( message.compareTo(\"OK\") != 0 )\n"
	    << "      _printError(message);\n"
	    << "    if( " << el->getName() << " == NULL )\n"
	    << "      result = false;\n  }\n";
      }
      else if( el->getType() == ParameterType::LIST )
	ost << "LIST )\n    " << el->getName()
	    << " = ((ListParameter*) el)->getValue();\n";
      else {
	cerr << "*** Internal Error in '" << __FILE__ << "', line "
	     << __LINE__ << ", $Revision: 1.2 $ ***\n";
      }
      if( el->getType() == ParameterType::ARRAY ) {
	;
      }
      ost << "  else {\n"
	  << "    _printError(\"'"
	  << ParameterType::getTypeAsString(el->getType()) << " "
	  << el->getName()
	  << "' not found!!!\");\n"
	  << "    result = false;"
	  << "            // Arrgh, Name of variable doesn't exists :-(\n"
	  << "  }\n\n";
    }
    el = (Parameter*) list.nextElement();
  }
  ost << "  if( !result ) {\n"
      << "    cerr << \"*** Something is wrong in the simulation "
      << "files!\\n\"\n"
      << "         << \"*** Please read the file '\" << __ErrorFilename__\n"
      << "         << \"' for details!\\n\"\n"
      << "         << \"*** Sorry, no output :-(\\n\";\n"
      << "    logFile.abort();\n"
      << "  }\n"
      << "  return result;\n}\n\n"
      << "///////////////////////////////////////"
      << "//////////////////////////////////////\n"
      << "//\n"
      << "// private methods:\n"
      << "//\n"
      << "///////////////////////////////////////"
      << "//////////////////////////////////////\n\n"
      << "void SiSi::_printError(" << _classNameOfString << " message)\n"
      << "{\n"
      << "  if( !_ost ) {                             "
      << "// _ost stream opened?\n"
      << "    _ost = new ofstream(__ErrorFilename__); // Open error file.\n"
      << "    if( !_ost )\n"
      << "      _ost = &cerr;                         // Open failed.\n"
      << "    else {                                  // Print header:\n"
      << "      *_ost << \"# Error messages for simulation '\" "
      << "<< __SimulationPath__\n"
      << "            << \"'\\n# calling model '\" << ModelPath << "
      << "\"'\\n\\n\";\n"
      << "      if( !_ost->good() )                   // Printing failed.\n"
      << "        _ost = &cerr;\n"
      << "    }\n"
      << "  }\n"
      << "  *_ost << \"*** \" << message << endl;\n"
      << "  if( _ost != &cerr )                       "
      << "// Additional to cerr:\n"
      << "    cerr << \"*** \" << message << endl;\n"
      << "}\n\n"
      << "ostream* SiSi::_ost = NULL;\n\n";
}