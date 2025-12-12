import QtQuick
import QtQuick.Layouts
import "../../utils"
import "../../services"
import "../../components"
import "../../modules/quickmenu"

Rectangle {
    id: barRoot
    anchors.fill: parent
    color: Config.styling.bg0

    Rectangle {
        id: contentArea
        anchors {
            top: barRoot.top
            left: barRoot.left
            right: barRoot.right
            bottom: sepline.top
            margins: 3
        }
        color: "transparent"
    }

    Rectangle {
        id: sepline
        color: Config.styling.primaryAccent
        anchors {
            right: barRoot.right
            left: barRoot.left
            bottom: barRoot.bottom
        }
        implicitHeight: 1
    }

    RowLayout {
        id: left
        anchors {
            top: contentArea.top
            bottom: contentArea.bottom
            left: contentArea.left
        }
        HyprlandWidget {}
    }

    RowLayout {
        id: center
        anchors {
            top: contentArea.top
            bottom: contentArea.bottom
            horizontalCenter: contentArea.horizontalCenter
        }
        Clock {
            format: "HH:mm"
        }
    }

    Rectangle {
        anchors.fill: right
        color: Config.styling.bg3
    }

    RowLayout {
        id: right
        anchors {
            top: contentArea.top
            bottom: contentArea.bottom
            right: contentArea.right
        }
        spacing: 0

        AudioIcon {
            HoverScaler {
                baseScale: 0.8
            }
        }
        BluetoothIcon {
            HoverScaler {
                baseScale: 0.8
            }
        }
        NetworkIcon {
            HoverScaler {
                baseScale: 0.8
            }
        }
        BatteryIcon {
            HoverScaler {
                baseScale: 0.8
            }
        }
        PowerIcon {
            HoverScaler {
                baseScale: 0.8
            }
        }
    }
}
