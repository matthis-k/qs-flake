import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQml
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import "../services"
import "../managers"
import "../components"

Item {
    id: root

    readonly property bool expandMode: true
    readonly property var defaultWorkspaceIds: [1, 2, 3, 4, 5]
    property var workspacePlaceholders: ({})

    Component {
        id: workspacePlaceholderComponent
        QtObject {
            property int id: -1
            function activate() {
                if (id > 0)
                    Hyprland.dispatch(`workspace ${id}`);
            }
        }
    }

    ListModel {
        id: workspaceModel
    }

    function workspaceForId(id) {
        const hyprWorkspace = Hyprland.workspaces?.values.find(w => w.id === id);
        if (hyprWorkspace) {
            if (workspacePlaceholders[id]) {
                workspacePlaceholders[id].destroy();
                delete workspacePlaceholders[id];
            }
            return hyprWorkspace;
        }
        if (!workspacePlaceholders[id]) {
            workspacePlaceholders[id] = workspacePlaceholderComponent.createObject(root, {
                id: id
            });
        }
        return workspacePlaceholders[id];
    }

    function desiredWorkspaceIds() {
        const ids = defaultWorkspaceIds.slice();
        const hyprlandWorkspaces = Hyprland.workspaces?.values || [];
        hyprlandWorkspaces.forEach(ws => {
            if (!ids.includes(ws.id))
                ids.push(ws.id);
        });
        const focusedId = Hyprland.focusedWorkspace?.id;
        if (focusedId && !ids.includes(focusedId))
            ids.push(focusedId);
        return ids;
    }

    function applyWorkspaceBinding(index) {
        const item = workspaceRepeater.itemAt(index);
        if (!item)
            return;
        const entry = workspaceModel.get(index);
        if (!entry)
            return;
        item.workspace = workspaceForId(entry.workspaceId);
    }

    function syncWorkspaceModel() {
        const ids = desiredWorkspaceIds();
        for (let i = 0; i < ids.length; ++i) {
            const id = ids[i];
            if (i >= workspaceModel.count) {
                workspaceModel.append({
                    workspaceId: id
                });
                continue;
            }
            if (workspaceModel.get(i).workspaceId !== id) {
                workspaceModel.setProperty(i, "workspaceId", id);
            }
        }
        while (workspaceModel.count > ids.length) {
            workspaceModel.remove(workspaceModel.count - 1);
        }
        for (let i = 0; i < workspaceModel.count; ++i) {
            applyWorkspaceBinding(i);
        }
    }

    Component.onCompleted: syncWorkspaceModel()

    Connections {
        target: Hyprland
        function onFocusedWorkspaceChanged() {
            root.syncWorkspaceModel();
        }
    }

    Connections {
        target: Hyprland.workspaces
        function onObjectInsertedPost() {
            root.syncWorkspaceModel();
        }
        function onObjectRemovedPost() {
            root.syncWorkspaceModel();
        }
    }

    component Toplevel: Item {
        id: tl
        required property HyprlandToplevel toplevel

        property bool inFocusedWorkspace: Hyprland.focusedWorkspace && toplevel.workspace && Hyprland.focusedWorkspace.id === toplevel.workspace.id
        readonly property bool isActiveOnFocusedWorkspace: inFocusedWorkspace && toplevel?.activated
        readonly property bool isUrgent: !!toplevel?.urgent

        implicitHeight: root.height
        implicitWidth: root.height
        width: implicitWidth
        height: implicitHeight
        Layout.fillHeight: true

        property Component popupComponent: Component {
            HyprlandToplevelView {
                toplevel: tl.toplevel
                title: tl.toplevel.title
            }
        }

        HoverHandler {
            id: toplevelHover
            onHoveredChanged: {
                if (hovered) {
                    PopupManager.anchors.topLeft.show(tl.popupComponent, {
                        peeking: true
                    });
                } else {
                    PopupManager.anchors.topLeft.hide(500);
                }
            }
        }

        Rectangle {
            id: activeHighlight
            anchors.fill: parent
            readonly property bool showActive: tl.isActiveOnFocusedWorkspace
            readonly property bool showUrgent: !showActive && tl.isUrgent
            readonly property bool shouldShow: showActive || showUrgent
            color: showActive ? Config.styling.activeIndicator : Config.styling.urgent
            opacity: shouldShow ? Config.styling.hoverBgOpacity : 0
            scale: shouldShow ? 1 : 0.85
            transformOrigin: Item.Center
            z: -1

            Behavior on opacity {
                enabled: Config.styling.animation.enabled
                NumberAnimation {
                    duration: Config.styling.animation.calc(0.12)
                    easing.type: Easing.Bezier
                    easing.bezierCurve: [0.4, 0.0, 0.2, 1.0]
                }
            }

            Behavior on scale {
                enabled: Config.styling.animation.enabled
                NumberAnimation {
                    duration: Config.styling.animation.calc(0.12)
                    easing.type: Easing.Bezier
                    easing.bezierCurve: [0.4, 0.0, 0.2, 1.0]
                }
            }
        }

        IconImage {
            property DesktopEntry entry: {
                // binding for refreshing
                DesktopEntries.applications?.values;
                return DesktopEntries.heuristicLookup(toplevel.wayland?.appId);
            }

            anchors.centerIn: parent
            implicitSize: Math.round(root.height * 0.35) * 2
            source: Quickshell.iconPath(entry?.icon || "dialog-warning", "dialog-warning")
            scale: toplevelHover.hovered ? 1.2 : 1

            Behavior on scale {
                enabled: Config.styling.animation.enabled
                NumberAnimation {
                    duration: Config.styling.animation.calc(0.1)
                    easing.type: Easing.Bezier
                    easing.bezierCurve: [0.4, 0.0, 0.2, 1.0]
                }
            }
        }

        Rectangle {
            id: activeIndicator
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            height: Math.max(2, Math.round(root.height * 0.0625))
            color: Config.styling.activeIndicator
            width: parent.width
            scale: root.expandMode && tl.isActiveOnFocusedWorkspace ? 1 : 0
            opacity: root.expandMode ? 1 : 0

            Behavior on scale {
                enabled: Config.styling.animation.enabled && root.expandMode
                NumberAnimation {
                    duration: Config.styling.animation.calc(0.1)
                    easing.type: Easing.Bezier
                    easing.bezierCurve: [0.4, 0.0, 0.2, 1.0]
                }
            }
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

        HoverHandler {
            id: hoverHandler
        }

        Text {
            anchors.centerIn: parent
            text: workspace.id
            color: (Hyprland.focusedWorkspace?.id === workspace?.id) ? Config.styling.activeIndicator : Config.styling.text0
            font.bold: true
            font.pixelSize: Math.round(root.height * (Hyprland.focusedWorkspace?.id === workspace?.id ? 0.75 : 0.5) * (hoverHandler.hovered ? (Hyprland.focusedWorkspace?.id === workspace?.id ? 1.2 : 1.5) : 1))

            Behavior on font.pixelSize {
                enabled: Config.styling.animation.enabled
                NumberAnimation {
                    duration: Config.styling.animation.calc(0.1)
                    easing.type: Easing.Bezier
                    easing.bezierCurve: [0.4, 0.0, 0.2, 1.0]
                }
            }
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
        property var workspace

        header: WorkspaceButton {
            workspace: pill.workspace
        }

        Item {
            id: windowArea
            Layout.fillHeight: true
            implicitHeight: root.height
            implicitWidth: windowRow.implicitWidth
            height: implicitHeight
            width: implicitWidth

            readonly property var currentWorkspace: pill.workspace

            RowLayout {
                id: windowRow
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                spacing: Math.max(4, Math.round(root.height * 0.1))

                Repeater {
                    id: windowRepeater
                    model: (windowArea.currentWorkspace?.toplevels?.values || []).filter(t => t.title !== "Wayland to X Recording bridge — Xwayland Video Bridge")

                    delegate: Toplevel {
                        required property var modelData
                        toplevel: modelData
                    }
                }
            }
        }
    }

    RowLayout {
        id: row
        Repeater {
            id: workspaceRepeater
            model: workspaceModel

            delegate: WorkspaceToplevelOverview {
                required property int workspaceId
                contentAnimationBaseDuration: 0.15

                Component.onCompleted: workspace = root.workspaceForId(workspaceId)
                onWorkspaceIdChanged: workspace = root.workspaceForId(workspaceId)
            }

            onItemAdded: function (index, item) {
                root.applyWorkspaceBinding(index);
            }
        }
        Component.onCompleted: {
            Hyprland.refreshWorkspaces();
            Hyprland.refreshToplevels();
        }
    }
}
