import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import "../services"
import "../components"

Item {
    id: root

    component Toplevel: Item {
        id: tl
        required property HyprlandToplevel toplevel

        property bool inFocusedWorkspace: Hyprland.focusedWorkspace && toplevel.workspace && Hyprland.focusedWorkspace.id === toplevel.workspace.id

        implicitHeight: root.height
        implicitWidth: root.height
        width: implicitWidth
        height: implicitHeight
        transformOrigin: Item.Center
        scale: 1

        IconImage {
            property DesktopEntry entry: {
                // binding for refreshing
                DesktopEntries.applications?.values;
                return DesktopEntries.heuristicLookup(toplevel.wayland?.appId);
            }

            anchors.centerIn: parent
            implicitSize: Math.round(root.height * 0.35) * 2
            source: Quickshell.iconPath(entry?.icon || "dialog-warning", "dialog-warning")
        }

        Rectangle {
            id: activeIndicator
            visible: inFocusedWorkspace && toplevel.activated
            height: Math.max(2, Math.round(root.height * 0.0625))
            color: Config.styling.activeIndicator

            anchors.top: tl.top
            anchors.left: tl.left
            anchors.right: tl.right
        }

        TapHandler {
            onTapped: {
                let f = toplevel?.wayland?.activate;
                f && f();
            }
        }

        TapHandler {
            acceptedButtons: Qt.MiddleButton
            onTapped: {
                let f = toplevel?.wayland?.close;
                f && f();
            }
        }

        // TODO: Hover / Preview etc.
    }

    component WorkspaceButton: Item {
        required property var workspace
        implicitHeight: root.height
        implicitWidth: root.height

        Text {
            anchors.centerIn: parent
            text: workspace.id
            color: (Hyprland.focusedWorkspace?.id === workspace?.id) ? Config.styling.activeIndicator : Config.styling.text0
            font.bold: true
            font.pixelSize: Math.round(root.height * (Hyprland.focusedWorkspace?.id === workspace?.id ? 0.75 : 0.5))
        }

        TapHandler {
            onTapped: {
                if (workspace && Hyprland.focusedWorkspace?.id !== workspace.id) {
                    workspace.activate?.();
                }
            }
        }
    }

    component WorkspaceToplevelOverview: Pill {
        id: pill
        required property var workspace

        header: WorkspaceButton {
            workspace: {
                return pill.workspace;
            }
        }

        ListView {
            id: windowList
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredHeight: root.height
            Layout.preferredWidth: Math.max(contentWidth, 0)
            implicitHeight: root.height
            implicitWidth: contentWidth
            height: root.height
            width: implicitWidth
            spacing: Math.max(4, Math.round(root.height * 0.1))
            orientation: ListView.Horizontal
            interactive: false
            boundsBehavior: Flickable.StopAtBounds
            model: (workspace?.toplevels?.values || []).filter(t => t.title !== "Wayland to X Recording bridge — Xwayland Video Bridge")

            delegate: Toplevel {
                toplevel: modelData
            }

            add: Transition {
                NumberAnimation {
                    properties: "opacity,scale"
                    from: 0.2
                    to: 1
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }

            remove: Transition {
                NumberAnimation {
                    properties: "opacity,scale"
                    from: 1
                    to: 0
                    duration: 160
                    easing.type: Easing.InCubic
                }
            }

            displaced: Transition {
                NumberAnimation {
                    properties: "x,y"
                    duration: 160
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    RowLayout {
        id: row
        Repeater {
            id: workspaceRepeater
            model: {
                const defaultIds = [1, 2, 3, 4, 5];
                const focusedId = Hyprland.focusedWorkspace?.id || 1;

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

            delegate: WorkspaceToplevelOverview {
                required property int index
                workspace: workspaceRepeater.model[index]
            }
        }
        Component.onCompleted: {
            Hyprland.refreshWorkspaces();
            Hyprland.refreshToplevels();
        }
    }
}
