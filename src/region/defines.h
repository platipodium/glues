#include<math.h>
#include<stdio.h>
#include<stdlib.h>
#include <string.h>
#include "random.h"

/* #define DIM2 86 */
/* #define DIM1 70 */
#ifdef _SAGE
#define DIM2 4320
#define DIM1 2160
#define DIMW2 4320  /* half degree lon world */ 
#define DIMW1 2160  /* half degree lat world */
#define NPOP 9331200
#define NSTAT 120
#define SAGE 1
#define NEW_REG 1
#else

#define DIM2 720 
#define DIM1 360
/*#define DIM2 190 */
/*#define DIM1 120 */

#define DIMW2 720  /* half degree lon world */ 
#define DIMW1 360  /* half degree lat world */
#define NPOP 62950
#define NSTAT 25
#define SAGE 0
#define NEW_REG 0

#endif

#define NIND 10
#define NDIR 9
#define EPS 1E-8
#define MAGICK 0
