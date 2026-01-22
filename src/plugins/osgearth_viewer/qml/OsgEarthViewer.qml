import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import OsgEarth 1.0

Rectangle {
    id: root
    color: "#2c3e50"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // 标题栏
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Label {
                text: qsTr("3D Earth Viewer")
                font.pixelSize: 18
                font.bold: true
                color: "white"
            }

            Item { Layout.fillWidth: true }

            // 导航按钮
            Button {
                text: "+"
                implicitWidth: 40
                onClicked: earthWidget.zoomIn()
                ToolTip.text: qsTr("Zoom In")
                ToolTip.visible: hovered
            }

            Button {
                text: "-"
                implicitWidth: 40
                onClicked: earthWidget.zoomOut()
                ToolTip.text: qsTr("Zoom Out")
                ToolTip.visible: hovered
            }

            Button {
                text: qsTr("Reset")
                onClicked: earthWidget.resetView()
                ToolTip.text: qsTr("Reset View")
                ToolTip.visible: hovered
            }
        }

        // 3D 地球视图
        EarthWidget {
            id: earthWidget
            Layout.fillWidth: true
            Layout.fillHeight: true

            // 可以设置 .earth 文件路径
            // earthFile: "path/to/your.earth"
        }

        // 状态栏
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Label {
                text: qsTr("Controls: Left-drag to rotate, Right-drag to pan, Scroll to zoom")
                color: "#95a5a6"
                font.pixelSize: 12
            }

            Item { Layout.fillWidth: true }

            // 快速导航
            ComboBox {
                id: locationCombo
                model: ListModel {
                    ListElement { text: "Beijing"; lon: 116.4; lat: 39.9 }
                    ListElement { text: "New York"; lon: -74.0; lat: 40.7 }
                    ListElement { text: "London"; lon: -0.12; lat: 51.5 }
                    ListElement { text: "Tokyo"; lon: 139.7; lat: 35.7 }
                }
                textRole: "text"
                implicitWidth: 120
                onActivated: function(index) {
                    var item = model.get(index)
                    earthWidget.goToLocation(item.lon, item.lat, 5000000)
                }
            }
        }
    }
}
