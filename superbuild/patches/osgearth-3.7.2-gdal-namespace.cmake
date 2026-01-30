# ==============================================================================
# osgEarth 3.7.2 GDAL 命名空间冲突修复
# ==============================================================================
#
# 问题：GDAL 3.9+ 在 gdal_cpp_functions.h 中引入全局 namespace GDAL，
#       与 osgEarth::GDAL 命名空间冲突，导致编译器无法解析 GDAL:: 前缀
#       错误信息：error C2872: "GDAL": 不明确的符号
#
# 修复：将命名空间外的 GDAL:: 替换为完全限定名 osgEarth::GDAL::
#
# ==============================================================================

set(GDAL_CPP_FILE "${SOURCE_DIR}/src/osgEarth/GDAL.cpp")

if(EXISTS "${GDAL_CPP_FILE}")
    file(READ "${GDAL_CPP_FILE}" CONTENT)
    
    # 检查是否已经应用过补丁
    if(NOT CONTENT MATCHES "osgEarth::GDAL::Driver::~Driver")
        # 替换行首的 GDAL:: 为 osgEarth::GDAL:: (类成员函数定义)
        string(REGEX REPLACE
            "\n(GDAL::)"
            "\nosgEarth::GDAL::"
            CONTENT "${CONTENT}"
        )
        
        # 替换参数类型中的 GDAL:: (如 GDAL::Options, GDAL::ExternalDataset)
        string(REGEX REPLACE
            "\\(GDAL::"
            "(osgEarth::GDAL::"
            CONTENT "${CONTENT}"
        )
        string(REGEX REPLACE
            ", GDAL::"
            ", osgEarth::GDAL::"
            CONTENT "${CONTENT}"
        )
        string(REGEX REPLACE
            " GDAL::([A-Z])"
            " osgEarth::GDAL::\\1"
            CONTENT "${CONTENT}"
        )
        
        # 替换模板参数中的 GDAL:: (如 std::make_shared<GDAL::Driver>)
        string(REGEX REPLACE
            "<GDAL::"
            "<osgEarth::GDAL::"
            CONTENT "${CONTENT}"
        )
        
        file(WRITE "${GDAL_CPP_FILE}" "${CONTENT}")
        message(STATUS "osgEarth GDAL namespace fix applied successfully")
    else()
        message(STATUS "osgEarth GDAL namespace fix already applied")
    endif()
else()
    message(WARNING "GDAL.cpp not found: ${GDAL_CPP_FILE}")
endif()
