pragma Singleton
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import "../quickSettings"

Singleton {
    id: root
    property QuickSettings qs: QuickSettings {}

    HyprlandFocusGrab {
        id: focusGrab
        windows: [qs]
        active: qs.visible && !qs.isPeeking
    }

    IpcHandler {
        target: "quicksettings"

        function open(view: string): void {
            qs.open(view, false);
        }
        function close(): void {
            qs.close();
        }
        function toggle(view: string): void {
            qs.toggle(view, false);
        }
    }
    function open(view: string, peeking: bool): void {
        peeking = peeking || false;
        qs.open(view, peeking);
    }
    function close(timeout_ms: int): void {
        if (timeout_ms == null || timeout_ms == undefined) {
            timeout_ms = 0;
        }
        qs.close(timeout_ms);
    }
    function toggle(view: string, peeking: bool): void {
        peeking = peeking || false;
        qs.toggle(view, peeking);
    }
}
