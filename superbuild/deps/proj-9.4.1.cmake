# ==============================================================================
# PROJ 9.4.1 - 地理坐标投影库
# ==============================================================================
# 官方仓库: https://github.com/OSGeo/PROJ
# 功能: 坐标系统转换，GDAL 的必需依赖
# ==============================================================================

sb_verify_version(proj "9.4.1")
sb_get_external_info(proj VERSION SB_PROJ_VERSION SOURCE_ARGS SB_PROJ_SRC)
sb_register_dependency(ext_proj DEPENDS ext_curl ext_tiff ext_sqlite3)
sb_build_install_commands()

ExternalProject_Add(ext_proj
    DEPENDS ext_curl ext_tiff ext_sqlite3
    PREFIX ${SB_PREFIX}/proj-${SB_PROJ_VERSION}
    ${SB_PROJ_SRC}
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
    CMAKE_ARGS
        ${SB_CMAKE_ARGS}
        -DBUILD_SHARED_LIBS:BOOL=ON
        -DBUILD_APPS:BOOL=OFF
        -DBUILD_TESTING:BOOL=OFF
        -DENABLE_CURL:BOOL=ON
        -DENABLE_TIFF:BOOL=ON
        -DCURL_DIR:PATH=${SB_INSTALL_DIR}
        -DTIFF_DIR:PATH=${SB_INSTALL_DIR}
        -DSQLite3_INCLUDE_DIR:PATH=${SB_INSTALL_DIR}/include
        -DSQLite3_LIBRARY:PATH=${SB_INSTALL_DIR}/lib/sqlite3.lib
        -DEXE_SQLITE3:FILEPATH=${SB_INSTALL_DIR}/bin/sqlite3.exe
    BUILD_COMMAND ${SB_BUILD_CMD}
    INSTALL_COMMAND ${SB_INSTALL_CMD}
    ${SB_LOG_ARGS}
)

# 导出变量
set(SB_PROJ_LIBRARY "${SB_INSTALL_DIR}/lib/proj.lib" CACHE FILEPATH "PROJ library")
set(SB_PROJ_INCLUDE_DIR "${SB_INSTALL_DIR}/include" CACHE PATH "PROJ include directory")
