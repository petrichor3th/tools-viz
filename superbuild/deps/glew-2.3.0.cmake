# ==============================================================================
# GLEW 2.3.0 - OpenGL Extension Wrangler Library
# ==============================================================================
# 官方仓库: https://github.com/nigels-com/glew
# 功能: OpenGL 扩展加载器
# 注: GLEW 的 CMakeLists.txt 位于 build/cmake 子目录
# ==============================================================================

sb_verify_version(glew "2.3.0")
sb_get_external_info(glew VERSION SB_GLEW_VERSION SOURCE_ARGS SB_GLEW_SRC)
sb_register_dependency(ext_glew)
sb_build_install_commands()

ExternalProject_Add(ext_glew
    PREFIX ${SB_PREFIX}/glew-${SB_GLEW_VERSION}
    ${SB_GLEW_SRC}
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
    SOURCE_SUBDIR build/cmake
    CMAKE_ARGS
        ${SB_CMAKE_ARGS}
        -DBUILD_UTILS:BOOL=OFF
    BUILD_COMMAND ${SB_BUILD_CMD}
    INSTALL_COMMAND ${SB_INSTALL_CMD}
    ${SB_LOG_ARGS}
)

# 导出变量
set(SB_GLEW_LIBRARY "${SB_INSTALL_DIR}/lib/glew32.lib" CACHE FILEPATH "GLEW library")
set(SB_GLEW_INCLUDE_DIR "${SB_INSTALL_DIR}/include" CACHE PATH "GLEW include directory")
