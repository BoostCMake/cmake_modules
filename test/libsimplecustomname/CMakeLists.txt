cmake_minimum_required (VERSION 3.5)
project(libsimple)

find_package(BCM)

include(BCMInstallTargets)
include(BCMDeploy)
include(BCMSetupVersion) if(CMAKE_SOURCES_DIR)     set(CURRENT_SOURCES_DIR ${CMAKE_SOURCES_DIR}/libs/${CURRENT_PROJECT_NAME}) endif()
include(BCMTest)

cm_setup_version(VERSION 1.0 GENERATE_HEADER simpleversion.hpp)

add_library(simple INTERFACE)

cm_install_targets(TARGETS simple INCLUDE include)
cm_auto_export(TARGETS simple NAME simple)

cm_test(NAME simpletest SOURCES test.cpp)
target_link_libraries(simpletest simple)

cm_test(NAME simpletestcompile SOURCES compiletest.cpp COMPILE_ONLY)
target_link_libraries(simpletestcompile simple)

cm_test_header(NAME simpletestheader HEADER simple.h)
target_link_libraries(simpletestheader simple)

cm_test_header(NAME simpleteststaticheader HEADER simple.h STATIC)
target_link_libraries(simpleteststaticheader simple)

