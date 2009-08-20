# part of Makefile (included by Makefile): Linux.

# Whats the desired name of the sissi library:
LIBRARY     = $(SISSIPATH)/lib/lib$(APPNAME).so

# Tell me how to make the library:
MAKELIBRARY  = g++ -shared -Wl,-soname,$(LIBRARY) -o $(LIBRARY) $(LIBOBJECTS)
