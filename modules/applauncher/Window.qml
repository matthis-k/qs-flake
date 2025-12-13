import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import "../../services"
import "../../components"
import "."

PanelWindow {
    id: win
    required property ShellScreen screen
    focusable: true

    color: "transparent"
    visible: false

    implicitWidth: launcher.implicitWidth + 32
    implicitHeight: launcher.implicitHeight + 32

    anchors {
        top: true
        right: true
        bottom: true
        left: true
    }

    AppLauncher {
        id: launcher
        anchors.centerIn: parent
    }

    function open() {
        resume = resume || false;
        win.visible = true;
    }

    function close() {
        visiblefalse;
    }

    function toggle() {
        if (win.visible) {
            close();
        } else {
            open(resume);
        }
    }
}
