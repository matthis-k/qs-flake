import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../theme"

Item {
    id: root
    required property QsMenuHandle menu

    property color background: Theme.surface0
    property color borderColor: Theme.blue
    property int margin: Theme.rounded * radius
    property int radius: 8

    QsMenuOpener {
        id: opener
        menu: root.menu
    }

    function open() {
        loader.active = true;
    }
    function close() {
        loader.active = false;
    }

    LazyLoader {
        id: loader
        component: PopupWindow {
            id: menuWindow
            visible: true
            color: "transparent"

            anchor.item: root.parent
            anchor.rect.y: root.parent.height + root.margin
            anchor.rect.x: (root.parent.width / 2)

            implicitWidth: frame.implicitWidth
            implicitHeight: frame.implicitHeight

            HyprlandFocusGrab {
                windows: [menuWindow]
                onCleared: loader.active = false
            }

            Rectangle {
                id: frame
                anchors.fill: parent
                color: root.background
                radius: root.radius
                border.color: root.borderColor
                border.width: root.borderColor ? 2 : 0

                implicitWidth: content.implicitWidth + 2 * root.margin
                implicitHeight: content.implicitHeight + 2 * root.margin

                HoverHandler {
                    id: popupArea
                    target: frame
                    onHoveredChanged: (!hovered) ? closeDelay.start() : closeDelay.stop()
                }
                Timer {
                    id: closeDelay
                    interval: 1000
                    onTriggered: loader.active = false
                }

                Item {
                    id: content
                    anchors.fill: parent
                    anchors.margins: root.margin
                    implicitWidth: menuStack.implicitWidth
                    implicitHeight: menuStack.implicitHeight

                    StackView {
                        id: menuStack
                        initialItem: menuPageComponent.createObject(menuStack, {
                            handle: root.menu,
                            showBack: false
                        })
                        implicitWidth: currentItem.implicitWidth
                        implicitHeight: currentItem.implicitHeight
                        pushEnter: Transition {
                            NumberAnimation {
                                duration: 0
                            }
                        }
                        pushExit: Transition {
                            NumberAnimation {
                                duration: 0
                            }
                        }
                        popEnter: Transition {
                            NumberAnimation {
                                duration: 0
                            }
                        }
                        popExit: Transition {
                            NumberAnimation {
                                duration: 0
                            }
                        }
                    }

                    Component {
                        id: menuPageComponent

                        ColumnLayout {
                            id: page
                            required property QsMenuHandle handle
                            property bool showBack: true
                            spacing: 4
                            width: menuStack.width

                            implicitWidth: body.implicitWidth
                            implicitHeight: header.implicitHeight + body.implicitHeight

                            Item {
                                id: header
                                visible: page.showBack
                                implicitHeight: visible ? 24 : 0
                                Layout.fillWidth: true

                                Rectangle {
                                    id: headerArea
                                    anchors.fill: parent
                                    radius: root.radius
                                    color: "transparent"
                                }

                                Rectangle {
                                    anchors.fill: headerArea
                                    visible: backHover.hovered
                                    color: Theme.surface1
                                    radius: Math.max(0, root.radius - 2)
                                }
                                Rectangle {
                                    anchors.top: headerArea.bottom
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    height: 1
                                    color: root.borderColor
                                }

                                HoverHandler {
                                    id: backHover
                                    target: headerArea
                                    cursorShape: Qt.PointingHandCursor
                                }
                                TapHandler {
                                    acceptedButtons: Qt.LeftButton
                                    gesturePolicy: TapHandler.ReleaseWithinBounds
                                    onTapped: menuStack.pop()
                                }

                                RowLayout {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 6

                                    Item {
                                        width: 16
                                        height: 16
                                        Layout.alignment: Qt.AlignVCenter
                                        ColorOverlay {
                                            anchors.fill: parent
                                            color: Theme.blue
                                            source: IconImage {
                                                anchors.fill: parent
                                                implicitSize: 16
                                                source: Quickshell.iconPath("pan-start")
                                                mipmap: true
                                            }
                                        }
                                    }

                                    Text {
                                        text: qsTr("Back")
                                        color: Theme.blue
                                        font.pixelSize: 16
                                        Layout.alignment: Qt.AlignVCenter
                                    }
                                }
                            }

                            ColumnLayout {
                                id: body
                                spacing: 0
                                Layout.fillWidth: true

                                QsMenuOpener {
                                    id: pageOpener
                                    menu: page.handle
                                }

                                Repeater {
                                    id: menuRepeater
                                    model: pageOpener.children
                                    Layout.fillWidth: true

                                    delegate: Item {
                                        required property var modelData
                                        property var entry: modelData || ({})
                                        readonly property bool isSep: !!entry.isSeparator
                                        readonly property bool hasKids: !!entry.hasChildren
                                        readonly property bool isEnabled: entry.enabled === undefined ? true : !!entry.enabled
                                        readonly property string iconSrc: (entry.icon && entry.icon.length) ? entry.icon : ""

                                        Layout.fillWidth: true
                                        implicitWidth: rowLeft.implicitWidth
                                        implicitHeight: isSep ? sep.height : Math.max(rowLeft.implicitHeight, 24)

                                        Rectangle {
                                            id: sep
                                            visible: isSep
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            height: 1
                                            color: root.borderColor
                                        }

                                        Rectangle {
                                            id: hoverBg
                                            visible: (!isSep) && rowHover.hovered
                                            anchors.fill: parent
                                            color: Theme.surface1
                                            radius: Math.max(0, root.radius - 2)
                                        }

                                        RowLayout {
                                            id: rowLeft
                                            visible: !isSep
                                            spacing: root.margin
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            Layout.preferredHeight: 24
                                            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                                            Item {
                                                width: 16
                                                height: 16
                                                Layout.preferredWidth: 16
                                                Layout.alignment: Qt.AlignVCenter
                                                visible: iconSrc !== ""
                                                Loader {
                                                    anchors.centerIn: parent
                                                    active: iconSrc !== ""
                                                    sourceComponent: Image {
                                                        source: iconSrc
                                                        width: 16
                                                        height: 16
                                                        sourceSize.width: width
                                                        sourceSize.height: height
                                                        smooth: true
                                                    }
                                                }
                                            }

                                            Text {
                                                text: entry.text || ""
                                                color: isEnabled ? Theme.text : Theme.blue
                                                elide: Text.ElideRight
                                                font.pixelSize: 16
                                            }

                                            Item {
                                                Layout.fillWidth: true
                                            }

                                            Loader {
                                                active: hasKids
                                                visible: hasKids
                                                sourceComponent: Item {
                                                    width: 16
                                                    height: 16
                                                    Layout.fillWidth: true
                                                    ColorOverlay {
                                                        anchors.fill: parent
                                                        color: Theme.text
                                                        source: IconImage {
                                                            anchors.fill: parent
                                                            implicitSize: 16
                                                            source: Quickshell.iconPath("pan-end")
                                                            mipmap: true
                                                        }
                                                    }
                                                }
                                            }
                                        }

                                        HoverHandler {
                                            id: rowHover
                                            enabled: !isSep
                                            cursorShape: isEnabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                        }

                                        TapHandler {
                                            enabled: (!isSep) && isEnabled
                                            acceptedButtons: Qt.LeftButton
                                            gesturePolicy: TapHandler.ReleaseWithinBounds
                                            onTapped: {
                                                if (hasKids) {
                                                    menuStack.push(menuPageComponent, {
                                                        handle: entry,
                                                        showBack: true
                                                    });
                                                } else if (entry && entry.triggered) {
                                                    entry.triggered();
                                                    loader.active = false;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
