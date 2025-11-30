import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Bluetooth
import Qt5Compat.GraphicalEffects
import "../services"
import "../components"
import "../panels"

Item {
    id: root
    implicitWidth: height
    implicitHeight: height

    Component {
        id: bluetoothPopupComponent
        BluetoothPanel {}
    }

    property bool expanded: false

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

    StatusIcon {
        anchors.fill: parent
        iconName: btIconName()
        overlayColor: btOn ? Config.styling.primaryAccent : Config.styling.critical
        popupComponent: bluetoothPopupComponent
    }
}
