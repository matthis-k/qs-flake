//@ pragma UseQApplication
import Quickshell
import Quickshell.Io
import QtQuick
import "managers"

Scope {
    property BarManager bars: BarManager
    property QuickSettingsManager qs: QuickSettingsManager
    property AppLauncherManager appLauncher: AppLauncherManager
}
