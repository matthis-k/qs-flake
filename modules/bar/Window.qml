import Quickshell
import QtQuick
import "../../utils"

PanelWindow {
    required property ShellScreen screen
    anchors {
        top: true
        right: true
        left: true
    }
    implicitHeight: Math.round(Pixels.mm(10, screen)) | 1
    Bar {}

    function open() {
        visible = true;
    }
    function close() {
        visible = false;
    }
    function toggle() {
        visible = !visible;
    }
}
