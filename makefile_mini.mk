# terminology..
# .. project <- this Makefile
# .. resource <- e.g. for mm_add_library a library is a resource
# .. binary <- e.g. for $(call mm_add_library,staticlibrarytest,<..>)..
#    .. libstaticlibrarytest.<lib/a> is a resource
# .. library <- static|shared
# .. executable <- notportable (<no extension>/.exe)|portable (.AppImage/.exe)
# .. installer <- <.deb/.snap>/.msi

#MM_SAFETY:=

#******************************************************************************

# NOTE: https://stackoverflow.com/a/47927343/4825512
MM_EMPTY:=
define MM_NEWLINE:=

$(MM_EMPTY)
endef


ifndef OS #< linux
MM_STATICLIBRARY_EXTENSION:=.a
MM_SHAREDLIBRARY_EXTENSION:=.so
else ifeq ($(OS), Windows_NT) #< windows
MM_STATICLIBRARY_EXTENSION:=.lib
MM_SHAREDLIBRARY_EXTENSION:=.dll
else
$(error os not supported)
endif

ifndef OS
MM_RM=rm -f $(1)
else
# NOTE: del outputs "Invalid switch" if any forward / is used"
MM_RM=if exist $(1) del $(subst /,\,$(1))
endif

# NOTE: $(1) == a
#       $(2) == b
# NOTE: if a == b.. returns 1
#       otherwise.. returns 0
define mm_equals=
$(eval mm_equals_bAreBothEmpty:=0)
$(if $(1),,$(if $(2),,$(eval mm_equals_bAreBothEmpty:=1)))
$(if $(filter 1,$(mm_equals_bAreBothEmpty)),\
	1,\
	$(if $(filter $(1),$(2)),1,0)\
)
endef

MM_BINARIES:=

#******************************************************************************
#                                      c
#******************************************************************************

# NOTE: $(1) == variablename
define mm_info_about_o_from_c_t=
$(eval $(1).c:=)
$(eval $(1).o:=)
$(eval $(1).gcc:=)
$(eval $(1).hFolders:=)
endef
# NOTE: ^
#       .o == if windows.. $(basename <.c>).o
#             if linux..
#             .. if sharedlibrary.. $(basename <.c>).shared.o
#             .. otherwise.. $(basename <.c>).static.o

MM_INFO_PER_O_FROM_C:=

#********************************** library ***********************************

EMMLibrarytype_All:=EMMLibrarytype_Static EMMLibrarytype_Shared

# NOTE: $(1) == <mm_add_library_parameters_t>
define mm_add_library_parameters_t=
$(eval $(1).types:=$(EMMLibrarytype_All))
$(eval $(1).c:=)
endef
# NOTE: ^
#       .types == one or multiple of EMMLibrarytype

# NOTE: $(1) == variablename
define mm_info_about_library_t=
$(eval $(1).name:=)
$(eval $(1).types:=)
$(eval $(1).c:=)
$(eval $(1).o:=)
$(if $(OS),,\
	$(eval $(1).static.o:=)\
	$(eval $(1).shared.o:=)\
)
endef

MM_INFO_PER_LIBRARY:=

#*********************************** checks ***********************************

# NOTE: $(1) == functionname
#       $(2) == <mm_add_library_parameters_t>
define mm_check_add_library_parameters_t=
$(if $(findstring undefined,$(origin $(2).types)),$(error $(2).types is not defined in $(1)),)
$(if $(findstring undefined,$(origin $(2).c)),$(error $(2).c is not defined in $(1)),)
$(if $($(2).types),,$(error $(2).types may not be empty in $(1)))
$(eval mm_check_add_library_parameters_t_a:=$(filter-out $(EMMLibrarytype_All),$($(2).types)))
$(if $(mm_check_add_library_parameters_t_a),$(error $(2).types contains invalid element(s) $(mm_check_add_library_parameters_t_a) in $(1)),)
$(eval mm_check_add_library_parameters_t_b:=$(filter-out %.c,$($(2).c)))
$(if $(mm_check_add_library_parameters_t_b),$(error $(2).c contains invalid element(s) $(mm_check_add_library_parameters_t_b) in $(1)),)
endef

#******************************************************************************

