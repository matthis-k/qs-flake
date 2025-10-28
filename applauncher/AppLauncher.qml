import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../theme"
import "../components"

PanelWindow {
    id: appLauncherWin
    visible: false

    function open(): void {
        appLauncherWin.visible = true;
    }
    function close(): void {
        appLauncherWin.visible = false;
    }
    function toggle(): void {
        appLauncherWin.visible = !appLauncherWin.visible;
    }
}
