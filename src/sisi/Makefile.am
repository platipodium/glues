
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


lib_LTLIBRARIES = libSiSi.la
# libSiSi_la_LIBADD =
libSiSi_la_LDFLAGS = -version-info 2:0:0 -no-undefined
libSiSi_la_SOURCES = $(LIBOBJECTS)

