# ==============================================================================
#                         SuperBuild 入口文件
# ==============================================================================
#
# 此文件管理所有第三方依赖的自动化构建
#
# 目录结构:
#   superbuild/
#   ├── Versions.cmake      # 版本集中管理
#   ├── Macros.cmake        # 宏定义和辅助函数
#   ├── deps/               # 依赖配置（带版本号命名）
#   │   ├── zlib-1.3.1.cmake
#   │   ├── curl-8.18.0.cmake
#   │   ├── libtiff-4.7.1.cmake
#   │   ├── sqlite-3.50.2.cmake
#   │   ├── proj-9.4.1.cmake
#   │   ├── gdal-3.12.1.cmake
#   │   ├── glew-2.3.1.cmake
#   │   ├── osg-3.6.5.cmake
#   │   └── osgearth-3.7.2.cmake
#   └── patches/            # 源码补丁
#       ├── osg-3.6.5-cpp17.cmake
#       └── osgearth-3.7.2-gdal-namespace.cmake
#

cmake_minimum_required(VERSION 3.16)

# ==============================================================================
# 加载核心模块
# ==============================================================================

# 宏和辅助函数
include(${CMAKE_SOURCE_DIR}/superbuild/Macros.cmake)

# 版本定义
include(${CMAKE_SOURCE_DIR}/superbuild/Versions.cmake)

# ==============================================================================
# 依赖加载顺序（按拓扑排序）
# ==============================================================================

message(STATUS "Loading SuperBuild dependencies...")

include(${CMAKE_SOURCE_DIR}/superbuild/deps/zlib-${SB_ZLIB_VERSION}.cmake)
include(${CMAKE_SOURCE_DIR}/superbuild/deps/curl-${SB_CURL_VERSION}.cmake)
include(${CMAKE_SOURCE_DIR}/superbuild/deps/libtiff-${SB_LIBTIFF_VERSION}.cmake)
include(${CMAKE_SOURCE_DIR}/superbuild/deps/sqlite-${SB_SQLITE_VERSION}.cmake)
include(${CMAKE_SOURCE_DIR}/superbuild/deps/proj-${SB_PROJ_VERSION}.cmake)
include(${CMAKE_SOURCE_DIR}/superbuild/deps/gdal-${SB_GDAL_VERSION}.cmake)
include(${CMAKE_SOURCE_DIR}/superbuild/deps/glew-${SB_GLEW_VERSION}.cmake)
include(${CMAKE_SOURCE_DIR}/superbuild/deps/osg-${SB_OSG_VERSION}.cmake)
include(${CMAKE_SOURCE_DIR}/superbuild/deps/osgearth-${SB_OSGEARTH_VERSION}.cmake)

# ==============================================================================
# 主项目构建
# ==============================================================================

sb_register_dependency(ToolsViz DEPENDS ext_osgearth)
sb_build_install_commands()

ExternalProject_Add(ToolsViz
    DEPENDS ext_osgearth
    PREFIX ${SB_PREFIX}/toolsviz
    SOURCE_DIR ${CMAKE_SOURCE_DIR}/src
    CMAKE_ARGS
        -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
        -DCMAKE_CXX_STANDARD:STRING=17
        -DCMAKE_PREFIX_PATH:PATH=${SB_INSTALL_DIR}
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_BINARY_DIR}/output
        -DOSG_DIR:PATH=${SB_INSTALL_DIR}
        -DOpenSceneGraph_DIR:PATH=${SB_INSTALL_DIR}
        -DosgEarth_DIR:PATH=${SB_INSTALL_DIR}/lib/cmake/osgEarth
        -DQt6_DIR:PATH=${Qt6_DIR}
    BUILD_COMMAND ${SB_BUILD_CMD}
    INSTALL_COMMAND ""
    LOG_CONFIGURE TRUE
    LOG_BUILD TRUE
)

# ==============================================================================
# 配置输出
# ==============================================================================

sb_print_summary()

# 生成依赖图（可选）
option(SB_GENERATE_DEPENDENCY_GRAPH "Generate dependency graph DOT file" OFF)
if(SB_GENERATE_DEPENDENCY_GRAPH)
    sb_generate_dependency_graph("${CMAKE_BINARY_DIR}/dependency_graph.dot")
endif()
