# ==============================================================================
# OSG C++17 兼容性修复补丁
# ==============================================================================
#
# 修复内容：
# 1. std::byte 冲突：C++17 的 std::byte 与 Windows SDK 的 byte 类型冲突
# 2. std::mem_fun_ref 移除：C++17 移除了 std::mem_fun_ref，需替换为 lambda
# 3. _FPOSOFF 宏：较新 MSVC 版本中未定义，需手动定义
# 4. std::ptr_fun/std::not1 移除：C++17 移除，需替换为 lambda
#
# ==============================================================================

# ==============================================================================
# 修复 1: std::byte 冲突
# ==============================================================================
set(OSG_CMAKELISTS "${SOURCE_DIR}/CMakeLists.txt")

if(NOT EXISTS "${OSG_CMAKELISTS}")
    message(FATAL_ERROR "OSG CMakeLists.txt not found: ${OSG_CMAKELISTS}")
endif()

file(READ "${OSG_CMAKELISTS}" CONTENT)

# 检查是否已经添加过补丁
if(NOT CONTENT MATCHES "_HAS_STD_BYTE")
    # 在 PROJECT() 后添加 _HAS_STD_BYTE=0 定义
    string(REGEX REPLACE
        "(PROJECT\\([^)]+\\))"
        "\\1\n\n# [PATCH] Fix C++17 std::byte conflict with Windows SDK byte type\nif(MSVC AND CMAKE_CXX_STANDARD GREATER_EQUAL 17)\n    add_compile_definitions(_HAS_STD_BYTE=0)\nendif()"
        CONTENT "${CONTENT}"
    )
    file(WRITE "${OSG_CMAKELISTS}" "${CONTENT}")
    message(STATUS "OSG std::byte fix applied successfully")
else()
    message(STATUS "OSG std::byte fix already applied")
endif()

# ==============================================================================
# 修复 2: std::mem_fun_ref 移除（C++17）
# ==============================================================================
set(GRAPH_ARRAY_FILE "${SOURCE_DIR}/src/osgUtil/tristripper/include/detail/graph_array.h")

if(EXISTS "${GRAPH_ARRAY_FILE}")
    file(READ "${GRAPH_ARRAY_FILE}" GRAPH_CONTENT)
    
    # 检查是否包含需要修复的代码
    if(GRAPH_CONTENT MATCHES "std::mem_fun_ref")
        # 替换 std::mem_fun_ref 为 lambda 表达式
        string(REPLACE
            "std::mem_fun_ref(&graph_array<N>::node::unmark)"
            "[](typename graph_array<N>::node& n) { n.unmark(); }"
            GRAPH_CONTENT "${GRAPH_CONTENT}"
        )
        file(WRITE "${GRAPH_ARRAY_FILE}" "${GRAPH_CONTENT}")
        message(STATUS "OSG mem_fun_ref fix applied successfully")
    else()
        message(STATUS "OSG mem_fun_ref fix already applied")
    endif()
else()
    message(WARNING "graph_array.h not found: ${GRAPH_ARRAY_FILE}")
endif()

# ==============================================================================
# 修复 3: _FPOSOFF 宏在较新 MSVC 中未定义
# ==============================================================================
set(OSGA_ARCHIVE_FILE "${SOURCE_DIR}/src/osgPlugins/osga/OSGA_Archive.cpp")

if(EXISTS "${OSGA_ARCHIVE_FILE}")
    file(READ "${OSGA_ARCHIVE_FILE}" OSGA_CONTENT)
    
    if(OSGA_CONTENT MATCHES "_FPOSOFF" AND NOT OSGA_CONTENT MATCHES "#ifndef _FPOSOFF")
        # 在文件开头的 #include 后添加 _FPOSOFF 宏定义
        # 在新版本 MSVC 中，fpos_t 是 __int64 基本类型，直接返回其值即可
        string(REGEX REPLACE
            "(#include \"OSGA_Archive.h\")"
            "\\1\n\n// [PATCH] Define _FPOSOFF for newer MSVC versions where fpos_t is __int64\n#ifndef _FPOSOFF\n#define _FPOSOFF(fp) (fp)\n#endif"
            OSGA_CONTENT "${OSGA_CONTENT}"
        )
        file(WRITE "${OSGA_ARCHIVE_FILE}" "${OSGA_CONTENT}")
        message(STATUS "OSG _FPOSOFF fix applied successfully")
    else()
        message(STATUS "OSG _FPOSOFF fix already applied or not needed")
    endif()
