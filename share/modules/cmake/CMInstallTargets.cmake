include(GNUInstallDirs)

function(cm_install_targets)
    set(options SKIP_HEADER_INSTALL)
    set(oneValueArgs EXPORT)
    set(multiValueArgs TARGETS INCLUDE)

    cmake_parse_arguments(PARSE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    string(TOLOWER ${PROJECT_NAME} PROJECT_NAME_LOWER)
    if(CMAKE_WORKSPACE_NAME)
        string(TOLOWER ${CMAKE_WORKSPACE_NAME} CMAKE_WORKSPACE_NAME_LOWER)
        set(EXPORT_FILE ${CMAKE_WORKSPACE_NAME_LOWER}_${PROJECT_NAME_LOWER}-targets)
    else()
        set(EXPORT_FILE ${PROJECT_NAME_LOWER}-targets)
    endif()
    if(PARSE_EXPORT)
        set(EXPORT_FILE ${PARSE_EXPORT})
    endif()

    set(BIN_INSTALL_DIR ${CMAKE_INSTALL_BINDIR})
    set(LIB_INSTALL_DIR ${CMAKE_INSTALL_LIBDIR})
    set(INCLUDE_INSTALL_DIR ${CMAKE_INSTALL_INCLUDEDIR})

    foreach(TARGET ${PARSE_TARGETS})
        foreach(INCLUDE ${PARSE_INCLUDE})
            get_filename_component(INCLUDE_PATH ${INCLUDE} ABSOLUTE)
            target_include_directories(${TARGET} INTERFACE $<BUILD_INTERFACE:${INCLUDE_PATH}>)
        endforeach()
        target_include_directories(${TARGET} INTERFACE $<INSTALL_INTERFACE:${INCLUDE_INSTALL_DIR}>)
    endforeach()


    if(NOT PARSE_SKIP_HEADER_INSTALL)
        foreach(INCLUDE ${PARSE_INCLUDE})
            install(DIRECTORY ${INCLUDE}/ DESTINATION ${INCLUDE_INSTALL_DIR})
        endforeach()
    endif()

    install(TARGETS ${PARSE_TARGETS}
            EXPORT ${EXPORT_FILE}
            RUNTIME DESTINATION ${BIN_INSTALL_DIR}
            LIBRARY DESTINATION ${LIB_INSTALL_DIR}
            ARCHIVE DESTINATION ${LIB_INSTALL_DIR})

endfunction()
