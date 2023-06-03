# variables that can be defined..
# NOTE: list of .h files to include in the release .zip regardless of platform
# NOTE: see MM_RELEASE for customizing what is included in the release .zip
#MM_HEADERS:=
# NOTE: list of staticlibraries to compile and then include the platform..
#       .. specific binary in the release .zip for that platform
# NOTE: e.g. staticlibrary statictest would result in libstatictest.<a/lib>
# NOTE: see MM_RELEASE for customizing what is included in the release .zip
#MM_STATICLIBRARIES:=
# NOTE: list of sharedlibraries to compile and then include the platform..
#       .. specific binary in the release .zip for that platform
# NOTE: e.g. sharedlibrary sharedtest would result in libsharedtest.<so/dll>
# NOTE: see MM_RELEASE for customizing what is included in the release .zip
#MM_SHAREDLIBRARIES:=
# NOTE: list of executables to compile and then include the platform..
#       .. specific binary in the release .zip for that platform
# NOTE: e.g. executable executabletest would result in executabletest</.exe>
# NOTE: see MM_RELEASE for customizing what is included in the release .zip
#MM_EXECUTABLES:=
# NOTE: list of tests to compile executable for
#       running "make release" runs every test and the release .zip is only..
#       .. made if every test passed (and the release .zip is not already up..
#       .. to date)
# NOTE: see MM_EXECUTABLES
#MM_TESTS:=
# NOTE: if MM_RELEASE is defined and empty.. disable creating a release .zip
#       if MM_RELEASE is defined and not empty.. per word..
#       .. if the word is a/an staticlibrary/sharedlibrary/..
#          ..executable/test.. will include the corresponding..
#          .. binary in the release .zip
#       .. otherwise.. the word is considered a filename and that..
#       .. file will be included in the release .zip
#       if MM_RELEASE isn't defined defaults to all headers and binaries except tests
# NOTE: any non release binary will be put in .makefile-mini/ to be hidden..
#       .. from any other project
#MM_RELEASE:=

# targets..
# NOTE: makes every (not up to date) binary that would be included in the..
#       .. release .zip for the current platform
#make
# NOTE: 1. makes every (not up to date) binary for the current platform..
#       .. (unlike "make" also make binaries that wouldn't be included in..
#       .. release .zip)
#       2. runs every test
#       if every test succeeded..
#       3. makes release .zip for the current platform (only if not up to date)
#make release
# NOTE: cleans every binary and every intermediate file
#make clean

#******************************************************************************

# NOTE: https://www.gnu.org/software/make/manual/html_node/Syntax-of-Functions.html
MM_COMMA:= ,
MM_EMPTY:= 
MM_SPACE:= $(EMPTY) $(EMPTY)
define MM_NEWLINE


endef
ifndef OS #< linux
MM_OS:=linux
MM_STATICLIBRARY_EXTENSION:=.a
MM_SHAREDLIBRARY_EXTENSION:=.so
MM_EXECUTABLE_EXTENSION:=
MM_RM=rm -f $(1)
MM_MKDIR=mkdir $(1)
MM_RMDIR=rm -f $(1)
MM_IF=if $(1); then $(2); fi
MM_EXIST=[ -f "$(1)" ]
# NOTE: not sure if correct
#              v
MM_NOT_EXIST=[ ! -f "$(1)" ]
# NOTE: $(1) == path to outputfile
# NOTE: $(2) == path per inputfile/inputfolder
MM_ZIP=zip -r9 $(2) $(1)
else ifeq ($(OS), Windows_NT) #< windows
MM_OS:=win32
MM_STATICLIBRARY_EXTENSION:=.lib
MM_SHAREDLIBRARY_EXTENSION:=.dll
MM_EXECUTABLE_EXTENSION:=.exe
# NOTE: del outputs "Invalid switch" if any forward / is used"
MM_RM=if exist $(1) del $(subst /,\,$(1))
# NOTE: mkdir outputs "The syntax of the command is incorrect." if there is..
#       .. a trailing /
MM_MKDIR=if not exist $(1) mkdir $(patsubst %/,%,$(1))
# NOTE: rmdir outputs "Invalid switch" if any forward / is used"
MM_RMDIR=if exist $(1) rmdir $(subst /,\,$(1))
MM_IF=if $(1) $(2)
MM_EXIST=exist $(1)
MM_NOT_EXIST=not exist $(1)
# NOTE: $(1) == path per inputfile/inputfolder
# NOTE: $(2) == path to outputfile
# NOTE: cannot find documentation on omitting -Command for powershell but..
#       .. seems to work
#       ^
#       https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_powershell_exe?view=powershell-5.1#-command
# NOTE: "use commas to separate the paths",..
#       .. https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.archive/compress-archive?view=powershell-7.3#-path
MM_ZIP=powershell Compress-Archive $(subst $(MM_SPACE),$(MM_COMMA),$(strip $(1))) $(2)
else
$(error os not supported)
endif

