# ==============================================================================
# libtiff 4.6.0 - TIFF 图像库
# ==============================================================================
# 官方仓库: https://gitlab.com/libtiff/libtiff
# 功能: TIFF 格式图像读写支持
# ==============================================================================

sb_verify_version(libtiff "4.7.1")
sb_get_external_info(libtiff VERSION SB_LIBTIFF_VERSION SOURCE_ARGS SB_LIBTIFF_SRC)
sb_register_dependency(ext_tiff DEPENDS ext_zlib)
sb_build_install_commands()

ExternalProject_Add(ext_tiff
    DEPENDS ext_zlib
    PREFIX ${SB_PREFIX}/libtiff-${SB_LIBTIFF_VERSION}
    ${SB_LIBTIFF_SRC}
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
    CMAKE_ARGS
        ${SB_CMAKE_ARGS}
        -DBUILD_SHARED_LIBS:BOOL=ON
        -Dtiff-tools:BOOL=OFF
        -Dtiff-tests:BOOL=OFF
        -Dtiff-contrib:BOOL=OFF
        -Dtiff-docs:BOOL=OFF
        -Dzlib:BOOL=ON
        -DZLIB_ROOT:PATH=${SB_INSTALL_DIR}
    BUILD_COMMAND ${SB_BUILD_CMD}
    INSTALL_COMMAND ${SB_INSTALL_CMD}
    ${SB_LOG_ARGS}
)

# 导出变量
set(SB_TIFF_LIBRARY "${SB_INSTALL_DIR}/lib/tiff.lib" CACHE FILEPATH "TIFF library")
set(SB_TIFF_INCLUDE_DIR "${SB_INSTALL_DIR}/include" CACHE PATH "TIFF include directory")
