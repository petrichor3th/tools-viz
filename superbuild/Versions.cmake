# ==============================================================================
# SuperBuild 版本管理 (重构版)
# ==============================================================================

# ------------------------------------------------------------------------------
# 基础库
# ------------------------------------------------------------------------------

sb_declare_external(zlib
    VERSION     "1.3.1"
    DESCRIPTION "General purpose compression library"
    URL         "https://github.com/madler/zlib/releases/download/v1.3.1/zlib-1.3.1.tar.gz"
)

sb_declare_external(curl
    VERSION     "8.5.0"
    DESCRIPTION "Command line tool and library for transferring data with URLs"
    GIT         "https://github.com/curl/curl.git"
    TAG         "curl-8_5_0"
)

sb_declare_external(libtiff
    VERSION     "4.7.1"
    DESCRIPTION "Library for reading and writing TIFF image files"
    URL         "https://download.osgeo.org/libtiff/tiff-4.7.1.tar.gz"
)

sb_declare_external(sqlite
    VERSION     "3.50.2"
    DESCRIPTION "C-language library that implements a small, fast, self-contained, high-reliability, full-featured, SQL database engine"
    URL         "https://www.sqlite.org/2025/sqlite-amalgamation-3500200.zip"
)

# ------------------------------------------------------------------------------
# 地理空间库
# ------------------------------------------------------------------------------

sb_declare_external(proj
    VERSION     "9.4.1"
    DESCRIPTION "Generic coordinate transformation software"
    URL         "https://github.com/OSGeo/PROJ/releases/download/9.4.1/proj-9.4.1.tar.gz"
)

sb_declare_external(gdal
    VERSION     "3.12.1"
    DESCRIPTION "Translator library for raster and vector geospatial data formats"
    URL         "https://github.com/OSGeo/gdal/releases/download/v3.12.1/gdal-3.12.1.tar.gz"
)

# ------------------------------------------------------------------------------
# 图形库
# ------------------------------------------------------------------------------

sb_declare_external(glew
    VERSION     "2.3.0"
    DESCRIPTION "OpenGL Extension Wrangler Library"
    GIT         "https://github.com/Perlmint/glew-cmake.git"
    TAG         "glew-cmake-2.3.0"
)

sb_declare_external(osg
    VERSION     "3.6.5"
    DESCRIPTION "OpenSceneGraph 3D graphics toolkit"
    GIT         "https://github.com/openscenegraph/OpenSceneGraph.git"
    TAG         "OpenSceneGraph-3.6.5"
)

sb_declare_external(osgearth
    VERSION     "3.7.2"
    DESCRIPTION "3D mapping engine for osgEarth"
    GIT         "https://github.com/gwaldron/osgearth.git"
    TAG         "osgearth-3.7.2"
)

# ------------------------------------------------------------------------------
# 版本校验宏 (保持兼容性)
# ------------------------------------------------------------------------------
macro(sb_verify_version DEP_NAME EXPECTED_VERSION)
    sb_get_external_info(${DEP_NAME} VERSION _ACTUAL_VERSION)
    if(NOT "${_ACTUAL_VERSION}" STREQUAL "${EXPECTED_VERSION}")
        message(WARNING "Version mismatch for ${DEP_NAME}: expected ${EXPECTED_VERSION}, got ${_ACTUAL_VERSION}")
    endif()
endmacro()
