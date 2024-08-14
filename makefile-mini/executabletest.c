#include "headertest.h"

#include <sharedlibrary_mini.h>


int staticlibrarytest();
SM_IMPORT float sharedlibrarytest();

int main(int argc, char** argv)
{
	fputs("Hello from executabletest!\n", stdout);

	if(staticlibrarytest() != HEADERTEST)
	{
		return 1;
	}
	if(sharedlibrarytest() != 1.234567890f)
	{
		return 2;
	}
	
	fputs("Bye from executabletest!\n", stdout);
	
	return 0;
}
