pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick
import "../applauncher"

Singleton {
    AppLauncher {
        id: appLauncher
    }

    IpcHandler {
        target: "applauncher"

        function open(): void {
            appLauncher.open();
        }
        function close(): void {
            appLauncher.close();
        }
        function toggle(): void {
            appLauncher.toggle();
        }
    }
}
