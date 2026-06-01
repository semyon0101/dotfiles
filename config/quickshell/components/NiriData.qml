import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: niriData

    property var workspaces: []
    property var windows: []
    property int activeWorkspaceId: -1
    property int activeWorkspaceIdx: 1

    signal windowAdded(string app_id)

    Process {
        id: niriWindowProc
        command: ["niri", "msg", "--json", "windows"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    let wins = JSON.parse(data);
                    wins.sort((a, b) => {
                        let posA = (a.layout && a.layout.pos_in_scrolling_layout) ? a.layout.pos_in_scrolling_layout[0] : 0;
                        let posB = (b.layout && b.layout.pos_in_scrolling_layout) ? b.layout.pos_in_scrolling_layout[0] : 0;
                        return posA - posB;
                    });
                    niriData.windows = wins;
                    wins.forEach(w => niriData.windowAdded(w.app_id));
                } catch (e) {
                    console.log("WINDOW JSON ERROR: " + e);
                }
            }
        }
    }

    Process {
        id: niriUpdateProc
        command: ["niri", "msg", "--json", "workspaces"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    let parsed = JSON.parse(data);
                    parsed.sort((a, b) => a.idx - b.idx);
                    niriData.workspaces = parsed;
                    for (let ws of parsed) {
                        if (ws.is_active) {
                            niriData.activeWorkspaceId = ws.id;
                            niriData.activeWorkspaceIdx = ws.idx;
                            break;
                        }
                    }
                } catch (e) {
                    console.log("WS JSON ERROR: " + e);
                }
            }
        }
    }

    Process {
        id: niriEventProc
        command: ["niri", "msg", "--json", "event-stream"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                if (niriUpdateProc.running) niriUpdateProc.running = false;
                niriUpdateProc.running = true;
                if (niriWindowProc.running) niriWindowProc.running = false;
                niriWindowProc.running = true;
            }
        }
    }

    Process {
        id: niriClickProc
        command: []
        function runAction(cmd) {
            command = cmd;
            if (running) running = false;
            running = true;
        }
    }

    function focusWorkspace(id) {
        niriClickProc.runAction(["niri", "msg", "action", "focus-workspace", id.toString()])
    }

    function focusWorkspaceByIdx(idx) {
        niriClickProc.runAction(["niri", "msg", "action", "focus-workspace", idx.toString()])
    }

    function focusWindow(id) {
        niriClickProc.runAction(["niri", "msg", "action", "focus-window", "--id", id.toString()])
    }
}
