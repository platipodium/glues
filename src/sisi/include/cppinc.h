#ifndef CPPINC_H
#define CPPINC_H

#ifdef USE_DEPRECATED_STANDARD_LIBRARY_HEADERS

#include <ctype.h>
#include <errno.h>
#include <fstream.h>
#include <iomanip.h>
#include <iostream.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#ifdef __BORLANDC__
#include <strstrea.h>
#else /* __BORLANDC__ */
#include <strstream.h>
#endif /* __BORLANDC__ */

#else /* USE_DEPRECATED_STANDARD_LIBRARY_HEADERS */

#include <ctype.h>
#include <errno.h>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <time.h>

#include <fstream>
#include <iomanip>
#include <iostream>
#include <strstream> /* This causes a deprecated warning indicating that it should be replaced by <sstream> */
#include <sstream>
using namespace std;

#endif /* USE_DEPRECATED_STANDARD_LIBRARY_HEADERS */

#endif /* CPPINC_H */
