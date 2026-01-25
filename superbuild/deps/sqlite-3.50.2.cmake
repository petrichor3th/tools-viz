# ==============================================================================
# SQLite 3.50.2 - 嵌入式数据库
# ==============================================================================
# 官方网站: https://www.sqlite.org
# 功能: PROJ 的必需依赖，用于 EPSG 坐标系统数据库
# 注: 使用官方 amalgamation 源码 + 自定义 CMakeLists.txt
# ==============================================================================

sb_verify_version(sqlite "3.50.2")
sb_get_external_info(sqlite VERSION SB_SQLITE_VERSION SOURCE_ARGS SB_SQLITE_SRC)
sb_register_dependency(ext_sqlite3)
sb_build_install_commands()

# ------------------------------------------------------------------------------
# 生成自定义 CMakeLists.txt（SQLite 官方不提供 CMake 构建）
# ------------------------------------------------------------------------------
set(_SQLITE3_CMAKELISTS_CONTENT [=[
cmake_minimum_required(VERSION 3.16)
project(sqlite3 VERSION 3.50.2 LANGUAGES C)

# 编译选项 - 启用高级功能
add_compile_definitions(
    SQLITE_ENABLE_RTREE           # R-Tree 空间索引
    SQLITE_ENABLE_FTS5            # 全文搜索 v5
    SQLITE_ENABLE_COLUMN_METADATA # 列元数据 API
    SQLITE_ENABLE_DBSTAT_VTAB     # 数据库统计虚表
    SQLITE_ENABLE_JSON1           # JSON 扩展
    SQLITE_ENABLE_UNLOCK_NOTIFY   # 解锁通知
    SQLITE_ENABLE_DESERIALIZE     # 序列化/反序列化
)

# 共享库
add_library(sqlite3 SHARED sqlite3.c)
target_include_directories(sqlite3 PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:include>
)
if(WIN32)
    target_compile_definitions(sqlite3 PRIVATE SQLITE_API=__declspec\(dllexport\))
endif()
set_target_properties(sqlite3 PROPERTIES
    PUBLIC_HEADER sqlite3.h
    VERSION ${PROJECT_VERSION}
    SOVERSION 0
)

# 命令行工具 (sqlite3.exe)
add_executable(sqlite3_shell shell.c)
target_link_libraries(sqlite3_shell PRIVATE sqlite3)
set_target_properties(sqlite3_shell PROPERTIES OUTPUT_NAME sqlite3)

# 安装
include(GNUInstallDirs)
install(TARGETS sqlite3 sqlite3_shell
    EXPORT sqlite3Targets
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)
install(EXPORT sqlite3Targets
    FILE sqlite3-config.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/sqlite3
)
]=])

file(WRITE "${CMAKE_BINARY_DIR}/sqlite3_CMakeLists.txt" "${_SQLITE3_CMAKELISTS_CONTENT}")

# ------------------------------------------------------------------------------
# ExternalProject 配置
# ------------------------------------------------------------------------------
ExternalProject_Add(ext_sqlite3
    PREFIX ${SB_PREFIX}/sqlite-${SB_SQLITE_VERSION}
    ${SB_SQLITE_SRC}
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
    PATCH_COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_BINARY_DIR}/sqlite3_CMakeLists.txt" <SOURCE_DIR>/CMakeLists.txt
    CMAKE_ARGS
        ${SB_CMAKE_ARGS}
    BUILD_COMMAND ${SB_BUILD_CMD}
    INSTALL_COMMAND ${SB_INSTALL_CMD}
    ${SB_LOG_ARGS}
)

# 导出变量
set(SB_SQLITE3_LIBRARY "${SB_INSTALL_DIR}/lib/sqlite3.lib" CACHE FILEPATH "SQLite3 library")
set(SB_SQLITE3_INCLUDE_DIR "${SB_INSTALL_DIR}/include" CACHE PATH "SQLite3 include directory")
