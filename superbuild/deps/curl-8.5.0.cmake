# ==============================================================================
# curl 8.5.0 - URL 传输库
# ==============================================================================
# 官方仓库: https://github.com/curl/curl
# 功能: HTTP/HTTPS, FTP, 文件传输协议支持
# ==============================================================================

sb_verify_version(curl "8.5.0")
sb_get_external_info(curl VERSION SB_CURL_VERSION SOURCE_ARGS SB_CURL_SRC)
sb_register_dependency(ext_curl DEPENDS ext_zlib)
sb_build_install_commands()

ExternalProject_Add(ext_curl
    DEPENDS ext_zlib
    PREFIX ${SB_PREFIX}/curl-${SB_CURL_VERSION}
    ${SB_CURL_SRC}
    GIT_SHALLOW TRUE
    GIT_PROGRESS TRUE
    CMAKE_ARGS
        ${SB_CMAKE_ARGS}
        -DBUILD_CURL_EXE:BOOL=OFF
        -DBUILD_TESTING:BOOL=OFF
        -DBUILD_SHARED_LIBS:BOOL=ON
        -DCURL_USE_SCHANNEL:BOOL=ON       # Windows 原生 SSL
        -DCURL_USE_LIBSSH2:BOOL=OFF
        -DCURL_ZLIB:BOOL=ON
        -DZLIB_ROOT:PATH=${SB_INSTALL_DIR}
    BUILD_COMMAND ${SB_BUILD_CMD}
    INSTALL_COMMAND ${SB_INSTALL_CMD}
    ${SB_LOG_ARGS}
)

# ------------------------------------------------------------------------------
# 导出变量（供下游依赖使用）
# 解决 CURLConfig.cmake 与 FindCURL.cmake 变量不兼容的问题
# ------------------------------------------------------------------------------
sb_lib_path(CURL_LIBRARY_PATH "libcurl-d" IMPORT)  # Debug
sb_lib_path(CURL_LIBRARY_RELEASE_PATH "libcurl" IMPORT)  # Release
sb_include_dir(CURL_INCLUDE_PATH)

# 设置传统 CMake 变量（供 OSG 等旧项目使用）
set(SB_CURL_LIBRARY "${SB_INSTALL_DIR}/lib/libcurl-d_imp.lib" CACHE FILEPATH "CURL import library")
set(SB_CURL_RELEASE_LIBRARY "${SB_INSTALL_DIR}/lib/libcurl_imp.lib" CACHE FILEPATH "CURL import debug library")
set(SB_CURL_INCLUDE_DIR "${SB_INSTALL_DIR}/include" CACHE PATH "CURL include directory")
