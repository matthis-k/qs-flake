import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import Qt5Compat.GraphicalEffects
import "../services"
import "../components"
import "../managers"
import "../quickSettings"

Item {
    id: root
    property UPowerDevice bat: UPower.displayDevice
    implicitWidth: height

    Component {
        id: batteryPopupComponent
        BatteryView {}
    }
    readonly property real iconMargin: Math.floor(root.height * (1 - Config.styling.statusIconScaler) / 2)

    property color stateColor: {
        let percentage = Math.floor(root.bat.percentage * 100);
        return [
            {
                max: 10,
                col: Config.styling.critical
            },
            {
                max: 20,
                col: Config.colors.yellow
            },
            {
                max: 60,
                col: Config.styling.text0
            },
            {
                max: 100,
                col: Config.styling.good
            }
        ].find(({
                max,
                col
            }) => percentage <= max).col;
    }

    StatusIcon {
        anchors.fill: parent
        iconName: root.bat.iconName
        overlayColor: root.stateColor
        popupComponent: batteryPopupComponent
    }
}
