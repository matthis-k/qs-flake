//@ pragma UseQApplication
import Quickshell
import Quickshell.Io
import QtQuick
import "bar"
import "applauncher"

Scope {
    Bar {
        id: bar
    }

    IpcHandler {
        target: "bar"

        function open(): void {
            bar.open();
        }
        function hide(): void {
            bar.close();
        }
        function toggle(): void {
            bar.toggle();
        }
    }

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
