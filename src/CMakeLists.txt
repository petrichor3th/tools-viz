cmake_minimum_required(VERSION 3.16)

project(ToolsViz VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# ==============================================================================
# IDE 文件夹支持
# ==============================================================================
set_property(GLOBAL PROPERTY USE_FOLDERS ON)
set_property(GLOBAL PROPERTY AUTOGEN_TARGETS_FOLDER "Autogen Targets")
set_property(GLOBAL PROPERTY AUTOGEN_SOURCE_GROUP "Generated Files")

# ==============================================================================
# Qt 自动化
# ==============================================================================
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

# ==============================================================================
# 查找依赖
# ==============================================================================
# Qt6
find_package(Qt6 REQUIRED COMPONENTS Core Widgets Quick QuickWidgets)

# OpenSceneGraph（可选）
find_package(OpenSceneGraph QUIET COMPONENTS osg osgDB osgViewer osgGA osgUtil)
if(OPENSCENEGRAPH_FOUND)
    message(STATUS "Found OpenSceneGraph: ${OPENSCENEGRAPH_VERSION}")
endif()

# osgEarth（可选）
find_package(osgEarth QUIET)
if(osgEarth_FOUND)
    message(STATUS "Found osgEarth")
endif()

# ==============================================================================
# 输出目录
# ==============================================================================
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# ==============================================================================
# 包含构建宏
# ==============================================================================
include(${CMAKE_CURRENT_SOURCE_DIR}/../cmake/BuildMacros.cmake)

# ==============================================================================
# 添加子目录
# ==============================================================================
add_subdirectory(core)
add_subdirectory(app)
add_subdirectory(plugins)
