import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Bluetooth
import Qt5Compat.GraphicalEffects
import "../theme"
import "../components"
import "../managers"

Item {
    id: root
    implicitWidth: parent?.height ?? 24
    implicitHeight: parent?.height ?? 24

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

    ColorOverlay {
        id: btOverlay
        anchors.fill: parent
        color: btOn ? Theme.blue : Theme.red
        source: IconImage {
            anchors.fill: parent
            anchors.margins: 4
            implicitSize: 24
            source: Quickshell.iconPath(btIconName(), "bluetooth-symbolic")
            opacity: btOn ? 1.0 : 0.7
        }
    }

    TapHandler {
        onSingleTapped: {
            QuickSettingsManager.toggle("bluetooth");
        }
    }
}