# NOTE: $(1) == list
#       $(2) == equivalent of text <- function with 1 argument (arguments[0]..
#       .. == var)
#       ^
#       https://www.gnu.org/software/make/manual/html_node/Foreach-Function.html
# NOTE: uses MM_a*
#       ^
#       MM_* is only for non functions
define mm_foreach_on_newline=
$(eval MM_aa=$(2))
$(foreach MM_ab,$(1),$\
	$(call MM_aa,$(MM_ab))$\
	$(if $(filter $(lastword $(1)),$(MM_ab)),,$(MM_NEWLINE))$\
)
endef

# $(1) == folders to search in
# $(2) == files to search
define mm_search_for_files_in_folders=
$(foreach MM_FOLDER,$(1),\
	$(foreach MM_FILE,$(2),\
		$(shell $(call MM_IF,$(call MM_EXIST,$(MM_FOLDER)$(MM_FILE)),echo $(MM_FOLDER)$(MM_FILE)))\
	)\
)
endef

# NOTE: $(1) == STATICLIBRARIES
mm_get_binaryfilenames_from_staticlibraries=$(patsubst %,lib%$(MM_STATICLIBRARY_EXTENSION),$(1))
# NOTE: $(1) == SHAREDLIBRARIES
mm_get_binaryfilenames_from_sharedlibraries=$(patsubst %,lib%$(MM_SHAREDLIBRARY_EXTENSION),$(1))
# NOTE: $(1) == EXECUTABLES
mm_get_binaryfilenames_from_executables=$(addsuffix $(MM_EXECUTABLE_EXTENSION),$(1))
# NOTE: ^
#       binaryfilename is e.g. lib<sharedlibrary>.<so/dll> for sharedlibrary..
#       .. (regardless whether non release or release)

# NOTE: $(1) == STATICLIBRARY
# NOTE: uses MM_b*
define mm_get_binary_from_staticlibrary=
$(eval MM_ba:=lib$(1)$(MM_STATICLIBRARY_EXTENSION))$\
$(if $(filter $(MM_RELEASE),$(MM_ba)),,.makefile-mini/)$(MM_ba)
endef
# NOTE: $(1) == SHAREDLIBRARY
# NOTE: uses MM_c*
define mm_get_binary_from_sharedlibrary=
$(eval MM_ca:=lib$(1)$(MM_SHAREDLIBRARY_EXTENSION))$\
$(if $(filter $(MM_RELEASE),$(MM_ca)),,.makefile-mini/)$(MM_ca)
endef
# NOTE: $(1) == EXECUTABLE
# NOTE: uses MM_d*
define mm_get_binary_from_executable=
$(eval MM_da:=$(1)$(MM_EXECUTABLE_EXTENSION))$\
$(if $(filter $(MM_RELEASE),$(MM_da)),,.makefile-mini/)$(MM_da)
endef
# NOTE: ^
#       binary is..
#       .. e.g. .makefile-mini/lib<sharedlibrary>.<so/dll> for non release..
#          .. sharedlibrary
#       .. e.g. lib<sharedlibrary>.<so/dll> for release sharedlibrary

# NOTE: $(1) == folder to add
# NOTE: if folder already exists when makefile is parsed.. doesn't output..
#       .. anything
mm_add_folder=$(if $(shell $(call MM_IF,$(call MM_NOT_EXIST,$(1)),echo 1)),$(call MM_MKDIR,$(1)))

#***************************** generate variables *****************************

# NOTE: MM_PROJECTNAME is name of folder Makefile that included..
#       .. makefile_mini.mk is in
#       ^
#       e.g. for makefile-mini/Makefile $(MM_PROJECTNAME) == makefile-mini
MM_PROJECTNAME:=$(lastword $(subst /,$(MM_SPACE),$(dir $(abspath $(firstword $(MAKEFILE_LIST))))))

