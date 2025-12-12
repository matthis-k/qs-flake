import Quickshell
import QtQuick
import QtQuick.Controls
import "../../utils"
import "../../components"
import "../../services"

PanelWindow {
    id: win
    required property ShellScreen screen
    property alias view: selection.currentView

    anchors {
        top: true
        right: true
    }

    implicitWidth: selection.currentItem?.implicitWidth + 16 || 0
    implicitHeight: selection.currentItem?.implicitHeight + 16 || 0
    visible: !!selection.currentItem
    color: Config.styling.bg0

    SelectView {
        id: selection
        anchors.centerIn: parent
        SelectView.Option {
            key: "power"
            item: Power {}
        }
        SelectView.Option {
            key: "battery"
            item: Battery {}
        }
        SelectView.Option {
            key: "network"
            item: Network {}
        }
        SelectView.Option {
            key: "bluetooth"
            item: Bluetooth {}
        }
        SelectView.Option {
            key: "audio"
            item: Audio {}
        }
    }

    property int externalHovers: 0
    readonly property bool _deferredClose: !(hoverHandler.hovered || externalHovers > 0)
    on_DeferredCloseChanged: _deferredClose ? closeTimer.start() : closeTimer.stop()

    HoverHandler {
        id: hoverHandler
        target: selection
    }

    Timer {
        id: closeTimer
        interval: 300
        onTriggered: {
            selection.currentView = null;
        }
    }
}
