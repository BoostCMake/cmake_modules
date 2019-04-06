
if (NOT TARGET packages)
    add_custom_target(packages COMMENT "Build all packages.")
endif ()

function(cm_mark_as_packages)
    foreach (TEST_TARGET ${ARGN})
        add_dependencies(packages ${TEST_TARGET})
    endforeach()
endfunction(cm_mark_as_packages)

function(cm_cpack)

    set(CPACK_GENERATOR "TBZ2")
    set(CPACK_BUILD_SOURCE_DIRS  "${CURRENT_SOURCES_DIR};${CMAKE_CURRENT_BINARY_DIR}")
    set(CPACK_PROPERTIES_FILE ${CMAKE_CURRENT_BINARY_DIR}/CPackProperties.cmake)
    set(CPACK_INSTALL_CMAKE_PROJECTS ${CMAKE_CURRENT_BINARY_DIR}; ${PROJECT_NAME}; ALL; /)
    set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${PROJECT_NAME} for test")
    set(CPACK_PACKAGE_FILE_NAME "${PROJECT_NAME}")
    set(CPACK_PACKAGE_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
    set(CPACK_PACKAGE_VERSION_MINOR ${PROJECT_VERSION_MINOR})
    set(CPACK_PACKAGE_VERSION_PATCH ${PROJECT_VERSION_PATCH})
    set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH})
    set(CPACK_PACKAGE_NAME "${PROJECT_NAME}")
    set(CPACK_PACKAGE_CONTACT "Contact")
    set(CPACK_OUTPUT_CONFIG_FILE "${CMAKE_CURRENT_BINARY_DIR}/CPackConfig.cmake")

    set(TARGET_NAME lib${WORKSPACE_NAME}-${PROJECT_NAME}${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}-dev)
    add_custom_target(${TARGET_NAME}
            COMMAND "${CMAKE_CPACK_COMMAND}"
            "-C" "$<CONFIGURATION>" "--config" "${CMAKE_CURRENT_BINARY_DIR}/CPackConfig.cmake")

    cm_mark_as_packages(${TARGET_NAME})

    include(CPack)

endfunction()

