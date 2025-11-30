import QtQuick
import Quickshell
import Quickshell.Io
import "./"

Scope {
    Variants {
        id: panelVariants
        model: Quickshell.screens

        delegate: Scope {
            id: perScreen
            required property var modelData
            property alias panel: panel

            PanelWindow {
                id: panel
                screen: perScreen.modelData
            }

            IpcHandler {
                target: "panel-" + perScreen.modelData.name

                function hideAll(timeout_ms: int) {
                    panel.hideAll(timeout_ms);
                }
            }
        }
    }

    IpcHandler {
        target: "panel"

        function hideAll(timeout_ms: int) {
            for (let item of panelVariants.instances) {
                item.panel.hideAll(timeout_ms);
            }
        }
    }

    readonly property QtObject anchorControllers: QtObject {
        readonly property QtObject topLeft: panelVariants.instances.length > 0 ? panelVariants.instances[0].panel.topLeft : null
        readonly property QtObject topCenter: panelVariants.instances.length > 0 ? panelVariants.instances[0].panel.topCenter : null
        readonly property QtObject topRight: panelVariants.instances.length > 0 ? panelVariants.instances[0].panel.topRight : null
        readonly property QtObject middleLeft: panelVariants.instances.length > 0 ? panelVariants.instances[0].panel.middleLeft : null
        readonly property QtObject middleCenter: panelVariants.instances.length > 0 ? panelVariants.instances[0].panel.middleCenter : null
        readonly property QtObject middleRight: panelVariants.instances.length > 0 ? panelVariants.instances[0].panel.middleRight : null
        readonly property QtObject bottomLeft: panelVariants.instances.length > 0 ? panelVariants.instances[0].panel.bottomLeft : null
        readonly property QtObject bottomCenter: panelVariants.instances.length > 0 ? panelVariants.instances[0].panel.bottomCenter : null
        readonly property QtObject bottomRight: panelVariants.instances.length > 0 ? panelVariants.instances[0].panel.bottomRight : null
    }

    function hideAll(timeout_ms: int) {
        for (let item of panelVariants.instances) {
            item.panel.hideAll(timeout_ms);
        }
    }

    function getPanelForScreen(screen) {
        if (!screen)
            return null;
        for (let i = 0; i < panelVariants.instances.length; i++) {
            let item = panelVariants.instances[i];
            if (item.panel.screen && item.panel.screen.name === screen.name)
                return item.panel;
        }
        return null;
    }

    function getAnchor(screen, anchorName) {
        const panel = getPanelForScreen(screen);
        if (!panel)
            return null;
        return panel[anchorName];
    }
}