MM_EXECUTABLES_AND_TESTS:=$(MM_EXECUTABLES) $(filter-out $(MM_EXECUTABLES),$(MM_TESTS))

MM_BINARYFILENAME_PER_STATICLIBRARY:=$(call mm_get_binaryfilenames_from_staticlibraries,$(MM_STATICLIBRARIES))
MM_BINARYFILENAME_PER_SHAREDLIBRARY:=$(call mm_get_binaryfilenames_from_sharedlibraries,$(MM_SHAREDLIBRARIES))
MM_BINARYFILENAME_PER_EXECUTABLE:=$(call mm_get_binaryfilenames_from_executables,$(MM_EXECUTABLES))
MM_BINARYFILENAME_PER_TEST:=$(call mm_get_binaryfilenames_from_executables,$(MM_TESTS))

MM_BINARYFILENAMES:=$(MM_BINARYFILENAME_PER_STATICLIBRARY) $(MM_BINARYFILENAME_PER_SHAREDLIBRARY) $(call mm_get_binaryfilenames_from_executables,$(MM_EXECUTABLES_AND_TESTS))

ifeq ($(origin MM_RELEASE),undefined)
# NOTE: if MM_RELEASE isn't defined.. release every binary except test(s)
MM_RELEASE:=$(MM_HEADERS) $(MM_STATICLIBRARIES) $(MM_SHAREDLIBRARIES) $(MM_EXECUTABLES)
endif

ifdef MM_RELEASE #< i.e. MM_RELEASE is not empty
# NOTE: per release binary.. <binary>
MM_RELEASE_BINARIES:=$(foreach MM_a,$(MM_RELEASE),$(if $(filter $(MM_STATICLIBRARIES),$(MM_a)),$(call mm_get_binaryfilenames_from_staticlibraries,$(MM_a)),$(if $(filter $(MM_SHAREDLIBRARIES),$(MM_a)),$(call mm_get_binaryfilenames_from_sharedlibraries,$(MM_a)),$(if $(filter $(MM_EXECUTABLES_AND_TESTS),$(MM_a)),$(call mm_get_binaryfilenames_from_executables,$(MM_a)),))))
# NOTE: per release binary.. <binary>
#       per release element not a binary.. <element>
# NOTE: strip here as in release MM_RELEASE is used in if
MM_RELEASE:=$(strip $(foreach MM_a,$(MM_RELEASE),$(if $(filter $(MM_STATICLIBRARIES),$(MM_a)),$(call mm_get_binaryfilenames_from_staticlibraries,$(MM_a)),$(if $(filter $(MM_SHAREDLIBRARIES),$(MM_a)),$(call mm_get_binaryfilenames_from_sharedlibraries,$(MM_a)),$(if $(filter $(MM_EXECUTABLES_AND_TESTS),$(MM_a)),$(call mm_get_binaryfilenames_from_executables,$(MM_a)),$(MM_a))))))
endif
# NOTE: ^
#       if MM_RELEASE is defined but empty.. don't release any binary

# NOTE: per non release binary.. .makefile-mini/<binaryfilename>
# NOTE: strip here as in clean MM_NON_RELEASE_BINARIES is used in if 
MM_NON_RELEASE_BINARIES:=$(strip $(foreach MM_BINARYFILENAME,$(MM_BINARYFILENAMES),$(if $(filter $(MM_RELEASE_BINARIES),$(MM_BINARYFILENAME)),,.makefile-mini/$(MM_BINARYFILENAME))))

# NOTE: per test..
#       .. if release.. <binaryfilename>
#       .. if non release.. .makefile-mini/<binaryfilename>
MM_BINARY_PER_TEST:=$(foreach MM_BINARYFILENAME,$(MM_BINARYFILENAME_PER_TEST),$(if $(filter $(MM_RELEASE_BINARIES),$(MM_BINARYFILENAME)),,.makefile-mini/)$(MM_BINARYFILENAME))

