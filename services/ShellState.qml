pragma Singleton
import QtQuick
import Quickshell
import "../utils"
import "../modules/bar" as Bar
import "../modules/quickmenu" as Quickmenu
import "../modules/hyprlandPreview/" as HyprlandPreview
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

        property QtObject bar: QtObject {
            property bool visible: true
            property int height: 28
            property bool pinned: true
            property bool autoHide: true

            property Bar.Window window: Bar.Window {
                screen: screenState.screen
            }
        }

        property Quickmenu.Window quickmenu: Quickmenu.Window {
            screen: screenState.screen
        }

        property HyprlandPreview.Window hyprlandPreview: HyprlandPreview.Window {
            screen: screenState.screen
        }
    }

    Variants {
        id: screenStates
        model: Quickshell.screens
        delegate: ScreenState {}
    }

    function getScreenByName(screenName: string): ScreenState {
        return root.instances.find(screenState => screenState.screen.name == screenName);
    }

    function getScreenByRegex(screenRegex: string): list<ScreenState> {
        return root.instances.filter(screen => screen.name.matches(screenRegex));
    }
}
