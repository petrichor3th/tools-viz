# ==============================================================================
# osgEarth 3.7.2 - 地理空间 3D 渲染工具包
# ==============================================================================
# 官方仓库: https://github.com/gwaldron/osgearth
# 功能: 基于 OSG 的地球渲染引擎，支持地形、影像、矢量数据
# ==============================================================================

sb_verify_version(osgearth "3.7.2")
sb_get_external_info(osgearth VERSION SB_OSGEARTH_VERSION SOURCE_ARGS SB_OSGEARTH_SRC)
sb_register_dependency(ext_osgearth DEPENDS ext_osg ext_glew ext_curl ext_gdal)
sb_build_install_commands()

# CURL 库变量（osgEarth 也使用传统变量）
if(WIN32)
    set(_CURL_LIBRARY "${SB_INSTALL_DIR}/lib/libcurl_imp.lib")
else()
    set(_CURL_LIBRARY "${SB_INSTALL_DIR}/lib/libcurl.so")
endif()

ExternalProject_Add(ext_osgearth
    DEPENDS ext_osg ext_glew ext_curl ext_gdal
    PREFIX ${SB_PREFIX}/osgearth-${SB_OSGEARTH_VERSION}
    ${SB_OSGEARTH_SRC}
    GIT_SHALLOW TRUE
    GIT_PROGRESS TRUE
    GIT_SUBMODULES "src/third_party/lerc"
    # GDAL 3.9+ 命名空间冲突修复补丁
    PATCH_COMMAND ${CMAKE_COMMAND}
        -DSOURCE_DIR=<SOURCE_DIR>
        -P ${CMAKE_SOURCE_DIR}/superbuild/patches/osgearth-3.7.2-gdal-namespace.cmake
    CMAKE_ARGS
        ${SB_CMAKE_ARGS}
        # OSG 配置
        -DOSG_DIR:PATH=${SB_INSTALL_DIR}
        -DOpenSceneGraph_DIR:PATH=${SB_INSTALL_DIR}
        # CURL 配置（传统变量）
        -DCURL_LIBRARY:FILEPATH=${_CURL_LIBRARY}
        -DCURL_INCLUDE_DIR:PATH=${SB_INSTALL_DIR}/include
        # GDAL 配置
        -DGDAL_DIR:PATH=${SB_INSTALL_DIR}
        # 禁用不需要的组件
        -DOSGEARTH_BUILD_EXAMPLES:BOOL=OFF
        -DOSGEARTH_BUILD_TESTS:BOOL=OFF
        -DOSGEARTH_BUILD_DOCS:BOOL=OFF
        -DOSGEARTH_BUILD_PROCEDURAL_NODEKIT:BOOL=OFF
        -DOSGEARTH_BUILD_TRITON_NODEKIT:BOOL=OFF
        -DOSGEARTH_BUILD_SILVERLINING_NODEKIT:BOOL=OFF
    BUILD_COMMAND ${SB_BUILD_CMD}
    INSTALL_COMMAND ${SB_INSTALL_CMD}
    ${SB_LOG_ARGS}
)

