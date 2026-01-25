#include "EarthWidget.h"

#include <QOpenGLFramebufferObject>
#include <QQuickWindow>
#include <QMouseEvent>
#include <QWheelEvent>
#include <QDebug>

#include <osg/Camera>
#include <osg/Group>
#include <osgDB/ReadFile>
#include <osgGA/GUIEventAdapter>
#include <osgViewer/Viewer>
#include <osgEarth/EarthManipulator>
#include <osgEarth/MapNode>
#include <osgEarth/Viewpoint>
#include <osgEarth/Map>
#include <osgEarth/XYZImageLayer>
#include <osgEarth/Profile>

// ==============================================================================
// EarthRenderer - 负责 FBO 渲染
// ==============================================================================
class EarthWidget::EarthRenderer : public QQuickFramebufferObject::Renderer
{
public:
    EarthRenderer(EarthWidget* widget)
        : m_widget(widget)
    {
    }

    void render() override
    {
        if (m_widget->m_viewer.valid())
        {
            m_widget->m_viewer->frame();
        }
    }

    QOpenGLFramebufferObject* createFramebufferObject(const QSize& size) override
    {
        QOpenGLFramebufferObjectFormat format;
        format.setAttachment(QOpenGLFramebufferObject::CombinedDepthStencil);
        format.setSamples(4);
        return new QOpenGLFramebufferObject(size, format);
    }

    void synchronize(QQuickFramebufferObject* item) override
    {
        EarthWidget* widget = static_cast<EarthWidget*>(item);
        if (widget->m_viewer.valid())
        {
            auto camera = widget->m_viewer->getCamera();
            int w = static_cast<int>(widget->width());
            int h = static_cast<int>(widget->height());
            if (w > 0 && h > 0)
            {
                camera->setViewport(0, 0, w, h);
                camera->setProjectionMatrixAsPerspective(
                    30.0, static_cast<double>(w) / static_cast<double>(h), 1.0, 1e10);
            }
        }
    }

private:
    EarthWidget* m_widget;
};

// ==============================================================================
// EarthWidget 实现
// ==============================================================================
EarthWidget::EarthWidget(QQuickItem* parent)
    : QQuickFramebufferObject(parent)
{
    setAcceptedMouseButtons(Qt::AllButtons);
    setFlag(ItemAcceptsInputMethod, true);
    setMirrorVertically(true);

    initializeViewer();
}

EarthWidget::~EarthWidget()
{
    if (m_viewer.valid())
    {
        m_viewer->setDone(true);
    }
}

void EarthWidget::initializeViewer()
{
    // 初始化 OSG Viewer
    m_viewer = new osgViewer::Viewer;
    m_viewer->setThreadingModel(osgViewer::Viewer::SingleThreaded);
    m_viewer->setRunFrameScheme(osgViewer::Viewer::ON_DEMAND);

    // 设置 Earth Manipulator
    osg::ref_ptr<osgEarth::EarthManipulator> manipulator = new osgEarth::EarthManipulator();
    m_viewer->setCameraManipulator(manipulator);

    // 创建默认在线地图（OpenStreetMap）
    osg::ref_ptr<osgEarth::Map> map = new osgEarth::Map();
    
    // 添加 OpenStreetMap XYZ 图层
    osgEarth::XYZImageLayer* osmLayer = new osgEarth::XYZImageLayer();
    osmLayer->setName("OpenStreetMap");
    osmLayer->setURL("http://[abc].tile.openstreetmap.org/{z}/{x}/{-y}.png");
    osmLayer->setProfile(osgEarth::Profile::create("spherical-mercator"));
    map->addLayer(osmLayer);

    // 创建 MapNode 并设置为场景
    m_mapNode = new osgEarth::MapNode(map);
    m_viewer->setSceneData(m_mapNode);

    qInfo() << "EarthWidget: Initialized with default OpenStreetMap layer";
}

QQuickFramebufferObject::Renderer* EarthWidget::createRenderer() const
{
    return new EarthRenderer(const_cast<EarthWidget*>(this));
}

QString EarthWidget::earthFile() const
{
    return m_earthFile;
}

