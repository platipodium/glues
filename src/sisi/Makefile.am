subdirs=control src include lib


# Target Operating System
# Change this according to your needs
# Supported values:
#	cygwin
#	cygwin32
#	linux
#	linux-gnu
#	solaris2.4
#	solaris2.5
#	SunOS5
#
OSTYPE = darwin-x64

include ./VERSION

include ./control/$(OSTYPE).ctl

APPNAME     = $(PRG)$(VERSION)
PRGNAME     = $(PRG)

# Current directory (under which the sisi distribution lies):
SISIPATH   = `pwd`

SRCDIR      = src

LIBOBJECTS  =	$(SRCDIR)/Version.o \
		$(SRCDIR)/platform.o \
		$(SRCDIR)/common/date.o \
		$(SRCDIR)/datastructures/Parameter.o \
		$(SRCDIR)/datastructures/ParameterType.o \
		$(SRCDIR)/datastructures/String.o \
		$(SRCDIR)/development/MessageHandler.o \
		$(SRCDIR)/development/ResultElement.o \
		$(SRCDIR)/development/ResultReader.o \
		$(SRCDIR)/development/ResultWriter.o \
		$(SRCDIR)/iostreams/FileParser.o \
		$(SRCDIR)/iostreams/SiSiParser.o \
		$(SRCDIR)/math/Random.o

# Supporting defines:
#  -D__STRING_DESTRUCTOR_DEBUG__ for debugging String destructors.
#  -D__DESTRUCTOR_DEBUG__        for debugging destructors.
#  -D__FILEPARSER_DEBUG__        for debugging FileParser.
#  -D__SISSIPARSER_DEBUG__       for debugging SiSiParser.
DEFINES     = -D__UNIX__
CCINCLUDE = -I./include
CCOPTS      = -ansi -Wall -Wno-deprecated
LNKOPTS     = -L$(SISIPATH)/lib
LNKLIB      = -lm

# Files, die in das Backup zu den *.hh und *.cc Files aufgenommen werden sollen
#BACKUPFILES:=	$(addprefix $(APPNAME)/, $(BACKUPFILES))

BU_SUFFIXES = "*.cc" "*.hh"
SUFFIXES = .cc .o  # Define our suffix list.

# Header-File, in der die Programmname und Versionsnummern definiert sind
VERSIONFILE = ./src/Version.cc

# Temporary Directory for Backup
TEMPNAME    = TEMP42

SOURCEFILES =	$(addsuffix .cc, $(basename $(OBJECTS))) \
		$(addsuffix .cc, $(basename $(MAKEDOCOBJECTS))) \
		$(addsuffix .cc, $(basename $(MANIPOBJECTS))) \
		$(addsuffix .cc, $(basename $(LIBOBJECTS)))

.cc.o:
	$(CC) -c $(CCOPTS) $(CCINCLUDE) $(DEFINES) -o $*.o $*.cc

.PHONY: version time completiontime linecount

$(LIBRARY): lib

lib: 	$(LIBOBJECTS)
	ar -rc libsisi.a $(LIBOBJECTS)
	@if [ ! -d ./lib ]; then mkdir lib; fi
	mv libsisi.a $(LIBRARY)
	ranlib $(LIBRARY)

all:    time version lib 

new:    clean all

clean:
	@echo -n "Making all Subdirectories clean ... "; \
	  for DIR in `find . -type d -print` ; do \
	    rm -f $$DIR/*.o $$DIR/*~ $$DIR/core $$DIR/a.out $$DIR/"#"*"#"; \
	  done; \
	  rm -f Html/*.html; \
	  echo Done.

completiontime:
	@echo -n "Setting CompletionTime in VERSION and update file \
                  \"$(VERSIONFILE)\" ... "; \
	  echo "PRG            = "$(PRG)                   > VERSION; \
	  echo "VERSION        = "$(VERSION)              >> VERSION; \
	  echo "COMPLETIONTIME = `date "+%b %d %Y, %T"`" >> VERSION; \
	  echo                           >> VERSION; \
	  echo "# Datum der Fertigstellung wird mittels" \
	       " make completiontime (time) erzeugt."     >> VERSION; \
	  $(MAKE) version > /dev/null; \
	  echo Done.


doc:
	@echo "Making documentation of selected header files ... "; \
	  if [ ! -x bin/makedocumentation ]; then\
	    make makedoc; \
	  fi; \
	  bin/createDocumentation; \
	  echo Done.

linecount:
	@echo "Counting number of lines of sources (*.hh and *.cc) ... "; \
	  unset SOURCES; \
	  for SUFFIXES in "*.hh" "*.cc"; do \
	    for FILE in `find * -name "$$SUFFIXES" -type \
		         f -print`; do \
	      SOURCES=$$SOURCES' '$$FILE; \
	    done; \
	  done; \
	  wc -l $$SOURCES; \
	  echo "Done."

time:
	@echo -n "Setting Time in VERSION (uncompleted) and update file \
                  \"$(VERSIONFILE)\" ... "; \
	  echo "PRG            = "$(PRG)                   > VERSION; \
          echo "VERSION        = "$(VERSION)              >> VERSION; \
	  echo "COMPLETIONTIME = `date "+%b %d %Y, %T"` (uncompleted)" \
	                                                  >> VERSION; \
	  echo                           >> VERSION; \
	  echo "# Datum der Fertigstellung wird mittels" \
	       " make completiontime (time) erzeugt."     >> VERSION; \
	  $(MAKE) version > /dev/null; \
	  echo Done.

version: 
	@echo -n "Creating file \"$(VERSIONFILE)\" from VERSION ... "; \
	  echo "// Generated automatically from VERSION by 'make version'" \
	    >$(VERSIONFILE); \
	  echo                                       >>$(VERSIONFILE); \
	  echo "#include \"Version.hh\""             >>$(VERSIONFILE); \
	  echo                                       >>$(VERSIONFILE); \
	  echo "const char* Version::ProgramName    = " \
	       "\"$(PRGNAME)\";"                     >>$(VERSIONFILE); \
	  echo "const char* Version::Number         = " \
	       "\"$(VERSION)\";"                     >>$(VERSIONFILE); \
	  echo "const char* Version::Program        = " \
	       "\"$(PRGNAME) $(VERSION)\";"          >>$(VERSIONFILE); \
	  echo "const char* Version::CompletionTime = " \
	       "\"$(COMPLETIONTIME)\";"              >>$(VERSIONFILE); \
	  echo done.

-include ./deps