# NOTE: $(1) == libraryname
# NOTE: if there is a library for which <mm_info_about_library_t>.name ==..
#       .. $(1).. returns 1
#       otherwise.. returns 0
define mm_is_library=
$(eval mm_is_library_bIsLibrary:=0)
$(foreach mm_is_library_infoAboutLibrary,$(MM_INFO_PER_LIBRARY),\
	$(if $(findstring $(mm_is_library_infoAboutLibrary).name,$(1)),\
		$(eval mm_is_library_bIsLibrary:=1)\
	,)\
)
$(if $(filter 1,$(mm_is_library_bIsLibrary)),1,0)
endef

# NOTE: library, headerlibrary and shaderlibrary are separate as every..
#       .. librarytype/shaderlibrary can be built from the same files
EMMLibrarytype:=EMMLibrarytype_Static EMMLibrarytype_Shared
# NOTE: $(1) == libraryname
#       $(2) == <mm_add_library_parameters_t>
define mm_add_library=
$(if $(findstring undefined,$(origin MM_SAFETY)),,\
	$(if $(filter 1,$(call mm_is_library,$(1))),$(error attempted to add library $(1) more than once in $(0)),)\
	$(call mm_check_add_library_parameters_t,$(0),$(2))\
)
$(eval MM_INFO_PER_LIBRARY+=MM_INFO_PER_LIBRARY.$(words $(MM_INFO_PER_LIBRARY)))
$(eval mm_add_library_infoAboutLibrary:=$(lastword $(MM_INFO_PER_LIBRARY)))
$(call mm_info_about_library_t,$(mm_add_library_infoAboutLibrary))
$(eval $(mm_add_library_infoAboutLibrary).name:=$(1))
$(eval $(mm_add_library_infoAboutLibrary).types:=$($(2).types))
$(eval $(mm_add_library_infoAboutLibrary).c:=$($(2).c))
$(if $(OS),\
	$(eval $(mm_add_library_infoAboutLibrary).o:=$(addsuffix .o,$(basename $($(2).c))))\
	$(eval $(mm_add_library_infoAboutLibrary).static.o:=$($(mm_add_library_infoAboutLibrary).o))
	$(eval $(mm_add_library_infoAboutLibrary).shared.o:=$($(mm_add_library_infoAboutLibrary).o)),\
	$(eval $(mm_add_library_infoAboutLibrary).o:=)\
	$(if $(findstring EMMLibrarytype_Static,$($(mm_add_library_infoAboutLibrary).types)),\
		$(eval $(mm_add_library_infoAboutLibrary).static.o:=$(addsuffix .static.o,$(basename $($(2).c))))\
		$(eval $(mm_add_library_infoAboutLibrary).o+=$($(mm_add_library_infoAboutLibrary).static.o))\
	,)\
	$(if $(findstring EMMLibrarytype_Shared,$($(mm_add_library_infoAboutLibrary).types)),\
		$(eval $(mm_add_library_infoAboutLibrary).shared.o:=$(addsuffix .shared.o,$(basename $($(2).c))))\
		$(eval $(mm_add_library_infoAboutLibrary).o+=$($(mm_add_library_infoAboutLibrary).shared.o))\
	,)\
)
$(foreach mm_add_library_o,$($(mm_add_library_infoAboutLibrary).o),\
	$(if $(OS),\
		$(eval mm_add_library_c:=$(basename $(mm_add_library_o)).c),\
		$(eval mm_add_library_c:=$(basename $(basename $(mm_add_library_o))).c)\
	)\
	$(eval mm_add_library_bIsOFromC:=0)\
	$(foreach mm_add_library_infoAboutOFromC,$(MM_INFO_PER_O_FROM_C),\
		$(if $(filter 1,$(call mm_equals,$($(mm_add_library_infoAboutOFromC).o),$(mm_add_library_o))),\
		$(if $(filter 1,$(call mm_equals,$($(mm_add_library_infoAboutOFromC).gcc),$($(2).gcc))),\
		$(if $(filter 1,$(call mm_equals,$($(mm_add_library_infoAboutOFromC).hFolders),$($(2).hFolders))),\
			$(eval mm_add_library_bIsOFromC:=1)\
		,)\
		,)\
		,)\
	)\
	$(if $(filter 0,$(mm_add_library_bIsOFromC)),\
		$(eval MM_INFO_PER_O_FROM_C+=MM_INFO_PER_O_FROM_C.$(words $(MM_INFO_PER_O_FROM_C)))\
		$(eval mm_add_library_infoAboutOFromC:=$(lastword $(MM_INFO_PER_O_FROM_C)))\
		$(call mm_info_about_o_from_c_t,$(mm_add_library_infoAboutOFromC))\
		$(eval $(mm_add_library_infoAboutOFromC).c:=$(mm_add_library_c))\
		$(eval $(mm_add_library_infoAboutOFromC).o:=$(mm_add_library_o))\
		$(eval $(mm_add_library_infoAboutOFromC).gcc:=$($(2).gcc))\
		$(eval $(mm_add_library_infoAboutOFromC).hFolders:=$($(2).hFolders))\
	,)\
)
$(if $(findstring EMMLibrarytype_Static,$($(2).types)),\
	$(eval MM_BINARIES+=lib$(1)$(MM_STATICLIBRARY_EXTENSION))\
,)
$(if $(findstring EMMLibrarytype_Shared,$($(2).types)),\
	$(eval MM_BINARIES+=lib$(1)$(MM_SHAREDLIBRARY_EXTENSION))\
,)
endef

