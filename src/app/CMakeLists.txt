set(APP_SOURCES
    main.cpp
    MainWindow.cpp
    MainWindow.h
)

add_tools_viz_app(ToolsViz
    WIN32_APP
    SOURCES ${APP_SOURCES}
)
