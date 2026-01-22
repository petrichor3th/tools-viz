#ifndef EARTH_WIDGET_H
#define EARTH_WIDGET_H

#include <QQuickFramebufferObject>
#include <osg/ref_ptr>

namespace osgViewer {
    class Viewer;
}

namespace osgEarth {
    class MapNode;
}

class EarthWidget : public QQuickFramebufferObject
{
    Q_OBJECT
    Q_PROPERTY(QString earthFile READ earthFile WRITE setEarthFile NOTIFY earthFileChanged)

public:
    explicit EarthWidget(QQuickItem* parent = nullptr);
    ~EarthWidget() override;

    Renderer* createRenderer() const override;

    QString earthFile() const;
    void setEarthFile(const QString& file);

    // 导航控制
    Q_INVOKABLE void zoomIn();
    Q_INVOKABLE void zoomOut();
    Q_INVOKABLE void resetView();
    Q_INVOKABLE void goToLocation(double lon, double lat, double altitude);

signals:
    void earthFileChanged();

protected:
    void mousePressEvent(QMouseEvent* event) override;
    void mouseMoveEvent(QMouseEvent* event) override;
    void mouseReleaseEvent(QMouseEvent* event) override;
    void wheelEvent(QWheelEvent* event) override;

private:
    class EarthRenderer;
    friend class EarthRenderer;

    QString m_earthFile;
    osg::ref_ptr<osgViewer::Viewer> m_viewer;
    osg::ref_ptr<osgEarth::MapNode> m_mapNode;

    void initializeViewer();
};

#endif // EARTH_WIDGET_H
