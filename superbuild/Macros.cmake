# ==============================================================================
# SuperBuild 宏定义和辅助函数
# ==============================================================================

include(ExternalProject)

# ==============================================================================
# 全局配置
# ==============================================================================

# 外部项目工作目录
set(SB_PREFIX "${CMAKE_BINARY_DIR}/externals")

# 统一安装目录
set(SB_INSTALL_DIR "${CMAKE_BINARY_DIR}/install")

# 确保目录存在
file(MAKE_DIRECTORY ${SB_INSTALL_DIR})
file(MAKE_DIRECTORY ${SB_INSTALL_DIR}/lib)
file(MAKE_DIRECTORY ${SB_INSTALL_DIR}/bin)
file(MAKE_DIRECTORY ${SB_INSTALL_DIR}/include)

# 依赖追踪列表
set(SB_DEPENDENCY_TARGETS "" CACHE INTERNAL "List of all SuperBuild dependency targets")
set(SB_DEPENDENCY_GRAPH "" CACHE INTERNAL "Dependency graph for visualization")

# ==============================================================================
# 平台相关配置
# ==============================================================================

# 库文件扩展名
if(WIN32)
    set(SB_SHARED_LIB_EXT ".dll")
    set(SB_STATIC_LIB_EXT ".lib")
    set(SB_IMPORT_LIB_EXT ".lib")
else()
    set(SB_SHARED_LIB_EXT ".so")
    set(SB_STATIC_LIB_EXT ".a")
    set(SB_IMPORT_LIB_EXT ".a")
endif()

# ==============================================================================
# 通用 CMake 参数
# ==============================================================================

set(SB_CMAKE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=${SB_INSTALL_DIR}
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DCMAKE_CXX_STANDARD:STRING=17
    -DCMAKE_C_STANDARD:STRING=11
    -DCMAKE_PREFIX_PATH:PATH=${SB_INSTALL_DIR}
    -DCMAKE_POLICY_DEFAULT_CMP0091:STRING=NEW
    -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON
)

# 旧版 CMake 兼容性参数
set(SB_CMAKE_COMPAT_ARGS
    -DCMAKE_POLICY_VERSION_MINIMUM:STRING=3.5
)

# MSVC 运行时库配置
if(MSVC)
    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
        list(APPEND SB_CMAKE_ARGS -DCMAKE_MSVC_RUNTIME_LIBRARY:STRING=MultiThreadedDebugDLL)
    else()
        list(APPEND SB_CMAKE_ARGS -DCMAKE_MSVC_RUNTIME_LIBRARY:STRING=MultiThreadedDLL)
    endif()
endif()

# ==============================================================================
# 库路径生成函数
# ==============================================================================

# 获取库文件完整路径
# 用法: sb_lib_path(<OUTPUT_VAR> <LIB_NAME> [SHARED|STATIC|IMPORT])
function(sb_lib_path OUTPUT_VAR LIB_NAME)
    set(LIB_TYPE "IMPORT")  # 默认为导入库
    if(ARGC GREATER 2)
        set(LIB_TYPE ${ARGV2})
    endif()

    if(WIN32)
        if(LIB_TYPE STREQUAL "SHARED")
            set(${OUTPUT_VAR} "${SB_INSTALL_DIR}/bin/${LIB_NAME}${SB_SHARED_LIB_EXT}" PARENT_SCOPE)
        else()
            set(${OUTPUT_VAR} "${SB_INSTALL_DIR}/lib/${LIB_NAME}${SB_IMPORT_LIB_EXT}" PARENT_SCOPE)
        endif()
    else()
        if(LIB_TYPE STREQUAL "STATIC")
            set(${OUTPUT_VAR} "${SB_INSTALL_DIR}/lib/lib${LIB_NAME}${SB_STATIC_LIB_EXT}" PARENT_SCOPE)
        else()
            set(${OUTPUT_VAR} "${SB_INSTALL_DIR}/lib/lib${LIB_NAME}${SB_SHARED_LIB_EXT}" PARENT_SCOPE)
        endif()
    endif()