else()
    message(WARNING "OSGA_Archive.cpp not found: ${OSGA_ARCHIVE_FILE}")
endif()

# ==============================================================================
# 修复 4: std::ptr_fun 和 std::not1 在 C++17 中被移除
# ==============================================================================
set(OBJ_CPP_FILE "${SOURCE_DIR}/src/osgPlugins/obj/obj.cpp")

if(EXISTS "${OBJ_CPP_FILE}")
    file(READ "${OBJ_CPP_FILE}" OBJ_CONTENT)
    
    if(OBJ_CONTENT MATCHES "std::ptr_fun")
        # 替换 std::not1(std::ptr_fun<...>(...)) 为 lambda
        string(REPLACE
            "std::not1( std::ptr_fun< int, int >( isspace ) )"
            "[](unsigned char c) { return !std::isspace(c); }"
            OBJ_CONTENT "${OBJ_CONTENT}"
        )
        file(WRITE "${OBJ_CPP_FILE}" "${OBJ_CONTENT}")
        message(STATUS "OSG ptr_fun fix applied successfully")
    else()
        message(STATUS "OSG ptr_fun fix already applied")
    endif()
else()
    message(WARNING "obj.cpp not found: ${OBJ_CPP_FILE}")
endif()

# ==============================================================================
# 修复 5: TIFF 插件使用 TIFF_LIBRARY 可能为空
# ==============================================================================
set(TIFF_CMAKELISTS "${SOURCE_DIR}/src/osgPlugins/tiff/CMakeLists.txt")

if(EXISTS "${TIFF_CMAKELISTS}")
    file(READ "${TIFF_CMAKELISTS}" TIFF_CONTENT)
    
    if(TIFF_CONTENT MATCHES "TIFF_LIBRARY")
        # 将 TIFF_LIBRARY 替换为 TIFF_LIBRARIES
        string(REPLACE
            "TIFF_LIBRARY"
            "TIFF_LIBRARIES"
            TIFF_CONTENT "${TIFF_CONTENT}"
        )
        file(WRITE "${TIFF_CMAKELISTS}" "${TIFF_CONTENT}")
        message(STATUS "OSG TIFF_LIBRARY fix applied successfully")
    else()
        message(STATUS "OSG TIFF_LIBRARY fix already applied or not needed")
    endif()
else()
    message(WARNING "TIFF CMakeLists.txt not found: ${TIFF_CMAKELISTS}")
endif()

# ==============================================================================
# 修复 6: GDAL 插件 C++17 兼容性 (std::auto_ptr 移除)
# ==============================================================================
set(GDAL_CPP_FILE "${SOURCE_DIR}/src/osgPlugins/gdal/ReaderWriterGDAL.cpp")

if(EXISTS "${GDAL_CPP_FILE}")
    file(READ "${GDAL_CPP_FILE}" GDAL_CONTENT)
    
    if(GDAL_CONTENT MATCHES "std::auto_ptr")
        # 替换 std::auto_ptr 为 std::unique_ptr
        string(REPLACE
            "std::auto_ptr"
            "std::unique_ptr"
            GDAL_CONTENT "${GDAL_CONTENT}"
        )
        file(WRITE "${GDAL_CPP_FILE}" "${GDAL_CONTENT}")
        message(STATUS "OSG GDAL auto_ptr fix applied successfully")
    else()
        message(STATUS "OSG GDAL auto_ptr fix already applied or not needed")
    endif()
else()
    message(WARNING "ReaderWriterGDAL.cpp not found: ${GDAL_CPP_FILE}")
endif()
