# part of Makefile (included by Makefile): SunOS5.

# Whats the desired name of the sissi library:
LIBRARY     = $(SISSIPATH)/lib/lib$(APPNAME).a

# Tell me how to make the library:
MAKELIBRARY  = ar r $(LIBRARY) $(LIBOBJECTS) && ranlib $(LIBRARY)
