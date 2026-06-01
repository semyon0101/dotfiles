import QtQuick
import Quickshell
import Quickshell.Widgets
import QtQuick.Layouts

Column {
    id: clockComp
    spacing: 2
    property var theme: null

    SystemClock {
        id: clock
    }

    Text {
        text: Qt.formatDateTime(clock.date, "HH")
        color: theme ? theme.text : "white"
        font.pixelSize: 18
        font.bold: true
        anchors.horizontalCenter: parent.horizontalCenter
    }
    Text {
        text: Qt.formatDateTime(clock.date, "mm")
        color: theme ? theme.subtext : "gray"
        font.pixelSize: 18
        anchors.horizontalCenter: parent.horizontalCenter
    }
    Rectangle {
        width: 20
        height: 2
        color: theme ? theme.surface1 : "gray"
        anchors.horizontalCenter: parent.horizontalCenter
        Layout.topMargin: 5
        Layout.bottomMargin: 5
    }
    Text {
        text: Qt.formatDateTime(clock.date, "dd")
        color: theme ? theme.text : "white"
        font.pixelSize: 14
        anchors.horizontalCenter: parent.horizontalCenter
    }
    Text {
        text: Qt.formatDateTime(clock.date, "MMM")
        color: theme ? theme.subtext : "gray"
        font.pixelSize: 12
        font.capitalization: Font.AllUppercase
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
