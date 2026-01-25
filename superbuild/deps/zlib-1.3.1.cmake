# ==============================================================================
# zlib 1.3.1 - 压缩库
# ==============================================================================
# 官方仓库: https://github.com/madler/zlib
# ==============================================================================

sb_verify_version(zlib "1.3.1")
sb_get_external_info(zlib VERSION SB_ZLIB_VERSION SOURCE_ARGS SB_ZLIB_SRC)
sb_register_dependency(ext_zlib)
sb_build_install_commands()

ExternalProject_Add(ext_zlib
    PREFIX ${SB_PREFIX}/zlib-${SB_ZLIB_VERSION}
    ${SB_ZLIB_SRC}
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
    CMAKE_ARGS
        ${SB_CMAKE_ARGS}
        -DBUILD_SHARED_LIBS:BOOL=ON
        -DZLIB_BUILD_EXAMPLES:BOOL=OFF
    BUILD_COMMAND ${SB_BUILD_CMD}
    INSTALL_COMMAND ${SB_INSTALL_CMD}
    ${SB_LOG_ARGS}
)
