MM_SAFETY:=
include makefile_mini.mk


$(call mm_start_parameters_t,a)
a.ignoredbinaries:=^liblibrarytest$(MM_STATICLIBRARY_EXTENSION)$$
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

#******************************************************************************

$(call mm_stop_parameters_t,i)
i.releasetypes:=EMMReleasetype_Zip
#i.releasetypes:=EMMReleasetype_Zip EMMReleasetype_Installer
i.ifRelease.ignoredbinaries:=^liblibrarytest$(MM_SHAREDLIBRARY_EXTENSION)$$
i.ifRelease.ifZip.additionalfiles:=.txt$$ .md$$
# ^
# additionally include every .txt and .md file in .zip
#i.ifRelease.ifInstaller.additionalfiles:=
$(call mm_stop,i)
