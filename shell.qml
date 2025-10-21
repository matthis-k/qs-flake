//@ pragma UseQApplication
import Quickshell
import Quickshell.Io
import QtQuick
import "bar"

Scope {
    Bar {
        id: bar
    }

    IpcHandler {
        target: "bar"

        function show(): void {
            bar.show();
        }
        function hide(): void {
            bar.hide();
        }
        function toggle(): void {
            bar.toggle();
        }
    }
}
