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
# no "f.o" as .o is not cross platform (unlike e.g. .spv)
$(call mm_add_library,staticlibrarytest,f)

$(call mm_add_library_parameters_t,g)
g.filetypes:=EMMLibraryfiletype_Shared
g.c:=sharedlibrarytest.c
$(call mm_add_library,sharedlibrarytest,g)

$(call mm_add_library_parameters_t,h)
h.filetypes:=$(EMMLibraryfiletype_All)
h.c:=staticlibrarytest.c sharedlibrarytest.c
$(call mm_add_library,librarytest,h)

$(call mm_add_executable_parameters_t,i)
#i.additionalfiletypes:=
# ^
# default
i.c:=executabletest.c
#i.libraries:=staticlibrarytest sharedlibrary-mini:
i.libraries:=staticlibrarytest sharedlibrarytest
#i.sharedlibraries:=librarytest
# ^
# wouldn't work here as librarytest also includes staticlibrarytest again?,..
# .. other than that i.libraries:=librarytest would be invalid because..
# .. ambiguous whether to include static/shared
i.hFolders:=../sharedlibrary-mini/
i.lib:=sharedlibrary-mini
i.libFolders:=../sharedlibrary-mini/
$(call mm_add_executable,executabletest,i)

$(call mm_add_executable_parameters_t,j)
j.c:=testexecutabletest.c
j.gcc:=-Wl,--wrap=malloc,--wrap=free,--wrap=main
#j.libraries:=test-mini:
j.hFolders:=../test-mini/
j.lib:=test-mini
j.libFolders:=../test-mini/
# ^
# for sanity.. suffices to read documentation of each library used to figure..
# .. out what (if anything) to specify here
$(call mm_add_executable,testexecutabletest,j)

#*********************************** tests ************************************

$(call mm_add_test_parameters_t,k)
k.executables:=testexecutabletest
k.scripts=testscripttest
$(call mm_add_test,test,k)

#******************************************************************************

$(call mm_stop_parameters_t,l)
l.releasetypes:=EMMReleasetype_Zip
#l.releasetypes:=EMMReleasetype_Zip EMMReleasetype_Installer
l.ifRelease.ignoredbinaries:=^liblibrarytest$(MM_SHAREDLIBRARY_EXTENSION)$$
l.ifRelease.ifZip.additionalfiles:=.txt$$ .md$$
# ^
# additionally include every .txt and .md file in .zip
#l.ifRelease.ifInstaller.additionalfiles:=
$(call mm_stop,l)
