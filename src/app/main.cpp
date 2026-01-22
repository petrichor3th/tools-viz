#include "MainWindow.h"
#include <QApplication>

int main(int argc, char* argv[])
{
    QApplication app(argc, argv);
    
    app.setApplicationName("Tools Viz");
    app.setApplicationVersion("1.0.0");
    app.setOrganizationName("ToolsViz");

    MainWindow mainWindow;
    mainWindow.show();

    return app.exec();
}
