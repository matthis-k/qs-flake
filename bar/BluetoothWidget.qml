import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Bluetooth
import Qt5Compat.GraphicalEffects
import "../theme"
import "../components"

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
        anchors.centerIn: parent
        anchors.fill: parent
        color: btOn ? Theme.blue : Theme.red

        source: IconImage {
            anchors.fill: parent
            anchors.margins: 4
            implicitSize: 24
            source: Quickshell.iconPath(btOn ? "bluetooth-symbolic" : "bluetooth-disabled-symbolic", "bluetooth-symbolic")
            opacity: btOn ? 1.0 : 0.7
        }
    }

    GenericTooltip {
        anchors.centerIn: parent
        anchors.fill: parent
        background: Theme.crust
        canEnterTooltip: true

        tooltipContent: Rectangle {
            implicitWidth: 260
            implicitHeight: col.implicitHeight
            color: "transparent"

            ColumnLayout {
                id: col
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.left: parent.left
                spacing: 6

                RowLayout {
                    spacing: 8
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32

                    IconImage {
                        source: Quickshell.iconPath(btIconName(), "bluetooth-symbolic")
                        implicitSize: 16
                    }

                    Text {
                        Layout.fillWidth: true
                        color: Theme.text
                        text: adapter ? `${adapter.name || adapter.adapterId} — ${adapterStateStr}` : "Bluetooth: Unavailable"
                    }

                    Switch {
                        visible: !!adapter
                        checked: adapter && adapter.enabled
                        onToggled: if (adapter)
                            adapter.enabled = checked
                    }
                }

                RowLayout {
                    visible: !!adapter
                    spacing: 8
                    Layout.fillWidth: true
                    Layout.preferredHeight: 24

                    Text {
                        color: Theme.subtext0
                        text: adapter ? `Discovering: ${adapter.discovering ? "yes" : "no"} · Discoverable: ${adapter.discoverable ? "yes" : "no"}` : ""
                        Layout.fillWidth: true
                    }

                    Button {
                        visible: !!adapter
                        text: root.expanded ? "Show less" : "Show more"
                        background: Rectangle {
                            radius: Theme.rounded ? 8 : 0
                            color: Theme.base
                            border.width: 1
                            border.color: hovered ? Theme.overlay1 : Theme.overlay0
                        }
                        onClicked: root.expanded = !root.expanded
                    }
                }

                ListView {
                    id: devicesList
                    visible: root.expanded && !!adapter
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(240, contentHeight)
                    clip: true
                    spacing: 6
                    model: adapter ? adapter.devices : null

                    delegate: Item {
                        required property var modelData    
                        width: devicesList.width
                        height: contentCol.implicitHeight

                        ColumnLayout {
                            id: contentCol
                            anchors.fill: parent
                            spacing: 4

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 28
                                spacing: 8

                                IconImage {
                                    source: Quickshell.iconPath(modelData.icon || "bluetooth-symbolic", "bluetooth-symbolic")
                                    implicitSize: 16
                                }

                                Text {
                                    Layout.fillWidth: true
                                    color: modelData.connected ? Theme.green : Theme.text
                                    text: modelData.name || modelData.deviceName
                                }

                                Text {
                                    visible: modelData.batteryAvailable
                                    color: Theme.subtext0
                                    text: `${Math.round((modelData.battery ?? 0) * 100)}%`
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Button {
                                    text: modelData.connected ? "Disconnect" : (modelData.paired ? "Connect" : "Pair")
                                    background: Rectangle {
                                        radius: Theme.rounded ? 8 : 0
                                        color: Theme.base
                                        border.width: 1
                                        border.color: down ? Theme.blue : (hovered ? Theme.overlay1 : Theme.overlay0)
                                    }
                                    onClicked: {
                                        if (!modelData.paired) {
                                            modelData.pair();
                                        } else if (modelData.connected) {
                                            modelData.disconnect();
                                        } else {
                                            modelData.connect();
                                        }
                                        root.expandedAddr = "";
                                    }
                                }

                                Button {
                                    text: "Forget"
                                    visible: modelData.paired || modelData.trusted
                                    background: Rectangle {
                                        radius: Theme.rounded ? 8 : 0
                                        color: Theme.base
                                        border.width: 1
                                        border.color: down ? Theme.blue : (hovered ? Theme.overlay1 : Theme.overlay0)
                                    }
                                    onClicked: modelData.forget()
                                }

                                Button {
                                    text: "Cancel"
                                    visible: modelData.pairing
                                    background: Rectangle {
                                        radius: Theme.rounded ? 8 : 0
                                        color: Theme.base
                                        border.width: 1
                                        border.color: down ? Theme.blue : (hovered ? Theme.overlay1 : Theme.overlay0)
                                    }
                                    onClicked: modelData.cancelPair()
                                }
                            }

                            Rectangle {
                                height: 1
                                color: Theme.surface1
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
            }
        }
    }
}
