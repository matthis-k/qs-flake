pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import "../utils"
import "../modules/bar" as Bar
import "../modules/quickmenu" as Quickmenu
import "../modules/hyprlandPreview/" as HyprlandPreview
import "../modules/applauncher" as AppLauncher
import "../components" as Components

Singleton {
    id: root

    readonly property alias instances: screenStates.instances
    component TestRect: Rectangle {
        implicitWidth: 200
        implicitHeight: 200
    }

    component ScreenState: QtObject {
        id: screenState

        required property ShellScreen modelData
        readonly property ShellScreen screen: screenState.modelData

        property Bar.Window bar: Bar.Window {
            screen: screenState.screen
            function open() {
                bar.visible = true;
            }
            function close() {
                bar.visible = false;
            }
            function toggle() {
                bar.visible = !bar.visible;
            }
            IpcHandler {
                target: `bar-${screen.name}`
                function open() {
                    bar.open();
                }
                function close() {
                    bar.close();
                }
                function toggle() {
                    bar.toggle();
                }
            }
        }

        property Quickmenu.Window quickmenu: Quickmenu.Window {
            screen: screenState.screen
        }

        property HyprlandPreview.Window hyprlandPreview: HyprlandPreview.Window {
            screen: screenState.screen
        }

        property AppLauncher.Window appLauncher: AppLauncher.Window {
            screen: screenState.screen
            function open() {
                appLauncher.visible = true;
            }
            function close() {
                appLauncher.visible = false;
            }
            function toggle() {
                appLauncher.visible = !appLauncher.visible;
            }
            IpcHandler {
                target: `applauncher-${screen.name}`
                function open() {
                    appLauncher.open();
                }
                function close() {
                    appLauncher.close();
                }
                function toggle() {
                    appLauncher.toggle();
                }
            }
        }
    }

    Variants {
        id: screenStates
        model: Quickshell.screens
        delegate: ScreenState {}
    }

    function forActiveScreens(callback) {
        Quickshell.screens.filter(screen => Hyprland.focusedMonitor && Hyprland.focusedMonitor == Hyprland.monitorFor(screen)).forEach(callback);
    }

    IpcHandler {
        target: "bar"
        function open() {
            forActiveScreens(screen => getScreenByName(screen.name).bar.open());
        }
        function close() {
            forActiveScreens(screen => getScreenByName(screen.name).bar.close());
        }
        function toggle() {
            forActiveScreens(screen => getScreenByName(screen.name).bar.toggle());
        }
    }
    IpcHandler {
        target: "applauncher"
        function open() {
            forActiveScreens(screen => getScreenByName(screen.name).appLauncher.open());
        }
        function close() {
            forActiveScreens(screen => getScreenByName(screen.name).appLauncher.close());
        }
        function toggle() {
            forActiveScreens(screen => getScreenByName(screen.name).appLauncher.toggle());
        }
    }

    function getScreenByName(screenName: string): ScreenState {
        return root.instances.find(screenState => screenState.screen.name == screenName);
    }

    function getScreenByRegex(screenRegex: string): list<ScreenState> {
        return root.instances.filter(screen => screen.name.matches(screenRegex));
    }
}
