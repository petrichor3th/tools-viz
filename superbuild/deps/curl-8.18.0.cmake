# ==============================================================================
# curl 8.18.0 - URL 传输库
# ==============================================================================
# 官方仓库: https://github.com/curl/curl
# 功能: HTTP/HTTPS, FTP, 文件传输协议支持
# ==============================================================================

sb_verify_version(curl "8.18.0")
sb_get_external_info(curl VERSION SB_CURL_VERSION SOURCE_ARGS SB_CURL_SRC)
sb_register_dependency(ext_curl DEPENDS ext_zlib)
sb_build_install_commands()

ExternalProject_Add(ext_curl
    DEPENDS ext_zlib
    PREFIX ${SB_PREFIX}/curl-${SB_CURL_VERSION}
    ${SB_CURL_SRC}
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
    CMAKE_ARGS
        ${SB_CMAKE_ARGS}
        -DBUILD_CURL_EXE:BOOL=OFF
        -DBUILD_TESTING:BOOL=OFF
        -DBUILD_SHARED_LIBS:BOOL=ON
        -DCURL_USE_SCHANNEL:BOOL=ON       # Windows 原生 SSL
        -DCURL_USE_LIBSSH2:BOOL=OFF
        -DCURL_USE_LIBPSL:BOOL=OFF
        -DCURL_ZLIB:BOOL=ON
        -DZLIB_ROOT:PATH=${SB_INSTALL_DIR}
    BUILD_COMMAND ${SB_BUILD_CMD}
    INSTALL_COMMAND ${SB_INSTALL_CMD}
    ${SB_LOG_ARGS}
)

