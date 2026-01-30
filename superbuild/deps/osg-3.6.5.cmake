# ==============================================================================
# OpenSceneGraph 3.6.5 - 3D 图形引擎
# ==============================================================================
# 官方仓库: https://github.com/openscenegraph/OpenSceneGraph
# 功能: 高性能 3D 图形渲染引擎
#
# 注意事项:
# 1. OSG 3.6.5 使用 CMAKE_MINIMUM_REQUIRED(VERSION 2.8.0)，需要添加兼容性参数
# 2. 需要补丁修复 C++17 兼容性问题（std::byte 冲突、std::mem_fun_ref 移除等）
# 3. OSG 使用传统 CMake 变量（CURL_LIBRARY），而非现代 CMake targets
# ==============================================================================

sb_verify_version(osg "3.6.5")
sb_get_external_info(osg VERSION SB_OSG_VERSION SOURCE_ARGS SB_OSG_SRC)
sb_register_dependency(ext_osg DEPENDS ext_curl ext_tiff ext_gdal ext_glew)
sb_build_install_commands()

# ------------------------------------------------------------------------------
# ExternalProject 配置
# ------------------------------------------------------------------------------
ExternalProject_Add(ext_osg
    DEPENDS ext_curl ext_tiff ext_gdal ext_glew
    PREFIX ${SB_PREFIX}/osg-${SB_OSG_VERSION}
    ${SB_OSG_SRC}
    GIT_SHALLOW TRUE
    GIT_PROGRESS TRUE
    # C++17 兼容性补丁
    PATCH_COMMAND ${CMAKE_COMMAND} 
        -DSOURCE_DIR=<SOURCE_DIR> 
        -P ${CMAKE_SOURCE_DIR}/superbuild/patches/osg-3.6.5-cpp17.cmake
    CMAKE_ARGS
        ${SB_CMAKE_ARGS}
        ${SB_CMAKE_COMPAT_ARGS}
        # 基础配置
        -DBUILD_OSG_APPLICATIONS:BOOL=OFF
        -DBUILD_OSG_EXAMPLES:BOOL=OFF
        -DOSG_USE_QT:BOOL=OFF
        -DOSG_GL3_AVAILABLE:BOOL=ON
        -DOPENGL_PROFILE:STRING=GL3
        # GLEW 配置
        -DGLEW_DIR:PATH=${SB_INSTALL_DIR}
        -DCURL_NO_CURL_CMAKE:BOOL=ON
    BUILD_COMMAND ${SB_BUILD_CMD}
    INSTALL_COMMAND ${SB_INSTALL_CMD}
    ${SB_LOG_ARGS}
)

