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
        anchors.fill: parent
        background: Theme.crust
        canEnterTooltip: true

        tooltipContent: ColumnLayout {
            id: col
            spacing: 8
            width: 280

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                spacing: 10

                ColorOverlay {
                    id: headerIcon
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    color: btOn ? Theme.blue : Theme.red
                    source: IconImage {
                        anchors.fill: parent
                        source: Quickshell.iconPath(btIconName(), "bluetooth-symbolic")
                        implicitSize: 32
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: adapter ? `Bluetooth: ${adapterStateStr}` : "Bluetooth: Unavailable"
                    color: Theme.text
                    font.pixelSize: 24
                    elide: Text.ElideRight
                }

                Switch {
                    visible: !!adapter
                    checked: adapter && adapter.enabled
                    onToggled: if (adapter)
                        adapter.enabled = checked
                }
            }

            Text {
                Layout.fillWidth: true
                visible: !!adapter
                text: adapter ? (adapter.name || "Unknown adapter") : ""
                color: Theme.subtext0
                font.pixelSize: 12
                elide: Text.ElideRight
            }

            RowLayout {
                visible: !!adapter
                Layout.fillWidth: true
                Layout.preferredHeight: 28
                spacing: 8

                Text {
                    Layout.fillWidth: true
                    color: Theme.subtext0
                    text: adapter ? `Discovering: ${adapter.discovering ? "yes" : "no"} · Discoverable: ${adapter.discoverable ? "yes" : "no"}` : ""
                    elide: Text.ElideRight
                }

                Button {
                    id: expandBtn
                    text: root.expanded ? "Show less" : "Show more"
                    onClicked: root.expanded = !root.expanded
                    background: Rectangle {
                        radius: Theme.rounded ? 8 : 0
                        color: Theme.base
                        border.width: 1
                        border.color: expandBtn.down ? Theme.blue : (expandBtn.hovered ? Theme.overlay1 : Theme.overlay0)
                    }
                }
            }

            ListView {
                id: devicesList
                visible: root.expanded && !!adapter
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(260, contentHeight)
                spacing: 6
                clip: true
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
                                elide: Text.ElideRight
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
                                id: actionBtn
                                text: modelData.connected ? "Disconnect" : (modelData.paired ? "Connect" : "Pair")
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
                                background: Rectangle {
                                    radius: Theme.rounded ? 8 : 0
                                    color: Theme.base
                                    border.width: 1
                                    border.color: actionBtn.down ? Theme.blue : (actionBtn.hovered ? Theme.overlay1 : Theme.overlay0)
                                }
                            }

                            Button {
                                id: forgetBtn
                                text: "Forget"
                                visible: modelData.paired || modelData.trusted
                                onClicked: modelData.forget()
                                background: Rectangle {
                                    radius: Theme.rounded ? 8 : 0
                                    color: Theme.base
                                    border.width: 1
                                    border.color: forgetBtn.down ? Theme.blue : (forgetBtn.hovered ? Theme.overlay1 : Theme.overlay0)
                                }
                            }

                            Button {
                                id: cancelBtn
                                text: "Cancel"
                                visible: modelData.pairing
                                onClicked: modelData.cancelPair()
                                background: Rectangle {
                                    radius: Theme.rounded ? 8 : 0
                                    color: Theme.base
                                    border.width: 1
                                    border.color: cancelBtn.down ? Theme.blue : (cancelBtn.hovered ? Theme.overlay1 : Theme.overlay0)
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: Theme.surface1
                        }
                    }
                }
            }
        }
    }
}
