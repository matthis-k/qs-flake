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
                    TapHandler {
                        parent: parent
                        acceptedButtons: Qt.LeftButton
                        onTapped: function (mouse) {
                            if (mouse.button === Qt.LeftButton && Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id !== pill.workspace.id) {
                                pill.workspace.activate();
                            }
                        }
                    }
                }
            }

            Repeater {
                Component.onCompleted: Hyprland.refreshToplevels()
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

                        tooltipContent: Item {
                            id: ttRoot
                            property int margin: 4
                            property int spacing: 6

                            implicitWidth: view.width
                            implicitHeight: titleRow.height + spacing + view.height

                            TapHandler {
                                parent: ttRoot
                                acceptedButtons: Qt.LeftButton
                                onTapped: {
                                    if (Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id !== pill.workspace.id) {
                                        pill.workspace.activate();
                                    }
                                }
                            }

                            ScreencopyView {
                                id: view
                                anchors {
                                    top: titleRow.bottom
                                    topMargin: ttRoot.spacing
                                    horizontalCenter: parent.horizontalCenter
                                }
                                live: true
                                captureSource: windowIconDelegate.toplevel.wayland

                                readonly property real maxWidth: 1920 / 4
                                readonly property real maxHeight: 1080 / 4
                                constraintSize: Qt.size(maxWidth, maxHeight)

                                implicitWidth: hasContent ? implicitWidth : maxWidth
                                implicitHeight: hasContent ? implicitHeight : maxHeight
                            }

                            Item {
                                id: titleRow
                                anchors {
                                    top: parent.top
                                    topMargin: ttRoot.margin
                                    horizontalCenter: view.horizontalCenter
                                }
                                width: view.width
                                height: Math.max(24, title.implicitHeight)

                                Text {
                                    id: title
                                    anchors {
                                        left: parent.left
                                        right: closeButton.left
                                        verticalCenter: parent.verticalCenter
                                        rightMargin: 6
                                    }
                                    text: windowIconDelegate.toplevel.title
                                    color: Theme.text
                                    elide: Text.ElideRight
                                    wrapMode: Text.NoWrap
                                    horizontalAlignment: Text.AlignLeft
                                    verticalAlignment: Text.AlignVCenter
                                }

                                Item {
                                    id: closeButton
                                    width: 24
                                    height: 24
                                    anchors {
                                        right: parent.right
                                        verticalCenter: parent.verticalCenter
                                    }

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
                                        gesturePolicy: TapHandler.WithinBounds
                                        grabPermissions: PointerHandler.TakeOverForbidden
                                        onTapped: windowIconDelegate.toplevel?.wayland?.close()
                                    }
                                }
                            }

                            anchors.leftMargin: margin
                            anchors.rightMargin: margin
                            anchors.topMargin: margin
                            anchors.bottomMargin: margin
                        }
                    }
                }
            }
        }
    }
}
