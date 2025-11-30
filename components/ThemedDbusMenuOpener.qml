import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../services"

Item {
    id: root
    required property QsMenuHandle menu
    property QtObject popupAnchor: {
        if (barScreen) {
            return popups.getAnchor(barScreen, "topRight");
        }
        return PopupManager.topRight; // fallback
    }
    property bool closeOnAction: true

    // Utility function to find the inheritance node
    function findInheritanceNode(obj) {
        if (obj && obj.inheritanceNode) {
            return obj.inheritanceNode;
        }
        if (obj && obj.parent) {
            return findInheritanceNode(obj.parent);
        }
        return null;
    }

    // Property to hold the found screen
    property var barScreen: {
        var node = findInheritanceNode(parent);
        return node ? node.lookup("screen") : null;
    }

    property color background: Config.styling.bg1
    property color borderColor: Config.styling.bg5
    property int margin: Config.styling.rounded * 12
    property int radius: 12

    readonly property Component contentComponent: Component {
        DbusMenuView {
            property QsMenuHandle menuHandle: null
            property QtObject anchorController: root.popupAnchor
            menu: menuHandle
            padding: root.margin
            onRequestClose: {
                if (anchorController)
                    anchorController.hide(0);
            }
        }
    }

    function open(toggle) {
        if (!popupAnchor || !menu)
            return;
        const options = {
            autoClose: true,
            properties: {
                menuHandle: menu,
                anchorController: popupAnchor
            }
        };
        if (toggle)
            popupAnchor.toggle(contentComponent, options);
        else
            popupAnchor.show(contentComponent, options);
    }

    function peek() {
        if (!popupAnchor || !menu)
            return;
        const options = {
            peeking: true,
            autoClose: true,
            properties: {
                menuHandle: menu,
                anchorController: popupAnchor
            }
        };
        popupAnchor.show(contentComponent, options);
    }

    function close(timeout) {
        if (popupAnchor)
            popupAnchor.hide(timeout ?? 0);
    }
}
