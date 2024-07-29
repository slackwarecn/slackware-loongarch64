/************** Machine (and compiler) dependent definitions. **************
 *
 *	This file is for 80386 based UNIX/XENIX systems.
 */


/*      MACHINE TYPE	DEFINED TYPE		VALUE RANGE	*/

typedef unsigned char	int8;		/*        0 ..     255 */
typedef short		int16;		/*  -10,000 ..  10,000 */
typedef int		int32;		/* -100,000 .. 100,000 */
typedef unsigned int	uint32;		/* 	  0 ..  2^31-1 */



#ifdef NETWORK_DATABASE

#if 1

/* If you want network byte order, you most likely have TCP as well. */
/* else... why want network byte order??? */

#define NETWORK_BYTE_ORDER	/* THEY ARE NOT */
#include <netinet/in.h>

#else

#undef NETWORK_BYTE_ORDER	/* THEY ARE NOT */
/*
YOU LOSE -- I DON'T KNOW HOW TO DO THIS ON 80386 BASED SYSTEMS!
*/
#define htonl(l)	...	/* host long to network long */
#define ntohl(l)	...	/* network long to host long */

#endif

#endif	/* NETWORK DATABASE */
