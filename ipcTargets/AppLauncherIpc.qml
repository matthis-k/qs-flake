pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick
import "../panels"

Singleton {
    AppLauncherPanel {
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