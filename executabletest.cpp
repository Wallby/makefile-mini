extern "C"
{
#include "headertest.h"
#include <sharedlibrary_mini.h>	
}


int staticlibrarytest();
extern "C"
{
SM_IMPORT float sharedlibrarytest();
}

int main(int argc, char** argv)
{
	fputs("Hello from executabletest2!\n", stdout);

	if(staticlibrarytest() != HEADERTEST)
	{
		return 1;
	}
	if(sharedlibrarytest() != 1.234567890f)
	{
		return 2;
	}
	
	fputs("Bye from executabletest2!\n", stdout);
	
	return 0;
}