# NOTE: 1. sets .o_FROM_.c to $(patsubst %.o,%.c,$(.c))
#       2. sets -I for each .o_FROM_.c
$(foreach MM_LIBRARY_OR_EXECUTABLE,$(MM_STATICLIBRARIES) $(MM_SHAREDLIBRARIES) $(MM_EXECUTABLES_AND_TESTS),\
	$(eval MM_LIBRARY_OR_EXECUTABLE.o:=$($(MM_LIBRARY_OR_EXECUTABLE).o))\
	$(eval MM_LIBRARY_OR_EXECUTABLE.o_FROM_.c:=$(patsubst %.c,%.o,$($(MM_LIBRARY_OR_EXECUTABLE).c)))\
	$(eval MM_LIBRARY_OR_EXECUTABLE-:=$($(MM_LIBRARY_OR_EXECUTABLE)-))\
	$(eval MM_LIBRARY_OR_EXECUTABLE-I:=$($(MM_LIBRARY_OR_EXECUTABLE)-I))\
	$(eval $(MM_LIBRARY_OR_EXECUTABLE).o_FROM_.c:=$(MM_LIBRARY_OR_EXECUTABLE.o_FROM_.c))\
	$(foreach MM_a,$(MM_LIBRARY_OR_EXECUTABLE.o_FROM_.c),\
		$(eval $(MM_a)-I:=$(MM_LIBRARY_OR_EXECUTABLE-I))\
	)\
)

ifndef OS #< linux
# specifies type of variable (i.e. :=)
# v
MM_.o_FROM_.c_STATIC:=
# NOTE: 1. appends .o_FROM_.c to MM_.o_FROM_.c_STATIC
$(foreach MM_STATICLIBRARY_OR_EXECUTABLE,$(MM_STATICLIBRARIES) $(MM_EXECUTABLES_AND_TESTS),\
	$(eval MM_STATICLIBRARY.o_FROM_.c:=$($(MM_STATICLIBRARY).o_FROM_.c))\
	$(eval MM_.o_FROM_.c_STATIC+=$(MM_STATICLIBRARY.o_FROM_.c))\
)
MM_.o_FROM_.c_SHARED:=
# NOTE: 1. appends .o_FROM_.c to MM_.o_FROM_.c_SHARED
$(foreach MM_SHAREDLIBRARY,$(MM_SHAREDLIBRARIES) $(MM_EXECUTABLES_AND_TESTS),\
	$(eval MM_SHAREDLIBRARY.o_FROM_.c:=$($(MM_SHAREDLIBRARY).o_FROM_.c))\
	$(eval MM_.o_FROM_.c_SHARED+=$(MM_LIBRARY_OR_EXECUTABLE.o_FROM_.c))\
)
else #< windows
MM_.o_FROM_.c:=
# NOTE: 1. appends .o_FROM_.c to MM_.o_FROM_.c
$(foreach MM_LIBRARY_OR_EXECUTABLE,$(MM_STATICLIBRARIES) $(MM_SHAREDLIBRARIES) $(MM_EXECUTABLES_AND_TESTS),\
	$(eval MM_LIBRARY_OR_EXECUTABLE.o_FROM_.c:=$($(MM_LIBRARY_OR_EXECUTABLE).o_FROM_.c))\
	$(eval MM_.o_FROM_.c+=$(MM_LIBRARY_OR_EXECUTABLE.o_FROM_.c))\
)
endif

#****************************** generate targets ******************************

ifndef OS #< linux
# NOTE: $(1) == .o_FROM_.c_STATIC
define mm_add_.o_from_.c_static=
$(eval MM_.o_FROM_.c-:=$($(1)-))
$(eval MM_.o_FROM_.c-I:=$($(1)-I))
$(1):%.o:%.c
	gcc $(MM_.o_FROM_.c-) -c $$< $(addprefix -I,$(MM_.o_FROM_.c-I))
endef
# NOTE: $(1) == .o_FROM_.c_SHARED
define mm_add_.o_from_.c_shared=
$(eval MM_.o_FROM_.c-:=$($(1)-))
$(eval MM_.o_FROM_.c-I:=$($(1)-I))
$(1):%.o:%.c
	gcc $(MM_.o_FROM_.c-) -fpic -fvisibility=hidden -c $$< $(addprefix -I,$(MM_.o_FROM_.c-I))
endef
else #< windows
# NOTE: $(1) == .o_FROM_.c
define mm_add_.o_from_.c=
$(eval MM_.o_FROM_.c-:=$($(1)-))
$(eval MM_.o_FROM_.c-I:=$($(1)-I))
$(1):%.o:%.c
	gcc $(MM_.o_FROM_.c-) -c $$< $(addprefix -I,$(MM_.o_FROM_.c-I))
endef
endif

