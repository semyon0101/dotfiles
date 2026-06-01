import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: manager

    property var iconMap: ({})
    property var cmdQueue: []
    property bool isProcessing: false

    function addToQueue(app_id) {
        if (!app_id || iconMap[app_id] || cmdQueue.indexOf(app_id) !== -1)
            return;
        cmdQueue.push(app_id);
        if (!isProcessing)
            runNext();
    }

    function runNext() {
        if (cmdQueue.length === 0) {
            isProcessing = false;
            return;
        }
        isProcessing = true;
        let id = cmdQueue.shift();
        syncProcess.currentId = id;
        syncProcess.command = ["bash", "-c", "grep \"^Icon=\" /usr/share/applications/" + id + ".desktop | head -n1 | cut -d= -f2"];
        syncProcess.running = true;
    }

    Process {
        id: syncProcess
        property string currentId: ""
        stdout: StdioCollector {
            onStreamFinished: {
                let icon = text.trim();
                let newMap = Object.assign({}, manager.iconMap);
                newMap[syncProcess.currentId] = icon || syncProcess.currentId;
                manager.iconMap = newMap;
                manager.runNext();
            }
        }
    }
}
