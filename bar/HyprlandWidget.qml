import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import "../theme"
import "../components"

RowLayout {
    id: root
    ScriptModel {
        id: workspaceModel
        objectProp: "id"
        values: {
            const defaultIds = [1, 2, 3, 4, 5];
            const focusedId = Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1;
            let ids = [...defaultIds];
            if (!ids.includes(focusedId)) {
                ids.push(focusedId);
            }
            return ids.map(id => {
                const ws = Hyprland.workspaces.values.find(w => w.id === id);
                return ws || {
                    id: id,
                    activate: () => {
                        Hyprland.dispatch(`workspace ${id}`);
                    }
                };
            });
        }
    }

    Repeater {
        model: workspaceModel
        delegate: Pill {
            id: pill
            required property var modelData
            property var workspace: modelData
            Layout.fillHeight: true
            header: Item {
                anchors.centerIn: parent
                Text {
                    anchors.centerIn: parent
                    text: pill.workspace.id
                    color: (Hyprland.focusedWorkspace?.id || -1) == pill.workspace.id ? Theme.green : Theme.text
                    font.bold: true
                    font.pixelSize: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id == pill.workspace.id ? 18 : 14
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: function (mouse) {
                            if (mouse.button === Qt.LeftButton && Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id !== pill.workspace.id) {
                                pill.workspace.activate();
                            }
                        }
                    }
                }
            }

            Repeater {
                model: pill.workspace.toplevels ? pill.workspace.toplevels.values.filter(t => t.title !== "Wayland to X Recording bridge — Xwayland Video Bridge") : []
                delegate: Rectangle {
                    id: windowIconDelegate
                    required property HyprlandToplevel modelData
                    property HyprlandToplevel toplevel: modelData
                    implicitWidth: root.height
                    implicitHeight: root.height
                    color: "transparent"

                    property string appId: toplevel.wayland?.appId || ""
                    property var entry: null
                    function refreshEntry() {
                        entry = DesktopEntries.heuristicLookup(appId);
                    }

                    Component.onCompleted: refreshEntry()
                    onAppIdChanged: refreshEntry()
                    Connections {
                        target: DesktopEntries
                        function onApplicationsChanged() {
                            windowIconDelegate.refreshEntry();
                        }
                    }

                    IconImage {
                        id: windowIcon
                        implicitSize: root.height - 8
                        asynchronous: true
                        mipmap: true
                        anchors.centerIn: parent
                        source: Quickshell.iconPath(windowIconDelegate.entry?.icon || "dialog-warning", "dialog-warning")
                    }

                    TapHandler {
                        parent: windowIcon
                        acceptedButtons: Qt.LeftButton
                        onTapped: {
                            if (windowIconDelegate.toplevel?.wayland) {
                                windowIconDelegate.toplevel.wayland.activate();
                            }
                        }
                    }

                    TapHandler {
                        parent: windowIcon
                        acceptedButtons: Qt.MiddleButton
                        onTapped: {
                            if (windowIconDelegate.toplevel?.wayland) {
                                windowIconDelegate.toplevel.wayland.close();
                            }
                        }
                    }

                    Rectangle {
                        property real h: Math.max(2, root.height / 16)
                        anchors {
                            bottom: windowIcon.top
                            horizontalCenter: windowIcon.horizontalCenter
                        }
                        height: h
                        width: windowIcon.width
                        color: Theme.green
                        visible: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === pill.workspace.id && !!windowIconDelegate.toplevel?.activated
                        bottomRightRadius: 2 * h
                        bottomLeftRadius: 2 * h
                        z: -1
                        antialiasing: true
                        clip: true
                    }

                    GenericTooltip {
                        id: tt
                        canEnterTooltip: true
                        tooltipContent: ColumnLayout {
                            anchors.fill: parent
                            RowLayout {
                                id: titleRow
                                Layout.fillWidth: true
                                spacing: 6

                                Text {
                                    id: title
                                    text: windowIconDelegate.toplevel.title
                                    color: Theme.text
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.maximumWidth: view.width - closeButton.implicitWidth - 8
                                }

                                Item {
                                    id: closeButton
                                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                                    width: 24
                                    height: 24
                                    Rectangle {
                                        anchors.fill: parent
                                        color: {
                                            if (tapHandler.pressed)
                                                return Qt.darker(Theme.red, 1.3);
                                            else
                                                return hoverHandler.hovered ? Theme.red : Theme.crust;
                                        }
                                        radius: Theme.rounded * parent.height / 2
                                    }

                                    ColorOverlay {
                                        anchors.fill: parent
                                        color: hoverHandler.hovered ? Theme.crust : Theme.red
                                        source: IconImage {
                                            anchors.centerIn: parent
                                            source: Quickshell.iconPath("window-close", "dialog-close")
                                            implicitSize: 20
                                            asynchronous: true
                                            mipmap: true
                                        }
                                    }

                                    HoverHandler {
                                        id: hoverHandler
                                    }

                                    TapHandler {
                                        id: tapHandler
                                        acceptedButtons: Qt.LeftButton
                                        onTapped: {
                                            windowIconDelegate.toplevel?.wayland?.close();
                                        }
                                    }
                                }
                            }
                            ScreencopyView {
                                id: view
                                property real maxRatio: 16 / 9
                                property real sourceRatio: sourceSize.width / sourceSize.height
                                property real ratioFactor: sourceRatio / maxRatio // if ratio > 1, then shrink height
                                property real maxWidth: 1920 / 4
                                property real maxHeight: 1080 / 4
                                live: true
                                captureSource: windowIconDelegate.toplevel.wayland
                                Layout.preferredWidth: {
                                    if (!view.hasContent) {
                                        return maxWidth;
                                    }
                                    return ratioFactor > 1 ? maxWidth : maxWidth * ratioFactor;
                                }
                                Layout.preferredHeight: {
                                    if (!view.hasContent) {
                                        return maxHeight;
                                    }
                                    return ratioFactor > 1 ? maxHeight / ratioFactor : maxHeight;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
