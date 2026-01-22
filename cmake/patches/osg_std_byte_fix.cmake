# ==============================================================================
# OSG std::byte 冲突修复补丁
# 问题：C++17 的 std::byte 与 Windows SDK 的 byte 类型冲突
# 解决：在 CMakeLists.txt 中添加 _HAS_STD_BYTE=0 定义
# ==============================================================================

set(OSG_CMAKELISTS "${SOURCE_DIR}/CMakeLists.txt")

if(NOT EXISTS "${OSG_CMAKELISTS}")
    message(FATAL_ERROR "OSG CMakeLists.txt not found: ${OSG_CMAKELISTS}")
endif()

file(READ "${OSG_CMAKELISTS}" CONTENT)

# 检查是否已经添加过补丁
if(CONTENT MATCHES "_HAS_STD_BYTE")
    message(STATUS "OSG std::byte fix already applied")
    return()
endif()

# 在 PROJECT() 后添加 _HAS_STD_BYTE=0 定义
# 查找 PROJECT(OpenSceneGraph) 行并在其后插入
string(REGEX REPLACE
    "(PROJECT\\([^)]+\\))"
    "\\1\n\n# [PATCH] Fix C++17 std::byte conflict with Windows SDK byte type\nif(MSVC AND CMAKE_CXX_STANDARD GREATER_EQUAL 17)\n    add_compile_definitions(_HAS_STD_BYTE=0)\nendif()"
    CONTENT "${CONTENT}"
)

file(WRITE "${OSG_CMAKELISTS}" "${CONTENT}")
message(STATUS "OSG std::byte fix applied successfully")
