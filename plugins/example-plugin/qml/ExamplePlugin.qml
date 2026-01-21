import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#f5f5f5"
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10
        
        // 标题
        Label {
            text: qsTr("Example Text Editor")
            font.pixelSize: 18
            font.bold: true
            color: "#333"
        }
        
        // 文本编辑区
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            TextArea {
                id: textArea
                placeholderText: qsTr("Enter your text here...")
                font.pixelSize: 14
                wrapMode: TextEdit.Wrap
                background: Rectangle {
                    color: "white"
                    border.color: "#ccc"
                    border.width: 1
                    radius: 4
                }
            }
        }
        
        // 按钮栏
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            
            Item { Layout.fillWidth: true }
            
            Button {
                text: qsTr("Clear")
                onClicked: textArea.clear()
            }
            
            Label {
                text: qsTr("Characters: %1").arg(textArea.length)
                color: "#666"
            }
        }
    }
}
