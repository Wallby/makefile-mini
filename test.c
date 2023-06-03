#include <test_mini.h>

#include <stdio.h>
#include <stdlib.h>


int test_1()
{
	fputs(".makefile-mini/executabletest.exe\n", stdout);
#if defined(_WIN32)
	int a = system(".makefile-mini\\executabletest.exe");
#else //< #elif defined(__linux__)
	int a = system(".makefile-mini/executabletest.exe");
#endif
	if(a != 0)
	{
		return a;
	}

	return 1;
}

int main(int argc, char** argv)
{
	TM_TEST2(1);
	
	return 0;
}