#******************************************************************************
#                                   makefile
#******************************************************************************

# NOTE: $(1) == variablename
define mm_add_makefile_parameters_t=
endef

#*********************************** checks ***********************************

# NOTE: $(1) == functionname
#       $(2) == <mm_add_makefile_parameters_t>
define mm_check_add_makefile_parameters_t=
endef

#******************************************************************************

# NOTE: $(1) == infoAboutOFromC
define mm_add_o_from_c_target=
$(if $(OS),$($(1).o):%.o:%.c,$($(1).o):$($(1).c))
	gcc $($(1).gcc) -o $$@ -c $$< $(addsuffix -I,$($(1).hFolders))
endef

# NOTE: $(1) == infoAboutLibrary
define mm_add_staticlibrary_target=
lib$($(1).name)$(MM_STATICLIBRARY_EXTENSION):$($(1).static.o)
	ar rcs $$@ $$^
endef

# NOTE: $(1) == infoAboutLibrary
define mm_add_sharedlibrary_target=
lib$($(1).name)$(MM_SHAREDLIBRARY_EXTENSION):$($(1).shared.o)
	gcc -shared -o $$@ $$^
endef

# NOTE: $(1) == infoAboutLibrary
define mm_add_library_targets=
$(if $(findstring EMMLibrarytype_Static,$($(1).types)),$(call mm_add_staticlibrary_target,$(1)),)
$(if $(findstring EMMLibrarytype_Shared,$($(1).types)),$(call mm_add_sharedlibrary_target,$(1)),)	
endef

# NOTE: $(1) == infoAboutOFromC
define mm_clean_o_from_c=
$(call MM_RM,$($(1).o))
endef

define mm_add_default_target=
default:$(MM_BINARIES)
endef

define mm_add_clean_target=
.PHONY: clean
clean:
	$(foreach mm_add_clean_target_infoAboutOFromC,$(MM_INFO_PER_O_FROM_C),$(MM_NEWLINE)	$(call mm_clean_o_from_c,$(mm_add_clean_target_infoAboutOFromC)))
	$(foreach mm_add_clean_target_binary,$(MM_BINARIES),$(MM_NEWLINE)	$(call MM_RM,$(mm_add_clean_target_binary)))
endef

# NOTE: $(1) == <mm_add_makefile_parameters_t>
define mm_add_makefile=
$(if $(findstring undefined,$(origin MM_SAFETY)),,\
	$(call mm_check_add_makefile_parameters_t,$(1))\
)

$(eval $(call mm_add_default_target))

$(foreach mm_add_makefile_infoAboutOFromC,$(MM_INFO_PER_O_FROM_C),$\
$(eval $(call mm_add_o_from_c_target,$(mm_add_makefile_infoAboutOFromC)))$\
)

$(foreach mm_add_makefile_infoAboutLibrary,$(MM_INFO_PER_LIBRARY),$\
$(eval $(call mm_add_library_targets,$(mm_add_makefile_infoAboutLibrary)))$\
)

$(eval $(call mm_add_clean_target))
endef
