import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

Item {
    id: workspaceRoot
    width: 38
    height: 150 + (4 * 16) + (4 * 4)

    property var workspaces: []
    property int activeIdx: 1
    property var allWindows: []
    property var iconMap: ({})
    property var niri: null
    property var theme: null

    property int currentChunk: Math.floor((activeIdx - 1) / 5)

    property var displayWorkspaces: {
        let start = currentChunk * 5 + 1;
        let list = [];
        for (let i = 0; i < 5; i++) {
            let currentIdx = start + i;
            let actualWS = workspaces.find(ws => ws.idx === currentIdx);
            list.push({
                idx: currentIdx,
                id: actualWS ? actualWS.id : null,
                is_active: currentIdx === activeIdx,
                exists: !!actualWS,
                localIdx: i
            });
        }
        return list;
    }

    Column {
        id: wsColumn
        spacing: 4
        anchors.fill: parent

        Repeater {
            model: workspaceRoot.displayWorkspaces
            delegate: Item {
                id: wsItem
                width: 38
                property bool isExpanded: modelData.is_active
                property bool exists: modelData.exists
                height: isExpanded ? 150 : 16
                
                opacity: 0
                scale: 0.8
                transform: Translate { id: itemTrans; y: 10 }

                Component.onCompleted: entranceAnim.start()
                
                SequentialAnimation {
                    id: entranceAnim
                    PauseAnimation { duration: modelData.localIdx * 50 }
                    ParallelAnimation {
                        NumberAnimation { target: wsItem; property: "opacity"; to: 1; duration: 400; easing.type: Easing.OutCubic }
                        NumberAnimation { target: wsItem; property: "scale"; to: 1; duration: 400; easing.type: Easing.OutBack }
                        NumberAnimation { target: itemTrans; property: "y"; to: 0; duration: 400; easing.type: Easing.OutCubic }
                    }
                }

                Behavior on height { NumberAnimation { duration: 400; easing.type: Easing.OutBack } }

                MouseArea {
                    id: wsMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: (modelData.is_active || !exists) ? Qt.ArrowCursor : Qt.PointingHandCursor
                    onClicked: if (niri && !modelData.is_active && exists) niri.focusWorkspaceByIdx(modelData.idx)
                }

                Rectangle {
                    anchors.fill: visualRect
                    anchors.margins: -4
                    radius: visualRect.radius + 2
                    color: "transparent"
                    border.color: theme ? theme.accent : "white"
                    border.width: 1
                    opacity: isExpanded ? 0.3 : 0
                    visible: isExpanded

                    SequentialAnimation on opacity {
                        running: wsItem.isExpanded
                        loops: Animation.Infinite
                        NumberAnimation { from: 0.1; to: 0.4; duration: 1500; easing.type: Easing.InOutQuad }
                        NumberAnimation { from: 0.4; to: 0.1; duration: 1500; easing.type: Easing.InOutQuad }
                    }
                }

                Rectangle {
                    id: visualRect
                    anchors.centerIn: parent
                    width: isExpanded ? 38 : (exists ? 10 : 6)
                    height: isExpanded ? 150 : (exists ? 10 : 6)
                    radius: isExpanded ? 16 : height / 2
                    
                    scale: (wsMouse.containsMouse && !modelData.is_active && exists) ? 1.3 : 1.0
                    Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }

                    color: isExpanded ? (theme ? theme.surface : "gray") : (exists ? (theme ? theme.accent : "blue") : (theme ? theme.overlay : "darkgray"))
                    border.color: isExpanded ? (theme ? theme.accent : "white") : "transparent"
                    border.width: isExpanded ? 3 : 0

                    Behavior on width { NumberAnimation { duration: 350; easing.type: Easing.OutBack } }
                    Behavior on height { NumberAnimation { duration: 350; easing.type: Easing.OutBack } }
                    Behavior on color { ColorAnimation { duration: 300 } }

                    Rectangle {
                        id: focusSlider
                        z: 5
                        property var wsWindows: workspaceRoot.allWindows.filter(win => win.workspace_id === modelData.id)
                        property int focusedIdx: {
                            for (let i = 0; i < wsWindows.length; i++) {
                                if (wsWindows[i].is_focused) return i;
                            }
                            return -1;
                        }
                        visible: isExpanded && focusedIdx !== -1
                        opacity: visible ? 1 : 0
                        width: 3
                        height: appColumn.iconSize * 0.7
                        radius: 1.5
                        color: theme ? theme.highlight : "orange"
                        x: 5
                        y: 6 + focusedIdx * (appColumn.iconSize + 4) + (appColumn.iconSize * 0.15)
                        Behavior on y { NumberAnimation { duration: 350; easing.type: Easing.OutBack } }
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                    }

                    Column {
                        id: appColumn
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 4
                        visible: isExpanded
                        
                        property var wsWindows: focusSlider.wsWindows
                        property int winCount: wsWindows.length
                        property real iconSize: {
                            if (winCount === 0) return 0;
                            let avail = parent.height - 12;
                            let slots = Math.max(5, winCount);
                            let totalSpacing = (slots - 1) * spacing;
                            return (avail - totalSpacing) / slots;
                        }

                        Repeater {
                            model: isExpanded ? appColumn.wsWindows : []
                            delegate: Item {
                                width: 26
                                height: appColumn.iconSize
                                anchors.horizontalCenter: parent.horizontalCenter
                                
                                IconImage {
                                    id: iconImg
                                    anchors.centerIn: parent
                                    width: Math.min(24, parent.height)
                                    height: width
                                    source: Quickshell.iconPath(workspaceRoot.iconMap[modelData.app_id] || modelData.app_id)
                                    opacity: modelData.is_focused ? 1.0 : 0.6
                                    
                                    Behavior on opacity { NumberAnimation { duration: 200 } }
                                    
                                    scale: modelData.is_focused ? 1.1 : (iconMouse.containsMouse ? 1.25 : 1.0)
                                    Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
                                }

                                MouseArea {
                                    id: iconMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: modelData.is_focused ? Qt.ArrowCursor : Qt.PointingHandCursor
                                    onClicked: if (niri && !modelData.is_focused) niri.focusWindow(modelData.id)
                                }
                            }
                        }
                    }
                    
                    Rectangle {
                        visible: isExpanded && appColumn.winCount === 0
                        width: 6
                        height: 6
                        radius: 3
                        color: theme ? theme.accent : "blue"
                        anchors.centerIn: parent
                    }
                }
            }
        }
    }
}
