pragma Singleton
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import "../quickSettings"

Singleton {
    property QuickSettings qs: QuickSettings {}

    HyprlandFocusGrab {
        id: focusGrab
        windows: [qs]
        active: qs.visible
    }

    IpcHandler {
        target: "quicksettings"

        function open(view: string): void {
            qs.currentView = view;
            qs.visible = true;
        }
        function close(): void {
            quickSettings.visible = false;
        }
        function toggle(view: string): void {
            if (qs.visible && qs.currentView == view) {
                close();
            } else {
                open(view);
            }
        }
    }

    function open(view: string): void {
        qs.currentView = view;
        qs.visible = true;
    }

    function close(): void {
        qs.visible = false;
    }

    function toggle(view: string): void {
        if (qs.visible && qs.currentView == view) {
            close();
        } else {
            open(view);
        }
    }
}
