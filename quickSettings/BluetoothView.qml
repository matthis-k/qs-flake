import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Bluetooth
import "../services" 1.0

Item {
    id: root
    width: implicitWidth
    height: implicitHeight
    implicitWidth: columnLayout.implicitWidth
    implicitHeight: columnLayout.implicitHeight
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

    ColumnLayout {
        id: columnLayout
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            spacing: 10

            IconImage {
                implicitWidth: 24
                implicitHeight: 24
                source: Quickshell.iconPath(btIconName(), "bluetooth-symbolic")
            }

            Text {
                Layout.fillWidth: true
                text: adapter ? `Bluetooth: ${adapterStateStr}` : "Bluetooth: Unavailable"
                color: Config.styling.text0
                font.pixelSize: 24
                elide: Text.ElideRight
            }

            Switch {
                visible: !!adapter
                checked: adapter && adapter.enabled
                onToggled: if (adapter) adapter.enabled = checked
            }
        }

        Text {
            visible: !!adapter
            Layout.fillWidth: true
            text: adapter ? `Adapter: ${adapter.name || "Unknown"}` : ""
            color: Config.styling.text1
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
                color: Config.styling.text1
                text: adapter ? `Discovering: ${adapter.discovering ? "yes" : "no"} · Discoverable: ${adapter.discoverable ? "yes" : "no"}` : ""
                elide: Text.ElideRight
            }

            Button {
                id: expandBtn
                text: expanded ? "Show less" : "Show more"
                onClicked: expanded = !expanded
                background: Rectangle {
                    radius: 8
                    color: Config.styling.bg2
                    border.width: 1
                    border.color: expandBtn.down ? Config.styling.primaryAccent : (expandBtn.hovered ? Config.styling.bg7 : Config.styling.bg6)
                }
            }
        }

        ListView {
            id: devicesList
            visible: expanded && !!adapter
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
                            color: modelData.connected ? Config.styling.good : Config.styling.text0
                            text: modelData.name || modelData.deviceName
                            elide: Text.ElideRight
                        }

                        Text {
                            visible: modelData.batteryAvailable
                            color: Config.styling.text1
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
                            }
                            background: Rectangle {
                                radius: 8
                                color: Config.styling.bg2
                                border.width: 1
                                border.color: actionBtn.down ? Config.styling.primaryAccent : (actionBtn.hovered ? Config.styling.bg7 : Config.styling.bg6)
                            }
                        }

                        Button {
                            id: forgetBtn
                            text: "Forget"
                            visible: modelData.paired || modelData.trusted
                            onClicked: modelData.forget()
                            background: Rectangle {
                                radius: 8
                                color: Config.styling.bg2
                                border.width: 1
                                border.color: forgetBtn.down ? Config.styling.primaryAccent : (forgetBtn.hovered ? Config.styling.bg7 : Config.styling.bg6)
                            }
                        }

                        Button {
                            id: cancelBtn
                            text: "Cancel"
                            visible: modelData.pairing
                            onClicked: modelData.cancelPair()
                            background: Rectangle {
                                radius: 8
                                color: Config.styling.bg2
                                border.width: 1
                                border.color: cancelBtn.down ? Config.styling.primaryAccent : (cancelBtn.hovered ? Config.styling.bg7 : Config.styling.bg6)
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Config.styling.bg4
                    }
                }
            }
        }
    }

    property bool expanded: false
}