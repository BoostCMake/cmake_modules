cmake_minimum_required (VERSION 3.5)
project(properties)

find_package(BCM)

include(BCMProperties)
include(BCMSetupVersion) if(CMAKE_SOURCES_DIR)     set(CURRENT_SOURCES_DIR ${CMAKE_SOURCES_DIR}/libs/${CURRENT_PROJECT_NAME}) endif()
include(BCMDeploy)
include(BCMTest)

cm_setup_version(VERSION 1.0)

add_library(simple INTERFACE)

cm_install_targets(TARGETS simple INCLUDE include)
cm_auto_export(TARGETS simple)
cm_auto_pkgconfig(TARGET simple)

if(MSVC)
    add_compile_options(/we4541)
    add_compile_options(/we4530)
endif()

cm_test_link_libraries(simple)

cm_test(NAME simpletest SOURCES test.cpp)

cm_test(NAME rttitest SOURCES test.cpp)
set_target_properties(rttitest PROPERTIES CXX_RTTI Off)

cm_test(NAME exceptiontest SOURCES test.cpp)
set_target_properties(exceptiontest PROPERTIES CXX_EXCEPTIONS Off)

cm_test(NAME statictest SOURCES test.cpp)
set_target_properties(statictest PROPERTIES CXX_STATIC_RUNTIME On)

cm_test(NAME throw SOURCES throw.cpp COMPILE_ONLY WILL_FAIL)
set_target_properties(throw PROPERTIES CXX_EXCEPTIONS Off)

cm_test(NAME throwpass SOURCES throw.cpp)
set_target_properties(throwpass PROPERTIES CXX_EXCEPTIONS On)

cm_test(NAME rtti SOURCES rtti.cpp COMPILE_ONLY WILL_FAIL)
set_target_properties(rtti PROPERTIES CXX_RTTI Off)

cm_test(NAME rttipass SOURCES rtti.cpp)
set_target_properties(rttipass PROPERTIES CXX_RTTI On)

foreach(WARNING_LEVEL off on all)
    cm_test(NAME warnings-${WARNING_LEVEL} SOURCES warnings.cpp)
    set_target_properties(warnings-${WARNING_LEVEL} PROPERTIES CXX_WARNINGS ${WARNING_LEVEL})

    if(WARNING_LEVEL STREQUAL "off")
        cm_test(NAME warnings-errors-${WARNING_LEVEL} SOURCES warnings.cpp COMPILE_ONLY)
    else()
        cm_test(NAME warnings-errors-${WARNING_LEVEL} SOURCES warnings.cpp COMPILE_ONLY WILL_FAIL)
    endif()
    set_target_properties(warnings-errors-${WARNING_LEVEL} PROPERTIES CXX_WARNINGS ${WARNING_LEVEL})
    set_target_properties(warnings-errors-${WARNING_LEVEL} PROPERTIES CXX_WARNINGS_AS_ERRORS On)

    cm_test(NAME nowarnings-${WARNING_LEVEL} SOURCES nowarnings.cpp)
    set_target_properties(nowarnings-${WARNING_LEVEL} PROPERTIES CXX_WARNINGS ${WARNING_LEVEL})

    cm_test(NAME nowarnings-errors-${WARNING_LEVEL} SOURCES nowarnings.cpp)
    set_target_properties(nowarnings-errors-${WARNING_LEVEL} PROPERTIES CXX_WARNINGS ${WARNING_LEVEL})
    set_target_properties(nowarnings-errors-${WARNING_LEVEL} PROPERTIES CXX_WARNINGS_AS_ERRORS On)
endforeach()
