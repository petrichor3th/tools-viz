add_tools_viz_plugin(example-plugin
    src/ExamplePlugin.h
    src/ExamplePlugin.cpp
)

# 复制QML文件到输出目录
add_custom_command(TARGET example-plugin POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy
        ${CMAKE_CURRENT_SOURCE_DIR}/qml/ExamplePlugin.qml
        ${CMAKE_BINARY_DIR}/bin/plugins/ExamplePlugin.qml
)
