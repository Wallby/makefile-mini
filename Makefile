MM_SAFETY:=
include makefile_mini.mk


$(call mm_add_library_parameters_t,e)
e.types:=EMMLibrarytype_Static
e.c:=staticlibrarytest.c
$(call mm_add_library,staticlibrarytest,e)

$(call mm_add_library_parameters_t,f)
f.types:=EMMLibrarytype_Shared
f.c:=sharedlibrarytest.c
$(call mm_add_library,sharedlibrarytest,f)

$(call mm_add_library_parameters_t,g)
g.types:=EMMLibrarytype_Static EMMLibrarytype_Shared
g.c:=staticlibrarytest.c sharedlibrarytest.c
$(call mm_add_library,librarytest,g)
# ^
# EMMLibrarytype_Static will generate liblibrarytest.<lib/a>
# EMMLibrarytype_Shared will generate liblibrarytest.<dll/so>

$(call mm_add_makefile_parameters_t,j)
$(call mm_add_makefile,j)
