set (BINNAME test-gcouchbase)

include(ValaPrecompile)

SET( LIVE_GCOUCH_VALA_PACKAGES
	${DEFAULT_PACKAGES}
	posix
)

vala_precompile(LIVE_GCOUCH_VALA_C 
	test-runner.vala
	client.vala
PACKAGES
	${LIVE_GCOUCH_VALA_PACKAGES}
	${PKGNAME}-${PKGVERSION}
OPTIONS
	${DEFAULT_VALA_OPTIONS}
	--vapidir ${CMAKE_BINARY_DIR}/src)

vala_precompile(OTHER_GCOUCH_VALA_C 
	test-runner-other.vala
	json-serializer.vala
	json-deserializer.vala
	test-classes.vala
PACKAGES
	${LIVE_GCOUCH_VALA_PACKAGES}
	${PKGNAME}-${PKGVERSION}
OPTIONS
	${DEFAULT_VALA_OPTIONS}
	--vapidir ${CMAKE_BINARY_DIR}/src)

set(LIVE_GCOUCH_CFLAGS
	${CORE_DEPS_CFLAGS_ALL}
	-I${CMAKE_BINARY_DIR}/src
	-w
)
set(LIVE_GCOUCH_LIB_PATHS
	${CORE_DEPS_LIBRARY_DIRS}
	${CMAKE_BINARY_DIR}/src
)
add_definitions(${LIVE_GCOUCH_CFLAGS})
link_directories(${LIVE_GCOUCH_LIB_PATHS})

add_executable(${BINNAME}-live ${LIVE_GCOUCH_VALA_C})
add_dependencies(${BINNAME}-live ${PKGNAME}-${PKGVERSION})
target_link_libraries(${BINNAME}-live ${CORE_DEPS_LIBRARIES} ${PKGNAME}-${PKGVERSION})

add_executable(${BINNAME} ${OTHER_GCOUCH_VALA_C})
add_dependencies(${BINNAME} ${PKGNAME}-${PKGVERSION})
target_link_libraries(${BINNAME} ${CORE_DEPS_LIBRARIES} ${PKGNAME}-${PKGVERSION})

include_directories(${CMAKE_BINARY_DIR}/src)
include(Tests)
add_test_executable(${BINNAME}-live)
add_test_executable(${BINNAME})
set(ENV{LD_LIBRARY_PATH} "${CMAKE_BINARY_DIR}/src:$ENV{LD_LIBRARY_PATH}")
