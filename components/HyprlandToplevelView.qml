import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import "../services"

Item {
    id: root

    property var toplevel
    property string title
    property QtObject anchorController

    property real screenFraction: 0.3

    readonly property real screenWidth: Qt.application.screens[0].width
    readonly property real screenHeight: Qt.application.screens[0].height
    readonly property real maxViewWidth: screenWidth * screenFraction
    readonly property real maxViewHeight: screenHeight * screenFraction

    implicitWidth: (screencopyView.implicitWidth || maxViewWidth)
    implicitHeight: (screencopyView.implicitHeight || maxViewHeight) + header.height

    Item {
        id: header
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: screencopyView.width
        height: 32

        IconImage {
            id: appIcon
            property DesktopEntry entry: {
                DesktopEntries.applications?.values;
                return DesktopEntries.heuristicLookup(root.toplevel?.wayland?.appId);
            }
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: height
            source: Quickshell.iconPath(entry?.icon || "dialog-warning", "dialog-warning")
            mipmap: false
            scale: Config.styling.statusIconScaler
        }

        Text {
            text: root.title
            color: Config.styling.text0
            font.pixelSize: 14
            font.bold: true
            elide: Text.ElideRight
            maximumLineCount: 1
            anchors.left: appIcon.right
            anchors.leftMargin: 4
            anchors.right: closeBtn.left
            anchors.verticalCenter: parent.verticalCenter
        }

        Item {
            id: closeBtn
            width: 32
            height: 32
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            HoverHandler {
                id: hoverHandler
            }

            IconImage {
                id: icon
                anchors.centerIn: parent
                anchors.fill: parent

                source: Quickshell.iconPath("window-close", "window-close")
                scale: hoverHandler.hovered ? 1 : Config.styling.statusIconScaler

                Behavior on scale {
                    enabled: Config.styling.animation.enabled
                    NumberAnimation {
                        duration: Config.styling.animation.calc(0.1)
                        easing.type: Easing.Bezier
                        easing.bezierCurve: [0.4, 0.0, 0.2, 1.0]
                    }
                }
            }

            ColorOverlay {
                anchors.fill: icon
                color: Config.styling.close || Config.color.red
                source: icon
                scale: icon.scale
            }

            TapHandler {
                onSingleTapped: {
                    let f = root.toplevel?.wayland?.close;
                    f && f();
                    if (root.anchorController) {
                        root.anchorController.hide();
                    }
                }
            }
        }
    }

    ScreencopyView {
        id: screencopyView
        captureSource: root.toplevel?.wayland
        constraintSize: Qt.size(root.maxViewWidth, root.maxViewHeight)
        width: implicitWidth || root.maxViewWidth
        height: implicitHeight || root.maxViewHeight
        anchors.top: header.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        TapHandler {
            onSingleTapped: {
                let f = root.toplevel?.wayland?.activate;
                f && f();
            }
        }
    }
}
