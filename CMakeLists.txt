cmake_minimum_required(VERSION 3.16)

project(ToolsViz-SuperBuild LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# ==============================================================================
# SuperBuild 选项
# ==============================================================================
option(USE_SUPERBUILD "Use SuperBuild to build dependencies from source" ON)
option(BUILD_OSGEARTH "Build OpenSceneGraph and osgEarth from source" ON)

# ==============================================================================
# SuperBuild 模式：使用 ExternalProject 管理依赖
# ==============================================================================
if(USE_SUPERBUILD AND BUILD_OSGEARTH)
    message(STATUS "SuperBuild mode enabled - building dependencies from source")
    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/Externals.cmake)
else()
    # ==============================================================================
    # 直接构建模式：假设依赖已安装
    # ==============================================================================
    message(STATUS "Direct build mode - assuming dependencies are installed")
    add_subdirectory(src)
endif()
