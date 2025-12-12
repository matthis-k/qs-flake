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
}
