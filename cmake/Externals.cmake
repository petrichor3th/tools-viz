# ==============================================================================
# ExternalProject 配置 - 管理 OSG 和 osgEarth 依赖
# ==============================================================================

include(ExternalProject)

# 外部项目安装目录
set(EP_PREFIX "${CMAKE_BINARY_DIR}/externals")
set(EP_INSTALL_DIR "${CMAKE_BINARY_DIR}/install")

# 确保安装目录存在
file(MAKE_DIRECTORY ${EP_INSTALL_DIR})

# 通用 CMake 参数
set(EP_CMAKE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=${EP_INSTALL_DIR}
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DCMAKE_CXX_STANDARD:STRING=17
    -DCMAKE_PREFIX_PATH:PATH=${EP_INSTALL_DIR}
    -DCMAKE_POLICY_DEFAULT_CMP0091:STRING=NEW
)

# 针对旧版项目的 CMake 兼容性参数（解决 CMake 4.x 移除 < 3.5 兼容性的问题）
set(EP_CMAKE_COMPAT_ARGS
    -DCMAKE_POLICY_VERSION_MINIMUM:STRING=3.5
)

# Windows MSVC 运行时库设置
if(MSVC)
    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
        list(APPEND EP_CMAKE_ARGS -DCMAKE_MSVC_RUNTIME_LIBRARY:STRING=MultiThreadedDebugDLL)
    else()
        list(APPEND EP_CMAKE_ARGS -DCMAKE_MSVC_RUNTIME_LIBRARY:STRING=MultiThreadedDLL)
    endif()
endif()

# ==============================================================================
# OpenSceneGraph
# 注：OSG 3.6.5 使用 CMAKE_MINIMUM_REQUIRED(VERSION 2.8.0)，需要添加兼容性参数
# 补丁：修复 C++17 兼容性问题（std::byte 冲突、std::mem_fun_ref 移除）
# ==============================================================================
ExternalProject_Add(ext_osg
    PREFIX ${EP_PREFIX}/osg
    GIT_REPOSITORY https://github.com/openscenegraph/OpenSceneGraph.git
    GIT_TAG OpenSceneGraph-3.6.5
    GIT_SHALLOW TRUE
    GIT_PROGRESS TRUE
    PATCH_COMMAND ${CMAKE_COMMAND} -DSOURCE_DIR=<SOURCE_DIR> -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/patches/osg_cpp17_fixes.cmake
    CMAKE_ARGS
        ${EP_CMAKE_ARGS}
        ${EP_CMAKE_COMPAT_ARGS}
        -DBUILD_OSG_APPLICATIONS:BOOL=OFF
        -DBUILD_OSG_EXAMPLES:BOOL=OFF
        -DOSG_USE_QT:BOOL=OFF
        -DOSG_GL3_AVAILABLE:BOOL=ON
        -DOPENGL_PROFILE:STRING=GL3
    BUILD_COMMAND ${CMAKE_COMMAND} --build <BINARY_DIR> --config $<CONFIG> --parallel
    INSTALL_COMMAND ${CMAKE_COMMAND} --build <BINARY_DIR> --config $<CONFIG> --target install
    LOG_DOWNLOAD TRUE
    LOG_CONFIGURE TRUE
    LOG_BUILD TRUE
    LOG_INSTALL TRUE
)

# ==============================================================================
# osgEarth 3.7.2 (最新稳定版)
# ==============================================================================
ExternalProject_Add(ext_osgearth
    DEPENDS ext_osg
    PREFIX ${EP_PREFIX}/osgearth
    GIT_REPOSITORY https://github.com/gwaldron/osgearth.git
    GIT_TAG osgearth-3.7.2
    GIT_SHALLOW TRUE
    GIT_PROGRESS TRUE
    CMAKE_ARGS
        ${EP_CMAKE_ARGS}
        -DOSG_DIR:PATH=${EP_INSTALL_DIR}
        -DOpenSceneGraph_DIR:PATH=${EP_INSTALL_DIR}
        -DOSGEARTH_BUILD_EXAMPLES:BOOL=OFF
        -DOSGEARTH_BUILD_TESTS:BOOL=OFF
        -DOSGEARTH_BUILD_DOCS:BOOL=OFF
        -DOSGEARTH_BUILD_PROCEDURAL_NODEKIT:BOOL=OFF
        -DOSGEARTH_BUILD_TRITON_NODEKIT:BOOL=OFF
        -DOSGEARTH_BUILD_SILVERLINING_NODEKIT:BOOL=OFF
    BUILD_COMMAND ${CMAKE_COMMAND} --build <BINARY_DIR> --config $<CONFIG> --parallel
    INSTALL_COMMAND ${CMAKE_COMMAND} --build <BINARY_DIR> --config $<CONFIG> --target install
    LOG_DOWNLOAD TRUE
    LOG_CONFIGURE TRUE
    LOG_BUILD TRUE
    LOG_INSTALL TRUE
)

# ==============================================================================
# 主项目 ToolsViz
# ==============================================================================
ExternalProject_Add(ToolsViz
    DEPENDS ext_osgearth
    PREFIX ${EP_PREFIX}/toolsviz
    SOURCE_DIR ${CMAKE_SOURCE_DIR}/src
    CMAKE_ARGS
        -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
        -DCMAKE_CXX_STANDARD:STRING=17
        -DCMAKE_PREFIX_PATH:PATH=${EP_INSTALL_DIR}
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_BINARY_DIR}/output
        -DOSG_DIR:PATH=${EP_INSTALL_DIR}
        -DOpenSceneGraph_DIR:PATH=${EP_INSTALL_DIR}
        -DosgEarth_DIR:PATH=${EP_INSTALL_DIR}/lib/cmake/osgEarth
    BUILD_COMMAND ${CMAKE_COMMAND} --build <BINARY_DIR> --config $<CONFIG> --parallel
    INSTALL_COMMAND ""
    LOG_CONFIGURE TRUE
    LOG_BUILD TRUE
)

# ==============================================================================
# 输出配置信息
# ==============================================================================
message(STATUS "=== SuperBuild Configuration ===")
message(STATUS "External projects prefix: ${EP_PREFIX}")
message(STATUS "Install directory: ${EP_INSTALL_DIR}")
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
