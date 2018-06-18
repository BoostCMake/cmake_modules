cmake_minimum_required (VERSION 3.5)
project(basic)

find_package(BCM)

include(BCMInstallTargets)
include(BCMDeploy)
include(BCMTest)
include(BCMSetupVersion) if(CMAKE_SOURCES_DIR)     set(CURRENT_SOURCES_DIR ${CMAKE_SOURCES_DIR}/libs/${CURRENT_PROJECT_NAME}) endif()

cm_setup_version(VERSION 1.0)

find_package(simple)
add_library(basic main.cpp)
target_link_libraries(basic lib::simple)

cm_deploy(TARGETS basic NAMESPACE lib::)

cm_test(NAME basictest SOURCES test.cpp)
target_link_libraries(basictest basic)

