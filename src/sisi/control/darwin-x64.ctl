# part of Makefile (included by Makefile): Linux.

# Whats the desired name of the sissi library:
LIBRARY     = ./lib/lib$(APPNAME).a

# Tell me how to make the library:
MAKELIBRARY  = ar r $(LIBRARY) $(LIBOBJECTS) && ranlib $(LIBRARY)
