import Quickshell
import Quickshell.Io
import QtQuick

Item {
    Component.onCompleted: {
        console.log("Bar State initialized, screens:", Quickshell.screens.length, "bars:", barVariants.instances.length);
    }

    Variants {
        id: barVariants
        model: Quickshell.screens

        delegate: Scope {
            id: perScreen
            required property var modelData
            Bar {
                screen: perScreen.modelData
            }

            IpcHandler {
                target: "bar-" + perScreen.modelData.name

                function open(): void {
                    modelData.open();
                }
                function hide(): void {
                    modelData.close();
                }
                function toggle(): void {
                    modelData.toggle();
                }
            }
        }
    }

    IpcHandler {
        target: "bar"

        function open(screenRegex: string): void {
            const regex = screenRegex ? new RegExp(screenRegex) : null;
            for (let bar of barVariants.instances) {
                if (!regex || regex.test(bar.screen.name)) {
                    bar.open();
                }
            }
        }
        function hide(screenRegex: string): void {
            const regex = screenRegex ? new RegExp(screenRegex) : null;
            for (let bar of barVariants.instances) {
                if (!regex || regex.test(bar.screen.name)) {
                    bar.close();
                }
            }
        }
        function toggle(screenRegex: string): void {
            const regex = screenRegex ? new RegExp(screenRegex) : null;
            for (let bar of barVariants.instances) {
                if (!regex || regex.test(bar.screen.name)) {
                    bar.toggle();
                }
            }
        }
    }
}
