# ==============================================================================
# ToolsViz 文档构建脚本
# ==============================================================================
#
# 使用方法:
#   cmake -P docs/build_docs.cmake
#
# 前置要求:
#   - 安装 Doxygen (https://www.doxygen.nl/)
#   - Windows: choco install doxygen.install
#   - Linux: apt install doxygen
#
# ==============================================================================

cmake_minimum_required(VERSION 3.16)

# 查找 Doxygen
find_program(DOXYGEN_EXECUTABLE doxygen)

if(NOT DOXYGEN_EXECUTABLE)
    message(FATAL_ERROR "Doxygen not found! Please install Doxygen first.")
endif()

message(STATUS "Found Doxygen: ${DOXYGEN_EXECUTABLE}")

# 获取脚本所在目录
get_filename_component(DOCS_DIR "${CMAKE_CURRENT_LIST_DIR}" ABSOLUTE)
get_filename_component(PROJECT_ROOT "${DOCS_DIR}/.." ABSOLUTE)

# 确保输出目录存在
file(MAKE_DIRECTORY "${DOCS_DIR}/api/html")

# 切换到项目根目录执行 Doxygen
message(STATUS "Generating API documentation...")
execute_process(
    COMMAND ${DOXYGEN_EXECUTABLE} "${DOCS_DIR}/Doxyfile"
    WORKING_DIRECTORY "${PROJECT_ROOT}"
    RESULT_VARIABLE DOXYGEN_RESULT
)

if(DOXYGEN_RESULT EQUAL 0)
    message(STATUS "Documentation generated successfully!")
    message(STATUS "Output: ${DOCS_DIR}/api/html/index.html")
else()
    message(FATAL_ERROR "Doxygen failed with code: ${DOXYGEN_RESULT}")
endif()
