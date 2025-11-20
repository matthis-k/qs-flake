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

Item {
    id: root
    implicitWidth: height
    implicitHeight: height

    property bool expanded: false
    property string expandedAddr: ""

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool btOn: !!adapter && adapter.enabled
    readonly property int connectedCount: adapter ? adapter.devices.values.length : 0
    readonly property string adapterStateStr: adapter ? BluetoothAdapterState.toString(adapter.state) : "Unavailable"

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
    IconImage {
        id: icon
        anchors.fill: parent
        anchors.margins: Math.floor(root.height * (1 - Config.styling.statusIconScaler) / 2)
        implicitSize: root.height
        source: Quickshell.iconPath(btIconName(), "bluetooth-symbolic")
        opacity: btOn ? 1.0 : 0.7
        mipmap: true
    }

    ColorOverlay {
        anchors.fill: icon
        color: btOn ? Config.styling.primaryAccent : Config.styling.critical
        source: icon
    }

    property bool peeking: false

    HoverHandler {
        onHoveredChanged: {
            if (hovered) {
                peeking = true;
                QuickSettingsManager.open("bluetooth", peeking);
            } else if (peeking) {
                QuickSettingsManager.close(500);
            }
        }
    }

    TapHandler {
        onSingleTapped: {
            keepOpen = false;
            QuickSettingsManager.toggle("bluetooth", peeking);
        }
    }
}
