import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Bluetooth
import Qt5Compat.GraphicalEffects
import "../services"
import "../components"
import "../managers"
import "../quickSettings"

Item {
    id: root
    implicitWidth: height
    implicitHeight: height

    Component {
        id: bluetoothPopupComponent
        BluetoothView {}
    }

    property bool expanded: false
    property string expandedAddr: ""

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool btOn: !!adapter && adapter.enabled
    readonly property int connectedCount: adapter ? adapter.devices.values.length : 0
    readonly property string adapterStateStr: adapter ? BluetoothAdapterState.toString(adapter.state) : "Unavailable"
    readonly property real iconMargin: Math.floor(root.height * (1 - Config.styling.statusIconScaler) / 2)

    function btIconName() {
        if (!adapter)
            return "bluetooth-disabled-symbolic";
        if (adapter.state === BluetoothAdapterState.Blocked)
            return "bluetooth-disabled-symbolic";
        if (!adapter.enabled || adapter.state === BluetoothAdapterState.Disabled)
            return "bluetooth-disabled-symbolic";
        if (connectedCount > 0)
            return "bluetooth-connected-symbolic";
        if (adapter.discovering)
            return "bluetooth-searching-symbolic";
        return "bluetooth-symbolic";
    }
    Item {
        id: iconWrapper
        anchors.fill: parent
        anchors.margins: iconMargin
        transformOrigin: Item.Center
        scale: hoverHandler.hovered ? 1.25 : 1

        Behavior on scale {
            enabled: Config.styling.animation.enabled
            NumberAnimation {
                duration: Config.styling.animation.calc(0.1)
                easing.type: Easing.Bezier
                easing.bezierCurve: [0.4, 0.0, 0.2, 1.0]
            }
        }

        IconImage {
            id: icon
            anchors.fill: parent
            source: Quickshell.iconPath(btIconName(), "bluetooth-symbolic")
            opacity: btOn ? 1.0 : 0.7
            mipmap: true
        }

        ColorOverlay {
            anchors.fill: parent
            color: btOn ? Config.styling.primaryAccent : Config.styling.critical
            source: icon
        }
    }

    property bool peeking: false

    HoverHandler {
        id: hoverHandler
        onHoveredChanged: {
            if (hovered) {
                peeking = true;
                PopupManager.anchors.topRight.show(bluetoothPopupComponent, {
                    peeking: peeking
                });
            } else if (peeking) {
                PopupManager.anchors.topRight.hide(500);
            }
        }
    }

    TapHandler {
        onSingleTapped: {
            peeking = false;
            PopupManager.anchors.topRight.toggle(bluetoothPopupComponent, {
                peeking: peeking
            });
        }
    }
}
