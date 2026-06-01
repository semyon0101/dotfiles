import QtQuick
import Quickshell
import Quickshell.Widgets

Column {
    id: taskList
    spacing: 12

    property var windows: []
    property var iconMap: ({})
    property var niri: null

    Repeater {
        model: taskList.windows
        delegate: Item {
            width: 38
            height: 38
            anchors.horizontalCenter: parent.horizontalCenter
            Rectangle {
                anchors.fill: parent
                radius: 8
                color: modelData.is_focused ? "#fab387" : "transparent"
                opacity: 0.2
                visible: modelData.is_focused
            }
            IconImage {
                anchors.centerIn: parent
                width: 30
                height: 30
                source: Quickshell.iconPath(taskList.iconMap[modelData.app_id] || modelData.app_id)
            }
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: -4
                anchors.horizontalCenter: parent.horizontalCenter
                width: 4
                height: 4
                radius: 2
                color: "#fab387"
                visible: modelData.is_focused
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: if (niri) niri.focusWindow(modelData.id)
            }
        }
    }
}
