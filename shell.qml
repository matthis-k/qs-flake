//@ pragma UseQApplication
import Quickshell
import Quickshell.Io
import QtQuick
import "managers"

Scope {
    property BarManager bars: BarManager
    property PopupManager popups: PopupManager
    property AppLauncherManager appLauncher: AppLauncherManager
}
