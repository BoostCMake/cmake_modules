list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})
include(CMFuture)
enable_testing()

function(find_subdirectories INPUT_DIRECTORY SUBMODULE_HEADER)
    file(GLOB_RECURSE LIBS ${INPUT_DIRECTORY}/*CMakeLists.txt)
    foreach(lib ${LIBS})
        file(READ ${lib} CONTENT)
        if("${CONTENT}" MATCHES ${SUBMODULE_HEADER})
            get_filename_component(LIB_DIR ${lib} DIRECTORY)
            get_filename_component(LIB_NAME ${LIB_DIR} NAME)
            if(NOT "${LIB_NAME}" IN_LIST EXCLUDE_LIBS)
                add_subdirectory(${LIB_DIR})
            endif()
        endif()
    endforeach()
endfunction()

function(cm_project INPUT_WORKSPACE_NAME INPUT_PROJECT_NAME)
    set(options)
    set(oneValueArgs DESCRIPTION VERSION)
    set(multiValueArgs LANGUAGES)

    cmake_parse_arguments(PARSE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(PARSE_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Unknown keywords given to workspace(): \"${PARSE_UNPARSED_ARGUMENTS}\"")
    endif()

    project(${INPUT_WORKSPACE_NAME}_${INPUT_PROJECT_NAME} ${PARSE_VERSION} ${PARSE_DESCRIPTION} ${PARSE_LANGUAGES})

    set(CURRENT_PROJECT_NAME ${INPUT_PROJECT_NAME} PARENT_SCOPE)
    set(CMAKE_PROJECT_NAME ${CMAKE_PROJECT_NAME} PARENT_SCOPE)
    set(PROJECT_NAME ${INPUT_PROJECT_NAME} PARENT_SCOPE)

    string(TOUPPER ${INPUT_PROJECT_NAME} UPPER_PROJECT_NAME)
    set(CURRENT_UPPER_PROJECT_NAME ${UPPER_PROJECT_NAME} PARENT_SCOPE)

    file(RELATIVE_PATH RELATIVE_DIR ${CMAKE_WORKSPACE_DIR} ${CMAKE_CURRENT_SOURCE_DIR})

    set(CURRENT_SOURCES_DIR ${CMAKE_WORKSPACE_SOURCES_DIR}/${RELATIVE_DIR} PARENT_SCOPE)
    set(CURRENT_TEST_SOURCES_DIR ${CMAKE_WORKSPACE_SOURCES_DIR}/${RELATIVE_DIR}/test PARENT_SCOPE)
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
    set(PROJECT_NAME ${WORKSPACE_NAME} PARENT_SCOPE)
    set(CMAKE_PROJECT_NAME ${WORKSPACE_NAME} PARENT_SCOPE)
    set(CMAKE_WORKSPACE_NAME ${WORKSPACE_NAME} PARENT_SCOPE)
    set(CMAKE_WORKSPACE_DIR ${CMAKE_CURRENT_SOURCE_DIR} PARENT_SCOPE)
    string(TOUPPER ${WORKSPACE_NAME} UPPER_WORKSPACE_NAME)
    set(CMAKE_UPPER_WORKSPACE_NAME ${UPPER_WORKSPACE_NAME} PARENT_SCOPE)

    if(PARSE_SOURCES_DIR)
        set(CMAKE_WORKSPACE_SOURCES_DIR ${PARSE_SOURCES_DIR} PARENT_SCOPE)
    endif()
endfunction()

function(patch_file INPUT_SOURCE INPUT_PATCH OUTPUT_DIRECTORY)
    find_package(Patch)
    if(NOT Patch_FOUND)
        message(FATAL_ERROR "Patch utulity is not found")
    endif()
    string(REPLACE ${CURRENT_TEST_SOURCES_DIR} ${CMAKE_CURRENT_BINARY_DIR} OUTPUT_FILE ${INPUT_SOURCE})
    get_filename_component(OUTPUT_DIRECTORY ${OUTPUT_FILE} DIRECTORY)
    file(COPY ${INPUT_SOURCE} DESTINATION ${OUTPUT_DIRECTORY})
    get_filename_component(SOURCE_FILE_NAME ${INPUT_SOURCE} NAME)
    execute_process(COMMAND patch ${OUTPUT_FILE} ${INPUT_PATCH}
                    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
endfunction()

function(patch_directory SOURCES_DIRECTORY PATCHES_DIRECTORY OUTPUT_DIRECTORY)
    find_package(Patch)
    if(NOT Patch_FOUND)
        message(FATAL_ERROR "Patch utulity is not found")
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

        patch_file(${SOURCE_FILE} ${PATCH_FILE} ${OUTPUT_FILE_DIRECTORY})
    endforeach()
endfunction()