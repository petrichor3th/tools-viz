# ==============================================================================
# GDAL 3.12.1 - 地理空间数据抽象库
# ==============================================================================
# 官方仓库: https://github.com/OSGeo/gdal
# 功能: 栅格和矢量地理空间数据格式支持
# ==============================================================================

sb_verify_version(gdal "3.12.1")
sb_get_external_info(gdal VERSION SB_GDAL_VERSION SOURCE_ARGS SB_GDAL_SRC)
sb_register_dependency(ext_gdal DEPENDS ext_curl ext_tiff ext_proj ext_zlib)
sb_build_install_commands()

ExternalProject_Add(ext_gdal
    DEPENDS ext_curl ext_tiff ext_proj ext_zlib
    PREFIX ${SB_PREFIX}/gdal-${SB_GDAL_VERSION}
    ${SB_GDAL_SRC}
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
    CMAKE_ARGS
        ${SB_CMAKE_ARGS}
        # 基础配置
        -DBUILD_SHARED_LIBS:BOOL=ON
        -DBUILD_APPS:BOOL=OFF
        -DBUILD_TESTING:BOOL=OFF
        # 禁用可选驱动（减少依赖）
        -DGDAL_BUILD_OPTIONAL_DRIVERS:BOOL=OFF
        -DOGR_BUILD_OPTIONAL_DRIVERS:BOOL=OFF
        # 必需依赖 - CURL
        -DGDAL_USE_CURL:BOOL=ON
        -DCURL_DIR:PATH=${SB_INSTALL_DIR}
        # 必需依赖 - TIFF
        -DGDAL_USE_TIFF:BOOL=ON
        -DTIFF_DIR:PATH=${SB_INSTALL_DIR}
        # 必需依赖 - PROJ
        -DGDAL_USE_INTERNAL_LIBS:STRING=OFF
        -DPROJ_DIR:PATH=${SB_INSTALL_DIR}
        -DPROJ_INCLUDE_DIR:PATH=${SB_INSTALL_DIR}/include
        -DPROJ_LIBRARY:PATH=${SB_INSTALL_DIR}/lib/proj.lib
        # 必需依赖 - ZLIB
        -DGDAL_USE_ZLIB:BOOL=ON
        -DZLIB_ROOT:PATH=${SB_INSTALL_DIR}
        # 必需依赖 - JSON-C（使用内置版本）
        -DGDAL_USE_JSONC_INTERNAL:BOOL=ON
    BUILD_COMMAND ${SB_BUILD_CMD}
    INSTALL_COMMAND ${SB_INSTALL_CMD}
    ${SB_LOG_ARGS}
)