endfunction()

# 获取头文件目录
function(sb_include_dir OUTPUT_VAR)
    set(${OUTPUT_VAR} "${SB_INSTALL_DIR}/include" PARENT_SCOPE)
endfunction()

# ==============================================================================
# 依赖注册宏
# ==============================================================================

# 注册依赖到全局追踪列表
# 用法: sb_register_dependency(<TARGET_NAME> [DEPENDS dep1 dep2 ...])
macro(sb_register_dependency TARGET_NAME)
    # 解析参数
    cmake_parse_arguments(SB_REG "" "" "DEPENDS" ${ARGN})
    
    # 添加到目标列表
    list(APPEND SB_DEPENDENCY_TARGETS ${TARGET_NAME})
    set(SB_DEPENDENCY_TARGETS ${SB_DEPENDENCY_TARGETS} CACHE INTERNAL "")
    
    # 记录依赖关系
    if(SB_REG_DEPENDS)
        foreach(_dep ${SB_REG_DEPENDS})
            list(APPEND SB_DEPENDENCY_GRAPH "${TARGET_NAME}->${_dep}")
        endforeach()
        set(SB_DEPENDENCY_GRAPH ${SB_DEPENDENCY_GRAPH} CACHE INTERNAL "")
    endif()
endmacro()

# ==============================================================================
# 通用 ExternalProject 参数宏
# ==============================================================================

# 生成通用的 BUILD_COMMAND 和 INSTALL_COMMAND
macro(sb_build_install_commands)
    set(SB_BUILD_CMD ${CMAKE_COMMAND} --build <BINARY_DIR> --config $<CONFIG> --parallel)
    set(SB_INSTALL_CMD ${CMAKE_COMMAND} --build <BINARY_DIR> --config $<CONFIG> --target install)
endmacro()

# 通用日志参数
set(SB_LOG_ARGS
    LOG_DOWNLOAD TRUE
    LOG_CONFIGURE TRUE
    LOG_BUILD TRUE
    LOG_INSTALL TRUE
)

# ==============================================================================
# 版本管理重构
# ==============================================================================

# 声明外部项目
# 用法:
# sb_declare_external(zlib
#     VERSION "1.3.1"
#     URL "..."
#     HASH "..."
# )
macro(sb_declare_external NAME)
    cmake_parse_arguments(EXT "" "VERSION;URL;GIT;TAG;HASH;DESCRIPTION" "" ${ARGN})
    
    # 支持通过命令行覆盖版本: -DSB_ZLIB_VERSION=1.2.13
    string(TOUPPER ${NAME} _NAME_UPPER)
    if(DEFINED SB_${_NAME_UPPER}_VERSION)
        set(_VERSION ${SB_${_NAME_UPPER}_VERSION})
    else()
        set(_VERSION ${EXT_VERSION})
    endif()

    # 存储到全局属性
    set_property(GLOBAL PROPERTY SB_EXT_${NAME}_VERSION "${_VERSION}")
    set_property(GLOBAL PROPERTY SB_EXT_${NAME}_DESCRIPTION "${EXT_DESCRIPTION}")
    
    if(EXT_URL)
        set_property(GLOBAL PROPERTY SB_EXT_${NAME}_URL "${EXT_URL}")
        set_property(GLOBAL PROPERTY SB_EXT_${NAME}_HASH "${EXT_HASH}")
        set_property(GLOBAL PROPERTY SB_EXT_${NAME}_TYPE "URL")
    elseif(EXT_GIT)
        set_property(GLOBAL PROPERTY SB_EXT_${NAME}_GIT "${EXT_GIT}")
        set_property(GLOBAL PROPERTY SB_EXT_${NAME}_TAG "${EXT_TAG}")
        set_property(GLOBAL PROPERTY SB_EXT_${NAME}_TYPE "GIT")
    endif()

    # 注册到项目列表
    get_property(_EXT_LIST GLOBAL PROPERTY SB_EXTERNAL_PROJECT_LIST)
    list(APPEND _EXT_LIST ${NAME})
    set_property(GLOBAL PROPERTY SB_EXTERNAL_PROJECT_LIST "${_EXT_LIST}")
