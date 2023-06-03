MM_HEADERS:=headertest.h
MM_STATICLIBRARIES:=staticlibrarytest
MM_SHAREDLIBRARIES:=sharedlibrarytest
MM_EXECUTABLES:=executabletest
MM_TESTS:=test
# ^
# e.g...
# MM_EXECUTABLES:=executabletest test
# .. would only compile test once, run test on release, and because of..
# .. inclusion of test in MM_EXECUTABLES will also include test in release..
# .. .zip (if MM_RELEASE isn't defined)
MM_RELEASE:=
# ^
# places every binary in .makefile-mini/ and not generate a release .zip ever
# TODO: make andtest
#       # ^
#       # identical to "make release" except doesn't generate a release .zip
#       # ^
#       # if adding --release and --safety.. "make test" can be..
#       # .. supplied --safety/--release to build release binaries with..
#       # .. safety/release (non release binaries don't support --safety nor..
#       # .. --release)
#       # ^
#       # i.e. "make release" would be identical to "make test --release"..
#       # .. except doesn't generate a release .zip
#MM_RELEASE:=$(MM_HEADERS) $(MM_SHAREDLIBRARIES) $(MM_EXECUTABLES)
# TODO: ^
#       the above would require generated files to be possible prerequisites..
#       .. as executabletest requires staticlibrary

staticlibrarytest.c:=staticlibrarytest.c

sharedlibrarytest.c:=sharedlibrarytest.c
sharedlibrarytest-I:=../sharedlibrary-mini/

executabletest.c:=executabletest.c
executabletest-I:=../sharedlibrary-mini/
executabletest-L:=../sharedlibrary-mini/ ./
executabletest-l:=sharedlibrary-mini staticlibrarytest sharedlibrarytest

test.c:=test.c
test-:=-Wl,--wrap=malloc,--wrap=free,--wrap=main
# ^
# - means additional option(s) for ar/gcc
# ^
# test-mini is not by default assumed as *-mini projects should never..
# .. require another mini project to be used (e.g. test-mini can be used for..
# .. test as building release* isn't required for only using a project,..
# .. makefile-mini can be used by copying makefile_mini.mk as it is only for..
# .. building a binary/binaries not a required file for using any binary)
# * building release -> make release
#   building release version -> make --release
#   ^
#   make release builds release version
test-I:=../test-mini/
test-L:=../test-mini/
test-l:=test-mini

include makefile_mini.mk
# ^
# include last is consistent with #define before #include
