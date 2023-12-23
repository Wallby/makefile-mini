MM_SAFETY:=
include makefile_mini.mk


$(call mm_start_parameters_t,a)
a.ignoredbinaries:=^testexecutabletest$(MM_EXECUTABLE_EXTENSION)$$
# ^
# $$ as otherwise will be escaped here
$(call mm_start,a)

#********************************** shaders ***********************************

$(call mm_add_shader_parameters_t,b)
b.type:=EMMShadertype_Vertex
#b.filetypes:=EMMShaderfiletype_Shared EMMShaderfiletype_Static
# ^
# default
b.filetypes:=EMMShaderfiletype_Shared
# ^
# .spv
b.glsl:=vertexshadertest.glsl
$(call mm_add_shader,vertexshadertest,b)

$(call mm_add_shader_parameters_t,c)
c.type:=EMMShadertype_Pixel
c.filetypes:=EMMShaderfiletype_Static
# ^
# .spv.h
c.glsl:=pixelshadertest.glsl
$(call mm_add_shader,pixelshadertest,c)

#************************************* c **************************************

$(call mm_add_library_parameters_t,e)
#e.filetypes:=
# ^
# default (.h only)
e.h:=headertest.h
$(call mm_add_library,headerlibrarytest,e)

$(call mm_add_library_parameters_t,f)
f.filetypes:=EMMLibraryfiletype_Static
f.c:=staticlibrarytest.c
f.localC:=a/a.c
# no "f.o" as .o is not cross platform (unlike e.g. .spv)
$(call mm_add_library,staticlibrarytest,f)

$(call mm_add_library_parameters_t,g)
g.filetypes:=EMMLibraryfiletype_Static
g.cpp:=staticlibrarytest.cpp
$(call mm_add_library,staticlibrarytest2,g)

$(call mm_add_library_parameters_t,h)
h.filetypes:=EMMLibraryfiletype_Shared
h.c:=sharedlibrarytest.c
#h.libraries:=sharedlibrary-mini:
$(call mm_add_library,sharedlibrarytest,h)

$(call mm_add_library_parameters_t,i)
i.filetypes:=$(EMMLibraryfiletype_All)
i.c:=staticlibrarytest.c sharedlibrarytest.c
i.localC:=a/a.c
$(call mm_add_library,librarytest,i)

$(call mm_add_executable_parameters_t,j)
#j.additionalfiletypes:=
# ^
# default
j.c:=executabletest.c
j.libraries:=staticlibrarytest sharedlibrarytest
#j.sharedlibraries:=librarytest
# ^
# wouldn't work here as librarytest also includes staticlibrarytest again?,..
# .. other than that j.libraries:=librarytest would be invalid because..
# .. ambiguous whether to include static/shared
j.hFolders:=../sharedlibrary-mini/
j.lib:=sharedlibrary-mini
j.libFolders:=../sharedlibrary-mini/
$(call mm_add_executable,executabletest,j)

$(call mm_add_executable_parameters_t,k)
k.cpp:=executabletest.cpp
k.hppFolders:=../sharedlibrary-mini/
# NOTE: ^
#       not sure if wouldn't make more sense to instead use .hFolders for..
#       .. both c and c++ and .hppFolders only for c++?
k.libraries:=staticlibrarytest2 sharedlibrarytest
k.lib=sharedlibrary-mini
k.libFolders:=../sharedlibrary-mini/
$(call mm_add_executable,executabletest2,k)

$(call mm_add_executable_parameters_t,l)
l.c:=testexecutabletest.c
l.gccOrG++:=-Wl,--wrap=malloc,--wrap=free,--wrap=main
#l.libraries:=test-mini:
l.hFolders:=../test-mini/
l.lib:=test-mini
l.libFolders:=../test-mini/
# ^
# for sanity.. suffices to read documentation of each library used to figure..
# .. out what (if anything) to specify here
$(call mm_add_executable,testexecutabletest,l)

#*********************************** tests ************************************

$(call mm_add_test_parameters_t,m)
m.executables:=testexecutabletest
m.scripts=testscripttest
$(call mm_add_test,test,m)

#******************************************************************************

$(call mm_stop_parameters_t,n)
n.releasetypes:=EMMReleasetype_Zip
#n.releasetypes:=EMMReleasetype_Zip EMMReleasetype_Installer
n.ifRelease.ignoredbinaries:=^liblibrarytest$(MM_SHAREDLIBRARY_EXTENSION)$$
n.ifRelease.ifZip.additionalfiles:=.txt$$ .md$$
# ^
# additionally include every .txt and .md file in .zip
#n.ifRelease.ifInstaller.additionalfiles:=
$(call mm_stop,n)