endmacro()

# 获取外部项目信息
# 用法: sb_get_external_info(zlib VERSION zlib_ver SOURCE_ARGS zlib_src)
function(sb_get_external_info NAME)
    cmake_parse_arguments(GET "" "VERSION;SOURCE_ARGS" "" ${ARGN})

    if(GET_VERSION)
        get_property(_VER GLOBAL PROPERTY SB_EXT_${NAME}_VERSION)
        set(${GET_VERSION} "${_VER}" PARENT_SCOPE)
    endif()

    if(GET_SOURCE_ARGS)
        get_property(_TYPE GLOBAL PROPERTY SB_EXT_${NAME}_TYPE)
        if(_TYPE STREQUAL "URL")
            get_property(_URL GLOBAL PROPERTY SB_EXT_${NAME}_URL)
            get_property(_HASH GLOBAL PROPERTY SB_EXT_${NAME}_HASH)
            set(_ARGS URL "${_URL}")
            if(_HASH)
                list(APPEND _ARGS URL_HASH "${_HASH}")
            endif()
        elseif(_TYPE STREQUAL "GIT")
            get_property(_GIT GLOBAL PROPERTY SB_EXT_${NAME}_GIT)
            get_property(_TAG GLOBAL PROPERTY SB_EXT_${NAME}_TAG)
            set(_ARGS GIT_REPOSITORY "${_GIT}" GIT_TAG "${_TAG}")
        endif()
        set(${GET_SOURCE_ARGS} "${_ARGS}" PARENT_SCOPE)
    endif()
endfunction()

# ==============================================================================
# 配置输出函数
# ==============================================================================

# 打印配置摘要
function(sb_print_summary)
    message(STATUS "")
    message(STATUS "SuperBuild Configuration")
    message(STATUS "  Install Directory: ${SB_INSTALL_DIR}")
    message(STATUS "  Build Type:        ${CMAKE_BUILD_TYPE}")
    message(STATUS "  C++ Standard:      17")
    message(STATUS "")
    message(STATUS "Dependencies")
    
    get_property(_EXT_LIST GLOBAL PROPERTY SB_EXTERNAL_PROJECT_LIST)
    foreach(_name ${_EXT_LIST})
        get_property(_version GLOBAL PROPERTY SB_EXT_${_name}_VERSION)
        string(LENGTH ${_name} _name_len)
        math(EXPR _padding "16 - ${_name_len}")
        if(_padding LESS 1)
            set(_padding 1)
        endif()
        string(REPEAT " " ${_padding} _spaces)
        message(STATUS "  ${_name}${_spaces}${_version}")
    endforeach()
    
    message(STATUS "")
endfunction()

# 生成依赖图 DOT 文件
function(sb_generate_dependency_graph OUTPUT_FILE)
    file(WRITE ${OUTPUT_FILE} "digraph SuperBuild {\n")
    file(APPEND ${OUTPUT_FILE} "    rankdir=LR;\n")
    file(APPEND ${OUTPUT_FILE} "    node [shape=box, style=filled, fillcolor=lightblue];\n")
    
    foreach(_edge ${SB_DEPENDENCY_GRAPH})
        string(REPLACE "->" "\" -> \"" _formatted ${_edge})
        file(APPEND ${OUTPUT_FILE} "    \"${_formatted}\";\n")
    endforeach()
    
    file(APPEND ${OUTPUT_FILE} "}\n")
    message(STATUS "Dependency graph written to: ${OUTPUT_FILE}")
endfunction()

# ==============================================================================
# 兼容性别名（向后兼容旧配置）
# ==============================================================================
set(EP_PREFIX ${SB_PREFIX})
set(EP_INSTALL_DIR ${SB_INSTALL_DIR})
set(EP_CMAKE_ARGS ${SB_CMAKE_ARGS})
set(EP_CMAKE_COMPAT_ARGS ${SB_CMAKE_COMPAT_ARGS})