# NOTE: $(1) == STATICLIBRARY
# NOTE: a == if release.. lib<staticlibrary>.<a/lib>
#            if non release.. .makefile-mini/lib<staticlibrary>.<a/lib>
#       b == every .o to include in staticlibrary
# NOTE: uses MM_e*
define mm_add_staticlibrary=
$(eval MM_STATICLIBRARY.o:=$($(1).o))
$(eval MM_STATICLIBRARY.o_FROM_.c:=$($(1).o_FROM_.c))
$(eval MM_STATICLIBRARY-:=$($(1)-))
$(eval MM_ea:=$(call mm_get_binary_from_staticlibrary,$(1)))
$(eval MM_eb:=$(MM_STATICLIBRARY.o) $(MM_STATICLIBRARY.o_FROM_.c))
$(MM_ea):$(MM_eb)
	$(if $(filter-out .makefile-mini/,$(dir $(MM_ea))),,$(call mm_add_folder,.makefile-mini/))
	$(call MM_RM,$$@)
	ar rcs $(MM_STATICLIBRARY-) $$@ $$^
endef

# NOTE: $(1) == SHAREDLIBRARY
# NOTE: a == if release.. lib<sharedlibrary>.<so/dll>
#            if non release.. .makefile-mini/lib<sharedlibrary>.<so/dll>
#       b == every .o to include in sharedlibrary
# NOTE: uses MM_f*
define mm_add_sharedlibrary=
$(eval MM_SHAREDLIBRARY.o:=$($(1).o))
$(eval MM_SHAREDLIBRARY.o_FROM_.c:=$($(1).o_FROM_.c))
$(eval MM_SHAREDLIBRARY-:=$($(1)-))
$(eval MM_fa:=$(call mm_get_binary_from_sharedlibrary,$(1)))
$(eval MM_fb:=$(MM_SHAREDLIBRARY.o) $(MM_SHAREDLIBRARY.o_FROM_.c))
$(MM_fa):$(MM_fb)
	$(if $(filter-out .makefile-mini/,$(dir $(MM_fa))),,$(call mm_add_folder,.makefile-mini/))
	gcc $(MM_SHAREDLIBRARY-) -shared -o $$@ $$^
endef

# NOTE: $(1) == EXECUTABLE
# NOTE: a == if release.. <executable></.exe>
#            if non release.. .makefile-mini/<executable></.exe>
#       b == every .o to link
#       c == every release library that can be found in -L and thus should..
#       .. be monitored for change
#       d == if release non empty
#            if non release.. empty
# TODO: ^
#       calculate which files will be generated and only search for files in..
#       .. folders if they aren't expected to be generated (i.e. as a last..
#       .. resort) <- currently if test requires release binary.. calling..
#       .. "make release" would cause error if first building non release..
#       .. binaries and only if every test succeeded make release .zip and..
#       .. thus build release binaries (currently not a problem as building..
#       .. all binaries in make release, but calculating which files will be..
#       .. generated would make building all binaries in make release not..
#       .. required)
# NOTE: uses MM_g*
define mm_add_executable=
$(eval MM_EXECUTABLE.o:=$($(1).o))
$(eval MM_EXECUTABLE.o_FROM_.c:=$($(1).o_FROM_.c))
$(eval MM_EXECUTABLE-:=$($(1)-))
$(eval MM_EXECUTABLE-L:=$($(1)-L))
$(eval MM_EXECUTABLE-l:=$($(1)-l))
$(eval MM_ga:=$(call mm_get_binary_from_executable,$(1)))
$(eval MM_gb:=$(MM_EXECUTABLE.o) $(MM_EXECUTABLE.o_FROM_.c))
$(eval MM_gc:=$(call mm_search_for_files_in_folders,$(MM_EXECUTABLE-L),$(call mm_get_binaryfilenames_from_staticlibraries,$(MM_EXECUTABLE-l)) $(call mm_get_binaryfilenames_from_sharedlibraries,$(MM_EXECUTABLE-l))))
$(eval MM_gd:=$(filter-out .makefile-mini/,$(dir $(MM_ga))))
$(MM_ga):$(MM_gb) $(MM_gc)
	$(if $(MM_gd),,$(call mm_add_folder,.makefile-mini/))
	gcc $(MM_EXECUTABLE-) -o $$@ $(MM_gb) $(addprefix -L,$(if $(MM_gd),,.makefile-mini/) $(MM_EXECUTABLE-L)) $(addprefix -l,$(MM_EXECUTABLE-l))
endef

# NOTE: $(1) == .o_FROM_.c
define mm_clean_.o_FROM_.c=
$(call MM_RM,$(1))
endef

