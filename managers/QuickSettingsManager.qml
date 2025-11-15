pragma Singleton
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import "../quickSettings"

Singleton {
    QuickSettings {
        id: quickSettings
    }

    HyprlandFocusGrab {
        id: focusGrab
        windows: [quickSettings]
        active: quickSettings.visible
    }

    IpcHandler {
        target: "quicksettings"

        function open(view: string): void {
            quickSettings.currentView = view;
            quickSettings.visible = true;
        }
        function close(): void {
            quickSettings.visible = false;
        }
        function toggle(view: string): void {
            if (quickSettings.visible && quickSettings.currentView == view) {
                close();
            } else {
                open(view);
            }
        }
    }

    function open(view: string): void {
        quickSettings.currentView = view;
        quickSettings.visible = true;
    }

    function close(): void {
        quickSettings.visible = false;
    }

    function toggle(view: string): void {
        if (quickSettings.visible && quickSettings.currentView == view) {
            close();
        } else {
            open(view);
        }
    }
}
