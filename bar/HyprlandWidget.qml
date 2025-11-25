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

        Item {
            id: windowArea
            Layout.alignment: Qt.AlignVCenter
            implicitHeight: root.height
            implicitWidth: windowRow.implicitWidth
            height: implicitHeight
            width: implicitWidth

            readonly property var currentWorkspace: pill.workspace

            property int activeWindowIndex: {
                if (Hyprland.focusedWorkspace?.id !== currentWorkspace?.id)
                    return -1;
                const list = windowRepeater.model || [];
                for (let i = 0; i < list.length; ++i) {
                    if (list[i]?.activated)
                        return i;
                }
                return -1;
            }

            property Item activeWindowItem: null

            function updateActiveWindowItem() {
                if (activeWindowIndex >= 0) {
                    const item = windowRepeater.itemAt(activeWindowIndex);
                    activeWindowItem = item || null;
                } else {
                    activeWindowItem = null;
                }
            }

            onActiveWindowIndexChanged: updateActiveWindowItem()
            onCurrentWorkspaceChanged: updateActiveWindowItem()
            Component.onCompleted: updateActiveWindowItem()

            RowLayout {
                id: windowRow
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                spacing: Math.max(4, Math.round(root.height * 0.1))

                Repeater {
                    id: windowRepeater
                    model: (windowArea.currentWorkspace?.toplevels?.values || []).filter(t => t.title !== "Wayland to X Recording bridge — Xwayland Video Bridge")

                    delegate: Toplevel {
                        required property var modelData
                        toplevel: modelData
                    }

                    onItemAdded: windowArea.updateActiveWindowItem()
                    onItemRemoved: windowArea.updateActiveWindowItem()
                }
            }

            Rectangle {
                id: workspaceActiveIndicator
                z: -1
                height: Math.max(2, Math.round(root.height * 0.0625))
                color: Config.styling.activeIndicator
                width: windowArea.activeWindowItem ? windowArea.activeWindowItem.width : 0
                x: windowArea.activeWindowItem ? windowArea.activeWindowItem.x : 0
                y: windowRow.bottom - height
                opacity: windowArea.activeWindowItem ? 1 : 0

                Behavior on x {
                    enabled: Config.styling.animation.enabled
                    NumberAnimation {
                        duration: Config.styling.animation.calc(0.1)
                        easing.type: Easing.Bezier
                        easing.bezierCurve: [0.4, 0.0, 0.2, 1.0]
                    }
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
                required property var modelData
                workspace: modelData
                contentAnimationBaseDuration: 0.15
            }
        }
        Component.onCompleted: {
            Hyprland.refreshWorkspaces();
            Hyprland.refreshToplevels();
        }
    }
}
