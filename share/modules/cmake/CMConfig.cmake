list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})
include(CMFuture)
enable_testing()

function(contains_path FILEPATH SUBPATH RESULT)
    file(RELATIVE_PATH PATH "${SUBPATH}" "${FILEPATH}")
    if(${PATH} MATCHES "\\.\\./")
        set(${RESULT} FALSE PARENT_SCOPE)
    else()
        set(${RESULT} TRUE PARENT_SCOPE)
    endif()
endfunction()

function(add_subdirectories curdir)
    file(GLOB children RELATIVE ${curdir} ${curdir}/*)
    set(dirlist "")
    foreach(child ${children})
        if(IS_DIRECTORY ${curdir}/${child})
            file(GLOB is_subproject ${curdir}/${child}/*CMakeLists.txt)
            if(is_subproject)
                add_subdirectory(${curdir}/${child})
            endif()
        endif()
    endforeach()
endfunction()

function(cm_project INPUT_PROJECT_NAME)
    set(options)
    set(oneValueArgs DESCRIPTION VERSION WORKSPACE_NAME)
    set(multiValueArgs LANGUAGES)

    cmake_parse_arguments(PARSE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(PARSE_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Unknown keywords given to workspace(): \"${PARSE_UNPARSED_ARGUMENTS}\"")
    endif()

    if(PARSE_WORKSPACE_NAME)
        if(PARSE_VERSION AND PARSE_LANGUAGES AND PARSE_DESCRIPTION)
            project(${INPUT_WORKSPACE_NAME}_${INPUT_PROJECT_NAME}
                    VERSION ${PARSE_VERSION}
                    DESCRIPTION ${PARSE_DESCRIPTION}
                    LANGUAGES ${PARSE_LANGUAGES})
        elseif(PARSE_LANGUAGES)
            project(${INPUT_WORKSPACE_NAME}_${INPUT_PROJECT_NAME} ${PARSE_LANGUAGES})
        else()
            project(${INPUT_WORKSPACE_NAME}_${INPUT_PROJECT_NAME})
        endif()
    endif()

    set(CURRENT_PROJECT_NAME ${INPUT_PROJECT_NAME} PARENT_SCOPE)
    set(CMAKE_PROJECT_NAME ${CMAKE_PROJECT_NAME} PARENT_SCOPE)
    set(PROJECT_NAME ${INPUT_PROJECT_NAME} PARENT_SCOPE)

    string(TOUPPER ${INPUT_PROJECT_NAME} UPPER_PROJECT_NAME)
    set(CURRENT_UPPER_PROJECT_NAME ${UPPER_PROJECT_NAME} PARENT_SCOPE)

    if(PARSE_WORKSPACE_NAME)
        file(RELATIVE_PATH RELATIVE_DIR ${CMAKE_WORKSPACE_DIR} ${CMAKE_CURRENT_SOURCE_DIR})

        set(CURRENT_SOURCES_DIR ${CMAKE_WORKSPACE_SOURCES_DIR}/${RELATIVE_DIR} PARENT_SCOPE)
        set(CURRENT_TEST_SOURCES_DIR ${CMAKE_WORKSPACE_SOURCES_DIR}/${RELATIVE_DIR}/test PARENT_SCOPE)
    endif()
endfunction()

function(cm_workspace WORKSPACE_NAME)
    set(options)
    set(oneValueArgs DESCRIPTION VERSION SOURCES_DIR)
    set(multiValueArgs LANGUAGES)

    cmake_parse_arguments(PARSE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(PARSE_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Unknown keywords given to workspace(): \"${PARSE_UNPARSED_ARGUMENTS}\"")
    endif()

    project(${WORKSPACE_NAME} ${PARSE_VERSION} ${PARSE_DESCRIPTION} ${PARSE_LANGUAGES})
    if (NOT PROJECT_NAME)
        set(PROJECT_NAME ${WORKSPACE_NAME} PARENT_SCOPE)
    endif()
    if (NOT CMAKE_PROJECT_NAME)
        set(CMAKE_PROJECT_NAME ${WORKSPACE_NAME} PARENT_SCOPE)
    endif()
    set(CMAKE_WORKSPACE_NAME ${WORKSPACE_NAME} PARENT_SCOPE)
    set(CMAKE_WORKSPACE_LIST ${CMAKE_WORKSPACE_LIST} ${CMAKE_WORKSPACE_NAME} PARENT_SCOPE)
    set(CMAKE_WORKSPACE_DIR ${CMAKE_CURRENT_SOURCE_DIR} PARENT_SCOPE)
    string(TOUPPER ${WORKSPACE_NAME} UPPER_WORKSPACE_NAME)
    set(CMAKE_UPPER_WORKSPACE_NAME ${UPPER_WORKSPACE_NAME} PARENT_SCOPE)

    if(PARSE_SOURCES_DIR)
        set(CMAKE_WORKSPACE_SOURCES_DIR ${PARSE_SOURCES_DIR} PARENT_SCOPE)
    endif()
endfunction()

function(patch_file INPUT_SOURCE INPUT_PATCH OUTPUT_DIRECTORY)
    set(options)
    set(oneValueArgs PREFIX_PATCH_NAME POSTFIX_PATCH_NAME)
    set(multiValueArgs)

    cmake_parse_arguments(PARSE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    find_package(Patch)
    if(NOT Patch_FOUND)
        message("Patch utulity is not found")
    endif()
    string(REPLACE ${CURRENT_TEST_SOURCES_DIR} ${CMAKE_CURRENT_BINARY_DIR} OUTPUT_FILE ${INPUT_SOURCE})
    file(COPY ${INPUT_SOURCE} DESTINATION ${OUTPUT_DIRECTORY})
    get_filename_component(SOURCE_FILE_NAME ${INPUT_SOURCE} NAME)
    set(NEW_SOURCE_FILE_NAME ${PARSE_PREFIX_PATCH_NAME}${SOURCE_FILE_NAME})
    if(PARSE_POSTFIX_PATCH_NAME)
        string(REPLACE . ${PARSE_POSTFIX_PATCH_NAME}. NEW_SOURCE_FILE_NAME ${NEW_SOURCE_FILE_NAME})
    endif()
    file(RENAME ${OUTPUT_DIRECTORY}/${SOURCE_FILE_NAME} ${OUTPUT_DIRECTORY}/${NEW_SOURCE_FILE_NAME})
    execute_process(COMMAND patch ${OUTPUT_DIRECTORY}/${NEW_SOURCE_FILE_NAME} ${INPUT_PATCH}
                    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
endfunction()

function(patch_directory SOURCES_DIRECTORY PATCHES_DIRECTORY OUTPUT_DIRECTORY)
    set(options)
    set(oneValueArgs PREFIX_PATCH_NAME POSTFIX_PATCH_NAME)
    set(multiValueArgs)

    cmake_parse_arguments(PARSE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    find_package(Patch)
    if(NOT Patch_FOUND)
        message("Patch utulity is not found")
    endif()
    file(GLOB_RECURSE PATCHES_FILES LIST_DIRECTORIES FALSE ${PATCHES_DIRECTORY}/*.patch)
    file(GLOB_RECURSE SOURCES_FILES LIST_DIRECTORIES FALSE ${SOURCES_DIRECTORY}/*)
    foreach(PATCH_FILE IN LISTS PATCHES_FILES)
        string(REPLACE ".patch" "" SOURCE_FILE_NAME ${PATCH_FILE})
        string(REPLACE ${PATCHES_DIRECTORY} ${SOURCES_DIRECTORY} SOURCE_FILE_NAME ${SOURCE_FILE_NAME})
        list(FIND SOURCES_FILES ${SOURCE_FILE_NAME} SOURCES_FILE_FIND)
        if(${SOURCES_FILE_FIND} EQUAL -1)
            message(FATAL_ERROR "Source file for patch is not found: " ${PATCH_FILE})
        endif()
        list(GET SOURCES_FILES ${SOURCES_FILE_FIND} SOURCE_FILE)
        string(REPLACE ${SOURCES_DIRECTORY} ${OUTPUT_DIRECTORY} OUTPUT_FILE_DIRECTORY ${SOURCE_FILE})
        get_filename_component(OUTPUT_FILE_DIRECTORY ${OUTPUT_FILE_DIRECTORY} DIRECTORY)
        patch_file(${SOURCE_FILE} ${PATCH_FILE} ${OUTPUT_FILE_DIRECTORY}
                   PREFIX_PATCH_NAME ${PARSE_PREFIX_PATCH_NAME} POSTFIX_PATCH_NAME ${PARSE_POSTFIX_PATCH_NAME})
    endforeach()
endfunction()

macro(cm_find_package NAME)
    foreach(ITERATOR ${CMAKE_WORKSPACE_LIST})
        if(NOT "${NAME}" MATCHES "^${ITERATOR}_.*$" AND NOT "${NAME}" STREQUAL CM)
            find_package(${ARGV})
        else()
            set(${ARGV0}_FOUND ON CACHE BOOL "")
        endif()
    endforeach()
endmacro()