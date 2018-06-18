list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})
include(BCMFuture)
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

macro(cm_project INPUT_WORKSPACE_NAME INPUT_PROJECT_NAME)
    set(options)
    set(oneValueArgs DESCRIPTION VERSION)
    set(multiValueArgs LANGUAGES)

    cmake_parse_arguments(PARSE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(PARSE_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Unknown keywords given to workspace(): \"${PARSE_UNPARSED_ARGUMENTS}\"")
    endif()

    project(${INPUT_WORKSPACE_NAME}_${INPUT_PROJECT_NAME} ${PARSE_VERSION} ${PARSE_DESCRIPTION} ${PARSE_LANGUAGES})
    set(CURRENT_PROJECT_NAME ${INPUT_PROJECT_NAME})
    string(TOUPPER ${INPUT_PROJECT_NAME} UPPER_PROJECT_NAME)
    set(CURRENT_UPPER_PROJECT_NAME ${UPPER_PROJECT_NAME})
endmacro()

macro(cm_workspace WORKSPACE_NAME)
    set(options)
    set(oneValueArgs DESCRIPTION VERSION)
    set(multiValueArgs LANGUAGES)

    cmake_parse_arguments(PARSE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(PARSE_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Unknown keywords given to workspace(): \"${PARSE_UNPARSED_ARGUMENTS}\"")
    endif()

    project(${WORKSPACE_NAME} ${PARSE_VERSION} ${PARSE_DESCRIPTION} ${PARSE_LANGUAGES})
    set(CMAKE_WORKSPACE_NAME ${WORKSPACE_NAME})
    string(TOUPPER ${WORKSPACE_NAME} UPPER_WORKSPACE_NAME)
    set(CMAKE_UPPER_WORKSPACE_NAME ${UPPER_WORKSPACE_NAME})
endmacro()

function(patch_file INPUT_SOURCE INPUT_PATCH OUTPUT_DIRECTORY)
    find_package(Patch)
    if(NOT Patch_FOUND)
        message(FATAL_ERROR "Patch utulity is not found")
    endif()

    execute_process(COMMAND patch ${INPUT_SOURCE} ${INPUT_PATCH}
                    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
endfunction()

function(patch_directory SOURCES_DIRECTORY PATCHES_DIRECTORY OUTPUT_DIRECTORY)
    find_package(Patch)
    if(NOT Patch_FOUND)
        message(FATAL_ERROR "Patch utulity is not found")
    endif()

    file(GLOB_RECURSE ${PATCHES_FILES} LIST_DIRECTORIES FALSE ${PATCHES_DIRECTORY})
    file(GLOB_RECURSE ${SOURCES_FILES} LIST_DIRECTORIES FALSE ${SOURCES_DIRECTORY})

    foreach(PATCH_FILE IN PATCHES_FILES)
        string(REPLACE ".patch" ${PATCH_FILE} PATCH_FILE_NAME)
        list(FIND ${SOURCES_FILES} PATCH_FILE)
        execute_process(COMMAND patch)
    endforeach()
endfunction()