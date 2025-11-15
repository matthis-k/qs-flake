pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick
import "../bar"

Singleton {
    Variants {
        id: barVariants
        model: Quickshell.screens

        Bar {
            screen: modelData
        }
    }

    IpcHandler {
        target: "bar"

        function open(): void {
            for (let bar of barVariants.instances) {
                bar.open();
            }
        }
        function hide(): void {
            for (let bar of barVariants.instances) {
                bar.close();
            }
        }
        function toggle(): void {
            for (let bar of barVariants.instances) {
                bar.toggle();
            }
        }
    }
}