# NOTE: $(1) == STATICLIBRARY
define mm_clean_staticlibrary=
$(call MM_RM,$(call mm_get_binary_from_staticlibrary,$(1)))
endef

# NOTE: $(1) == SHAREDLIBRARY
define mm_clean_sharedlibrary=
$(call MM_RM,$(call mm_get_binary_from_sharedlibrary,$(1)))
endef

# NOTE: $(1) == EXECUTABLE
define mm_clean_executable=
$(call MM_RM,$(call mm_get_binary_from_executable,$(1)))
endef

#******************************************************************************

ifeq ($(or $(filter $(MM_HEADERS),$(MM_RELEASE)),$(MM_RELEASE_BINARIES)),)
# NOTE: if there's nothing to release (not headers nor binaries).. assure "nothing to be done" is output
default:
else
# NOTE: build all release binaries and if this is a header only library..
#       .. output a message specifically for that case
#       ^
#       if there are no binaries to release guaranteed here that this is a..
#       .. header only library
default: $(MM_RELEASE_BINARIES)
	$(if $^,,@echo $(MM_PROJECTNAME) is a header only library)
endif

# NOTE: if linux.. static .o from .c is compiled differently than shared .o..
#       .. from .c
#       if windows.. each .o from .c is compiled the same
ifndef OS #< linux
$(foreach MM_a,$(MM_.o_FROM_.c_STATIC),$(eval $(call mm_add_.o_from_.c_static,$(MM_a))))

$(foreach MM_a,$(MM_.o_FROM_.c_SHARED),$(eval $(call mm_add_.o_from_.c_shared,$(MM_a))))
else #< windows
$(foreach MM_a,$(MM_.o_FROM_.c),$(eval $(call mm_add_.o_from_.c,$(MM_a))))
endif

$(foreach MM_STATICLIBRARY,$(MM_STATICLIBRARIES),$(eval $(call mm_add_staticlibrary,$(MM_STATICLIBRARY))))

$(foreach MM_SHAREDLIBRARY,$(MM_SHAREDLIBRARIES),$(eval $(call mm_add_sharedlibrary,$(MM_SHAREDLIBRARY))))

$(foreach MM_EXECUTABLE,$(MM_EXECUTABLES_AND_TESTS),$(eval $(call mm_add_executable,$(MM_EXECUTABLE))))

ifdef MM_RELEASE
# NOTE: only build release .zip if it's not up to date allows changing test..
#       .. without causing the .zip to be changed
$(MM_PROJECTNAME).$(MM_OS).zip: $(MM_RELEASE)
	$(call MM_RM,$(MM_PROJECTNAME).$(MM_OS).zip)
	$(call MM_ZIP,$^,$(MM_PROJECTNAME).$(MM_OS).zip)
endif

# NOTE: 1. build every test
#       2. run every test
#       if any test failed.. stops
#       3. make release .zip (only if not up to date)
.PHONY: release
# NOTE: deducing prerequisites from generatable binaries would mean..
#       .. MM_RELEASE_BINARIES here is no longer required
#       v
#       temporary fix build MM_RELEASE_BINARIES here as if any non release..
#       .. binary requires it would cause error if it hasn't been made here
#        v
release: $(MM_RELEASE_BINARIES) $(MM_NON_RELEASE_BINARIES)
	$(foreach MM_BINARY,$(MM_BINARY_PER_TEST),./$(MM_BINARY))
	$(if $(MM_RELEASE),@$(MAKE) --no-print-directory $(MM_PROJECTNAME).$(MM_OS).zip)

.PHONY: clean
clean:
	$(call mm_foreach_on_newline,$(MM_.o_FROM_.c),$$(call mm_clean_.o_FROM_.c,$$(1)))
	$(call mm_foreach_on_newline,$(MM_STATICLIBRARIES),$$(call mm_clean_staticlibrary,$$(1)))
	$(call mm_foreach_on_newline,$(MM_SHAREDLIBRARIES),$$(call mm_clean_sharedlibrary,$$(1)))
	$(call mm_foreach_on_newline,$(MM_EXECUTABLES_AND_TESTS),$$(call mm_clean_executable,$$(1)))
	$(if $(MM_NON_RELEASE_BINARIES),$(call MM_RMDIR,.makefile-mini/))
	$(if $(MM_RELEASE),$(call MM_RM,$(MM_PROJECTNAME).$(MM_OS).zip),)
