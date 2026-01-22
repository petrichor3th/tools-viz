# ==============================================================================
# Tools Viz 构建宏
# 提供统一的应用程序和插件构建接口
# ==============================================================================

# ==============================================================================
# add_tools_viz_app - 应用程序构建宏
# 用法: add_tools_viz_app(应用名 SOURCES src1.cpp src2.cpp... [WIN32_APP] [EXTRA_LIBS lib1 lib2...])
# ==============================================================================
function(add_tools_viz_app APP_NAME)
    set(options WIN32_APP)
    set(oneValueArgs "")
    set(multiValueArgs SOURCES EXTRA_LIBS)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # 如果没有使用 SOURCES 关键字，使用未解析的参数
    if(NOT ARG_SOURCES)
        set(ARG_SOURCES ${ARG_UNPARSED_ARGUMENTS})
    endif()

    # 创建可执行文件
    if(ARG_WIN32_APP AND WIN32)
        add_executable(${APP_NAME} WIN32 ${ARG_SOURCES})
    else()
        add_executable(${APP_NAME} ${ARG_SOURCES})
    endif()

    # 链接库
    target_link_libraries(${APP_NAME} PRIVATE
        ToolsVizCore
        Qt6::Core
        Qt6::Widgets
        Qt6::Quick
        Qt6::QuickWidgets
        ${ARG_EXTRA_LIBS}
    )

    # 包含目录
    target_include_directories(${APP_NAME} PRIVATE
        ${CMAKE_SOURCE_DIR}/core/include
    )

    # 输出目录
    set_target_properties(${APP_NAME} PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
    )

    # IDE 文件夹
    set_target_properties(${APP_NAME} PROPERTIES FOLDER "Applications")
endfunction()

# ==============================================================================
# add_tools_viz_plugin - 插件构建宏
# 用法: add_tools_viz_plugin(插件名 SOURCES src1.cpp... [QML_FILES qml1.qml...] [EXTRA_LIBS lib1...])
# ==============================================================================
function(add_tools_viz_plugin PLUGIN_NAME)
    set(options "")
    set(oneValueArgs "")
    set(multiValueArgs SOURCES QML_FILES EXTRA_LIBS)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # 如果没有使用 SOURCES 关键字，使用未解析的参数
    if(NOT ARG_SOURCES)
        set(ARG_SOURCES ${ARG_UNPARSED_ARGUMENTS})
    endif()

    # 创建模块库
    add_library(${PLUGIN_NAME} MODULE ${ARG_SOURCES})

    # 链接库
    target_link_libraries(${PLUGIN_NAME} PRIVATE
        ToolsVizCore
        Qt6::Core
        Qt6::Widgets
        Qt6::Quick
        ${ARG_EXTRA_LIBS}
    )

    # 包含目录
    target_include_directories(${PLUGIN_NAME} PRIVATE
        ${CMAKE_SOURCE_DIR}/core/include
    )

    # 输出目录
    set_target_properties(${PLUGIN_NAME} PROPERTIES
        LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin/plugins"
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin/plugins"
    )

    # IDE 文件夹
    set_target_properties(${PLUGIN_NAME} PROPERTIES FOLDER "Plugins")

    # Windows: 移除 lib 前缀
    if(WIN32)
        set_target_properties(${PLUGIN_NAME} PROPERTIES PREFIX "")
    endif()

    # 复制 QML 文件
    if(ARG_QML_FILES)
        foreach(QML_FILE ${ARG_QML_FILES})
            get_filename_component(QML_NAME ${QML_FILE} NAME)
            add_custom_command(TARGET ${PLUGIN_NAME} POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy
                    "${QML_FILE}"
                    "${CMAKE_BINARY_DIR}/bin/plugins/${QML_NAME}"
                COMMENT "Copying ${QML_NAME} to plugins directory"
            )
        endforeach()
    endif()
endfunction()
