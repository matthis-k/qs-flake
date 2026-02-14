import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import qs.services
import qs.components
import qs.modules.quickmenu

Icon {
    id: root
    property var quickmenuName
    color: Config.styling.text0

    HoverHandler {
        onHoveredChanged: {
            if (!quickmenuName) {
                return;
            }
            let qm = ShellState.getScreenByName(screen.name).quickmenu;
            if (hovered) {
                qm.view = quickmenuName;
            }
            qm.externalHovers += hovered ? 1 : -1;
        }
    }
}
