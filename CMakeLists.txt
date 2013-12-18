cmake_minimum_required (VERSION 2.8)
cmake_policy(VERSION 2.8)
project(Ambition)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake )
enable_testing()

find_package(Vala REQUIRED)
include(ValaVersion)
include(ValaPrecompile)
ensure_vala_version("0.18.0" MINIMUM)

find_package(Couchbase REQUIRED)

IF(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
	SET(CMAKE_INSTALL_PREFIX "/usr" CACHE PATH "install prefix" FORCE)
ENDIF(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)

IF(LIB_INSTALL_DIR)
ELSE()
SET(LIB_INSTALL_DIR lib)
ENDIF()

set (PKGNAME gcouchbase)
set (PKGVERSION 0.1)
set (PREFIX ${CMAKE_INSTALL_PREFIX})
set (DOLLAR "$")

set (VAPIDIRS 
	--vapidir='${CMAKE_SOURCE_DIR}'
	--vapidir='${CMAKE_SOURCE_DIR}/vapi'
)
set (DEFAULT_VALA_OPTIONS
	--pkg libcouchbase
	${VAPIDIRS}
	--enable-experimental
	--target-glib=2.32
	--debug
	-g
)

SET( CORE_DEPS_PACKAGES
	glib-2.0
	gee-0.8
	json-glib-1.0
	gmodule-2.0
)
find_package(PkgConfig)
pkg_check_modules(CORE_DEPS REQUIRED ${CORE_DEPS_PACKAGES} glib-2.0>=2.32)
SET( CMAKE_BUILD_TYPE Debug )
SET( CORE_DEPS_CFLAGS_ALL
	${CORE_DEPS_CFLAGS}
	${CORE_DEPS_CFLAGS_OTHER}
	-I${COUCHBASE_INCLUDE_DIR}
)

SET( CORE_DEPS_LIBRARY_DIRS 
	${CORE_DEPS_LIBRARY_DIRS}
	${COUCHBASE_LIBRARY})

SET( CORE_DEPS_LIBRARIES 
	${CORE_DEPS_LIBRARIES}
	couchbase)

add_subdirectory (src)
add_subdirectory (test)
