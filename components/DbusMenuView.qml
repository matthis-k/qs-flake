import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import "../services"

Item {
    id: root
    property QsMenuHandle menu: null
    property QtObject anchorController: null
    property int padding: 12
    property color hoverColor: Config.styling.bg3
    property color textColor: Config.styling.text0
    signal requestClose

    implicitWidth: contentItem.implicitWidth
    implicitHeight: contentItem.implicitHeight

    function closeMenu() {
        requestClose();
    }

    Item {
        id: contentItem
        implicitWidth: menuStack.implicitWidth
        implicitHeight: menuStack.implicitHeight

        StackView {
            id: menuStack
            anchors.fill: parent
            implicitWidth: currentItem ? currentItem.implicitWidth : 0
            implicitHeight: currentItem ? currentItem.implicitHeight : 0
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

            function rebuildMenu() {
                if (!root.menu)
                    return;
                clear();
                push(menuPageComponent, {
                    handle: root.menu,
                    showBack: false
                });
            }
        }
    }

    Component.onCompleted: menuStack.rebuildMenu()
    Connections {
        target: root
        function onMenuChanged() {
            menuStack.rebuildMenu();
        }
    }

    Component {
        id: menuPageComponent

        ColumnLayout {
            id: page
            required property QsMenuHandle handle
            property bool showBack: true
            spacing: 4
            implicitWidth: body.implicitWidth
            implicitHeight: header.implicitHeight + body.implicitHeight

            Item {
                id: header
                visible: page.showBack
                implicitHeight: visible ? 28 : 0
                Layout.fillWidth: true

                Rectangle {
                    anchors.fill: parent
                    color: backHover.hovered ? Config.styling.bg3 : "transparent"
                }

                HoverHandler {
                    id: backHover
                    target: header
                    cursorShape: Qt.PointingHandCursor
                }
                TapHandler {
                    acceptedButtons: Qt.LeftButton
                    gesturePolicy: TapHandler.ReleaseWithinBounds
                    onTapped: menuStack.pop()
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 4
                    spacing: 6

                    Item {
                        width: 16
                        height: 16
                        Layout.alignment: Qt.AlignVCenter
                        IconImage {
                            id: backIcon
                            anchors.fill: parent
                            source: Quickshell.iconPath("pan-start")
                        }
                        ColorOverlay {
                            anchors.fill: backIcon
                            color: Config.styling.primaryAccent
                            source: backIcon
                        }
                    }

                    Text {
                        text: qsTr("Back")
                        color: Config.styling.primaryAccent
                        font.pixelSize: 16
                        Layout.alignment: Qt.AlignVCenter
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignLeft
                    }
                }
            }

            ColumnLayout {
                id: body
                spacing: 0
                Layout.fillWidth: true
                implicitWidth: Math.max(menuColumn.implicitWidth, 0)

                QsMenuOpener {
                    id: pageOpener
                    menu: page.handle
                }

                ColumnLayout {
                    id: menuColumn
                    spacing: 0
                    Layout.fillWidth: true

                    Repeater {
                        id: menuRepeater
                        model: pageOpener.children
                        delegate: Item {
                            required property var modelData
                            property var entry: modelData || ({})
                            readonly property bool isSep: !!entry.isSeparator
                            readonly property bool hasKids: !!entry.hasChildren
                            readonly property bool isEnabled: entry.enabled === undefined ? true : !!entry.enabled
                            readonly property string iconSrc: (entry.icon && entry.icon.length) ? entry.icon : ""

                            Layout.fillWidth: true
                            implicitWidth: rowLayout.implicitWidth
                            implicitHeight: isSep ? 1 : Math.max(rowLayout.implicitHeight, 24)

                            Rectangle {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                height: 1
                                visible: isSep
                                color: Config.styling.bg5
                            }

                            Rectangle {
                                id: hoverBg
                                visible: (!isSep) && rowHover.hovered && isEnabled
                                anchors.fill: parent
                                color: root.hoverColor
                            }

                            RowLayout {
                                id: rowLayout
                                visible: !isSep
                                spacing: padding / 2
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                Layout.preferredHeight: 28
                                Layout.rightMargin: 0
                                Layout.leftMargin: 0

                                Item {
                                    width: 16
                                    height: 16
                                    visible: iconSrc !== ""
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.preferredWidth: 16
                                    Layout.minimumWidth: 16
                                    Layout.maximumWidth: 16
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
                                    color: isEnabled ? root.textColor : Config.styling.primaryAccent
                                    elide: Text.ElideRight
                                    font.pixelSize: 16
                                    Layout.fillWidth: true
                                }

                                Item {
                                    width: 16
                                    height: 16
                                    Layout.fillWidth: false
                                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                    Layout.rightMargin: 0
                                    Layout.leftMargin: 0
                                    Layout.preferredWidth: 16
                                    Layout.minimumWidth: 16
                                    Layout.maximumWidth: 16
                                    visible: hasKids
                                    IconImage {
                                        id: childIcon
                                        anchors.fill: parent
                                        source: Quickshell.iconPath("pan-end")
                                    }
                                    ColorOverlay {
                                        anchors.fill: childIcon
                                        color: Config.styling.text0
                                        source: childIcon
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
                                        root.closeMenu();
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
