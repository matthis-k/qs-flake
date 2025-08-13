import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../theme"

Item {
    id: root
    anchors.fill: parent
    property Component tooltipContent
    property int openDelay: 300
    property int closeDelay: 200
    property bool canEnterTooltip: false
    property real margin: 8
    property bool visibleCond: true
    property color background: Theme.crust
    property var borderColor: Theme.blue

    function open(timeout = 0) {
        loader.active = true;
        actionTimer.schedule(() => loader.item.visible = true, timeout);
    }

    function close(timeout = 0) {
        actionTimer.schedule(() => loader.active = false, timeout);
    }

    Timer {
        id: actionTimer
        repeat: false
        property var _callback: null
        function schedule(callback, timeout) {
            actionTimer.stop();
            actionTimer._callback = callback;
            actionTimer.interval = timeout;
            actionTimer.restart();
        }
        onTriggered: {
            if (typeof _callback == "function")
                _callback();
            _callback = null;
        }
    }

    MouseArea {
        id: triggerArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton

        onEntered: root.open(root.openDelay)
        onExited: root.close(root.closeDelay)
    }

    LazyLoader {
        id: loader
        component: Component {
            PopupWindow {
                id: tooltipWindow
                visible: false
                anchor.item: root.parent
                anchor.rect.y: root.parent.height + root.margin
                anchor.rect.x: -(implicitWidth / 2) + (root.parent.width / 2)

                implicitWidth: content.implicitWidth
                implicitHeight: content.implicitHeight
                color: "transparent"

                HyprlandFocusGrab {
                    id: grab
                    windows: [tooltipWindow]
                }

                Rectangle {
                    id: content
                    anchors.fill: parent
                    color: root.background
                    radius: Theme.roudned * 2 * root.margin
                    border.color: root.borderColor
                    border.width: root.borderColor && 2 || 0

                    implicitWidth: Math.max(contentLoader.item.implicitWidth, contentLoader.item.width) + 2 * root.margin
                    implicitHeight: Math.max(contentLoader.item.implicitHeight, contentLoader.item.height) + 2 * root.margin

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: root.margin
                        color: "transparent"
                        HoverHandler {
                            id: popupArea
                            target: parent
                            onHoveredChanged: {
                                if (popupArea.hovered) {
                                    grab.active = true;
                                    root.open(root.openDelay);
                                } else {
                                    grab.active = false;
                                    root.close(root.closeDelay);
                                }
                            }
                        }

                        Loader {
                            id: contentLoader
                            anchors.fill: parent
                            sourceComponent: root.tooltipContent
                        }
                    }
                }
            }
        }
    }
}
