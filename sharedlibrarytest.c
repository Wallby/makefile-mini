#if MM_SHARED
#include <sharedlibrary_mini.h>
#else
#define SM_EXPORT
#endif


SM_EXPORT float sharedlibrarytest()
{
	return 1.234567890f;
}
