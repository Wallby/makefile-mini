#include <test_mini.h>

#include <stdio.h>
#include <stdlib.h>

#if defined(_WIN32)
#define FOLDER_SEPARATOR "\\"
#elif defined(__linux__)
#define FOLDER_SEPARATOR "/"
#else
#error os not supported
#endif


// test if all files are where they are expected to be..

// files in..
// vertexshadertest.glsl <- EMMShaderfiletype_Shared
// pixelshadertest.glsl <- EMMShaderfiletype_Static
// headertest.h
// staticlibrarytest.c <- EMMLibraryfiletype_Static, EMMLibraryfiletype_Shared
// sharedlibrarytest.c <- EMMLibraryfiletype_Shared, EMMLibraryfiletype_Static
// executabletest.c
// testexecutabletest.c

// files out..
// vertexshadertest.spv
// .makefile-mini/pixelshadertest.spv
// pixelshadertest.spv.h
// if windows..
//   .makefile-mini/staticlibrarytest.o
//   .makefile-mini/sharedlibrarytest.o
//   libstaticlibrarytest.lib
//   libsharedlibrarytest.dll
//   liblibrarytest.lib
//   liblibrarytest.dll
// if linux..
//   .makefile-mini/staticlibrarytest.static.o
//   .makefile-mini/sharedlibrarytest.shared.o
//   .makefile-mini/staticlibrarytest.shared.o
//   .makefile-mini/sharedlibrarytest.static.o
//   libstaticlibrarytest.a
//   libsharedlibrarytest.so
//   liblibrarytest.a
//   liblibrarytest.so
// .makefile-mini/executabletest.o
// .makefile-mini/testexecutabletest.o
// if windows..
//   executabletest.exe
//   .makefile-mini/testexecutabletest.exe
// if linux..
//   executabletest
//   .makefile-mini/testexecutabletest

int test_1()
{
	//if(fopen("
	fputs("test 1 is not implemented\n", stdout);
	
	return 1;
}

// try to run executables..

int test_2()
{
	fputs("." FOLDER_SEPARATOR "executabletest.exe\n", stdout);
	int a = system("." FOLDER_SEPARATOR "executabletest.exe");
	if(a != 0)
	{
		return a;
	}

	return 1;
}


int main(int argc, char** argv)
{
	TM_TEST2(1)
	TM_TEST2(2)
	
	return 0;
}