void EarthWidget::setEarthFile(const QString& file)
{
    if (m_earthFile != file)
    {
        m_earthFile = file;

        // 加载 .earth 文件
        osg::ref_ptr<osg::Node> node = osgDB::readNodeFile(file.toStdString());
        if (node.valid())
        {
            m_mapNode = osgEarth::MapNode::findMapNode(node);
            m_viewer->setSceneData(node);
        }

        emit earthFileChanged();
        update();
    }
}

void EarthWidget::zoomIn()
{
    osgEarth::EarthManipulator* manipulator = dynamic_cast<osgEarth::EarthManipulator*>(
        m_viewer->getCameraManipulator());
    if (manipulator)
    {
        osgEarth::Viewpoint vp = manipulator->getViewpoint();
        double range = vp.range()->as(osgEarth::Units::METERS);
        vp.range()->set(range * 0.8, osgEarth::Units::METERS);
        manipulator->setViewpoint(vp, 0.5);
    }
    update();
}

void EarthWidget::zoomOut()
{
    osgEarth::EarthManipulator* manipulator = dynamic_cast<osgEarth::EarthManipulator*>(
        m_viewer->getCameraManipulator());
    if (manipulator)
    {
        osgEarth::Viewpoint vp = manipulator->getViewpoint();
        double range = vp.range()->as(osgEarth::Units::METERS);
        vp.range()->set(range * 1.25, osgEarth::Units::METERS);
        manipulator->setViewpoint(vp, 0.5);
    }
    update();
}

void EarthWidget::resetView()
{
    osgEarth::EarthManipulator* manipulator = dynamic_cast<osgEarth::EarthManipulator*>(
        m_viewer->getCameraManipulator());
    if (manipulator)
    {
        manipulator->home(0);
    }
    update();
}

void EarthWidget::goToLocation(double lon, double lat, double altitude)
{
    osgEarth::EarthManipulator* manipulator = dynamic_cast<osgEarth::EarthManipulator*>(
        m_viewer->getCameraManipulator());
    if (manipulator)
    {
        osgEarth::Viewpoint vp;
        vp.focalPoint() = osgEarth::GeoPoint(osgEarth::SpatialReference::get("wgs84"), lon, lat, 0);
        vp.pitch()->set(-90.0, osgEarth::Units::DEGREES);
        vp.range()->set(altitude, osgEarth::Units::METERS);
        manipulator->setViewpoint(vp, 2.0);
    }
    update();
}

void EarthWidget::mousePressEvent(QMouseEvent* event)
{
    if (m_viewer.valid())
    {
        int button = 0;
        if (event->button() == Qt::LeftButton) button = 1;
        else if (event->button() == Qt::MiddleButton) button = 2;
        else if (event->button() == Qt::RightButton) button = 3;

        m_viewer->getEventQueue()->mouseButtonPress(
            static_cast<float>(event->position().x()),
            static_cast<float>(event->position().y()),
            button);
    }
    update();
}

void EarthWidget::mouseMoveEvent(QMouseEvent* event)
{
    if (m_viewer.valid())
    {
        m_viewer->getEventQueue()->mouseMotion(
            static_cast<float>(event->position().x()),
            static_cast<float>(event->position().y()));
    }
    update();
}

void EarthWidget::mouseReleaseEvent(QMouseEvent* event)
{
    if (m_viewer.valid())
    {
        int button = 0;
        if (event->button() == Qt::LeftButton) button = 1;
        else if (event->button() == Qt::MiddleButton) button = 2;
        else if (event->button() == Qt::RightButton) button = 3;

        m_viewer->getEventQueue()->mouseButtonRelease(
            static_cast<float>(event->position().x()),
            static_cast<float>(event->position().y()),
            button);
    }
    update();
}

void EarthWidget::wheelEvent(QWheelEvent* event)
{
    if (m_viewer.valid())
    {
        if (event->angleDelta().y() > 0)
        {
            m_viewer->getEventQueue()->mouseScroll(osgGA::GUIEventAdapter::SCROLL_UP);
        }
        else
        {
            m_viewer->getEventQueue()->mouseScroll(osgGA::GUIEventAdapter::SCROLL_DOWN);
        }
    }
    update();
}
