import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "components"

ShellRoot {
    id: root

    // Central Theme Configuration
    Theme { id: theme }

    NiriData {
        id: niri
        onWindowAdded: app_id => iconManager.addToQueue(app_id)
    }

    IconManager {
        id: iconManager
    }

    PanelWindow {
        id: panel
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.exclusiveZone: 50

        anchors {
            left: true
            top: true
            bottom: true
        }

        width: 50
        color: theme.bg

        ColumnLayout {
            id: content
            anchors.fill: parent
            anchors.topMargin: 15
            anchors.bottomMargin: 15
            spacing: 0
            
            opacity: 0
            transform: Translate { id: entryTranslate; x: -20 }
            
            Component.onCompleted: {
                entryAnim.start()
            }
            
            ParallelAnimation {
                id: entryAnim
                NumberAnimation { target: content; property: "opacity"; to: 1; duration: 500; easing.type: Easing.OutCubic }
                NumberAnimation { target: entryTranslate; property: "x"; to: 0; duration: 500; easing.type: Easing.OutBack }
            }

            WorkspaceList {
                Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
                workspaces: niri.workspaces
                activeIdx: niri.activeWorkspaceIdx
                allWindows: niri.windows
                iconMap: iconManager.iconMap
                niri: niri
                theme: theme
            }

            Item { Layout.fillHeight: true }

            VerticalClock {
                Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
                Layout.topMargin: 20
                theme: theme
            }
        }
    }
}
