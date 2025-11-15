import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import "../theme"
import "../managers/"
import "."

PanelWindow {
    id: quickSettings
    implicitWidth: (stackLayout.itemAt(stackLayout.currentIndex)?.implicitWidth ?? 0) + 3 * cornerRadius
    implicitHeight: (stackLayout.itemAt(stackLayout.currentIndex)?.implicitHeight ?? 0) + 3 * cornerRadius
    color: "transparent"
    visible: false

    anchors {
        top: true
        right: true
    }

    property string currentView: "network"
    property int cornerRadius: Theme.rounded * 16
    property color borderColor: Theme.green

    HoverHandler {
        id: hoverHandler
        onHoveredChanged: {
            if (hovered) {
                closeTimer.stop();
            } else {
                closeTimer.start();
            }
        }
    }

    Timer {
        id: closeTimer
        interval: 500
        onTriggered: QuickSettingsManager.close()
    }

    Rectangle {
        id: bgMain
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: stackLayout.left
        anchors.bottom: stackLayout.bottom
        color: Theme.crust
    }

    Rectangle {
        id: bgLeft
        anchors.right: stackLayout.left
        anchors.top: parent.top
        anchors.bottom: stackLayout.bottom
        width: cornerRadius
        color: Theme.crust
    }

    Rectangle {
        id: bgBottom
        anchors.top: stackLayout.bottom
        anchors.left: stackLayout.left
        anchors.right: parent.right
        height: cornerRadius
        color: Theme.crust
    }

    Rectangle {
        id: bgBottomLeftCorner
        anchors.verticalCenter: stackLayout.bottom
        anchors.horizontalCenter: stackLayout.left
        height: 2 * cornerRadius
        width: 2 * cornerRadius
        radius: cornerRadius
        color: Theme.crust
    }

    Item {
        id: bgTopLeftEntry
        width: cornerRadius
        height: cornerRadius
        anchors.left: quickSettings.left
        anchors.top: quickSettings.top

        Shape {
            anchors.fill: parent

            ShapePath {
                strokeWidth: 0
                fillColor: Theme.crust
                fillRule: ShapePath.OddEvenFill

                startX: 0
                startY: 0
                PathLine {
                    x: cornerRadius
                    y: 0
                }
                PathLine {
                    x: cornerRadius
                    y: cornerRadius
                }
                PathLine {
                    x: 0
                    y: cornerRadius
                }
                PathLine {
                    x: 0
                    y: 0
                }

                PathMove {
                    x: 0
                    y: 0
                }
                PathArc {
                    x: cornerRadius
                    y: cornerRadius
                    radiusX: cornerRadius
                    radiusY: cornerRadius
                    useLargeArc: false
                    direction: PathArc.Clockwise
                }
                PathLine {
                    x: 0
                    y: cornerRadius
                }
                PathLine {
                    x: 0
                    y: 0
                }
            }

            ShapePath {
                strokeWidth: 2
                strokeColor: borderColor
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap

                startX: 0
                startY: 0

                PathArc {
                    x: cornerRadius
                    y: cornerRadius
                    radiusX: cornerRadius
                    radiusY: cornerRadius
                    useLargeArc: false
                    direction: PathArc.Clockwise
                }
            }
        }
    }

    Rectangle {
        id: leftBorder
        width: 1
        color: borderColor
        anchors.left: bgLeft.left
        anchors.top: bgTopLeftEntry.bottom
        anchors.bottom: bgLeft.bottom
        anchors.topMargin: radius
    }

    Item {
        id: bottomLeftBorder
        width: cornerRadius
        height: cornerRadius
        anchors.left: bgLeft.left
        anchors.top: bgBottom.top

        Shape {
            anchors.fill: parent

            ShapePath {
                strokeWidth: 2
                strokeColor: borderColor
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap

                startX: 1
                startY: 1

                PathArc {
                    x: cornerRadius - 1
                    y: cornerRadius - 1
                    radiusX: cornerRadius
                    radiusY: cornerRadius
                    useLargeArc: false
                    direction: PathArc.Counterclockwise
                }
            }
        }
    }

    Rectangle {
        id: bottomBorder
        height: 1
        color: borderColor
        anchors.left: bottomLeftBorder.right
        anchors.right: bottomRightExit.left
        anchors.bottom: bgBottom.bottom
    }

    Item {
        id: bottomRightExit
        width: cornerRadius
        height: cornerRadius
        anchors.right: bgBottom.right
        anchors.top: bgBottom.bottom

        Shape {
            anchors.fill: parent

            ShapePath {
                strokeWidth: 0
                fillColor: Theme.crust
                fillRule: ShapePath.OddEvenFill

                startX: 0
                startY: 0
                PathLine {
                    x: cornerRadius
                    y: 0
                }
                PathLine {
                    x: cornerRadius
                    y: cornerRadius
                }
                PathLine {
                    x: 0
                    y: cornerRadius
                }
                PathLine {
                    x: 0
                    y: 0
                }

                PathMove {
                    x: 0
                    y: 0
                }
                PathArc {
                    x: cornerRadius
                    y: cornerRadius
                    radiusX: cornerRadius
                    radiusY: cornerRadius
                    useLargeArc: false
                    direction: PathArc.Clockwise
                }
                PathLine {
                    x: 0
                    y: cornerRadius
                }
                PathLine {
                    x: 0
                    y: 0
                }
            }

            ShapePath {
                strokeWidth: 2
                strokeColor: borderColor
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap

                startX: 0
                startY: 0

                PathArc {
                    x: cornerRadius
                    y: cornerRadius
                    radiusX: cornerRadius
                    radiusY: cornerRadius
                    useLargeArc: false
                    direction: PathArc.Clockwise
                }

                PathLine {
                    x: cornerRadius
                    y: cornerRadius
                }
            }
        }
    }

    StackLayout {
        id: stackLayout
        currentIndex: views.findIndex(item => item == currentView)
        anchors.fill: parent
        anchors.leftMargin: 2 * cornerRadius
        anchors.rightMargin: cornerRadius
        anchors.topMargin: cornerRadius
        anchors.bottomMargin: 2 * cornerRadius

        property var views: ["network", "bluetooth", "battery", "audio", "powermenu",]

        NetworkView {}
        BluetoothView {}
        BatteryView {}
        AudioView {}
        PowerMenuView {}
    }
}
