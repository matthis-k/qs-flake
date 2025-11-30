//@ pragma UseQApplication
import Quickshell
import Quickshell.Io
import QtQuick
import "./bar"
import "./ipcTargets"
import "./panels"

Scope {
    BarState {
        id: barState
    }
    PanelState {
        id: panelState
    }
    property var appLauncher: AppLauncherIpc
    property var popups: panelState
}
