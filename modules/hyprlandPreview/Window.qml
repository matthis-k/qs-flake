import Quickshell
import QtQuick
import QtQuick.Controls
import "../../utils"
import "../../components"
import "../../services"

PanelWindow {
    id: win
    required property ShellScreen screen
    property alias view: selectView.currentView
    property alias views: selectView

    anchors {
        top: true
        left: true
    }

    implicitWidth: selectView.currentItem?.implicitWidth + 16 || 0
    implicitHeight: selectView.currentItem?.implicitHeight + 16 || 0

    visible: !!selectView.currentItem
    color: Config.styling.bg0

    SelectView {
        id: selectView
        anchors.centerIn: parent
        currentView: "hyprlandPreview"
    }

    property int externalHovers: 0
    readonly property bool _deferredClose: !(hoverHandler.hovered || externalHovers > 0)
    on_DeferredCloseChanged: _deferredClose ? closeTimer.start() : closeTimer.stop()

    HoverHandler {
        id: hoverHandler
        target: selectView
    }

    Timer {
        id: closeTimer
        interval: 300
        onTriggered: {
            selectView.remove("hyprlandPreview");
        }
    }
}
