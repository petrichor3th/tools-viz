# ==============================================================================
# OSG C++17 兼容性修复补丁
# ==============================================================================
#
# 修复内容：
# 1. std::byte 冲突：C++17 的 std::byte 与 Windows SDK 的 byte 类型冲突
# 2. std::mem_fun_ref 移除：C++17 移除了 std::mem_fun_ref，需替换为 lambda
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
