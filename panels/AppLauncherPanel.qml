import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../services"
import "../components"

PanelWindow {
    id: appLauncher
    visible: false

    anchors {
        top: true
        right: true
        bottom: true
        left: true
    }

    color: "transparent"
        property list<DesktopEntry> filteredApps: DesktopEntries.applications.values
            .filter(data => !data.noDisplay)
            .filter(data => data.name.toLowerCase().includes(searchInput.text.toLowerCase()))
            .sort((lhs, rhs) => lhs.name.toLowerCase().localeCompare(rhs.name.toLowerCase()))

    function open(resume): void {
        resume = resume || false;
        if (!resume) {
            searchInput.text = "";
        }
        visible = true;
        focusGrab.active = true;
    }

    function close(): void {
        focusGrab.active = false;
        visible = false;
    }

    function toggle(): void {
        if (visible)
            close();
        else
            open();
    }

    component AppEntry: Item {
        id: appEntry
        required property DesktopEntry entry
        required property bool hovered
        property real iconScale: hovered ? 1 : Config.styling.statusIconScaler
        property int entrywidth: grid.cellWidth

        ColumnLayout {
            id: c
            anchors.centerIn: parent
            width: parent.width
            Layout.preferredWidth: appEntry.entrywidth
            Layout.maximumWidth: appEntry.entrywidth

            Item {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                width: 48
                height: 48

                IconImage {
                    anchors.centerIn: parent
                    width: 48
                    height: 48
                    source: entry ? Quickshell.iconPath(entry.icon, true) : ""
                    scale: iconScale
                    smooth: true

                    Behavior on scale {
                        enabled: Config.styling.animation.enabled
                        NumberAnimation {
                            duration: Config.styling.animation.calc(0.1)
                            easing.type: Easing.Bezier
                            easing.bezierCurve: [0.4, 0.0, 0.2, 1.0]
                        }
                    }
                }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: appEntry.entrywidth
                Layout.maximumWidth: appEntry.entrywidth
                text: entry ? entry.name : ""
                color: Config.styling.text0
                font.pixelSize: 13
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: appEntry.entrywidth
                Layout.maximumWidth: appEntry.entrywidth
                text: entry ? (entry.genericName !== "" ? entry.genericName : entry.comment) : ""
                color: Config.styling.text1
                font.pixelSize: 11
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }
            Item {
                implicitHeight: 8
            }
        }
    }

    HyprlandFocusGrab {
        id: focusGrab
        windows: [appLauncher]
        active: false
        onCleared: {
            appLauncher.close();
        }
    }

    Item {
        id: content
        property int columns: (() => {
            const screenWidth = parent.width * 0.75;
            const cw = 160;
            const maxCols = Math.floor(screenWidth / cw);
            const cols = maxCols - (maxCols % 2);
            return Math.max(2, cols);
        })()
        implicitWidth: columns * 160
        implicitHeight: (() => {
            const screenHeight = parent.height * 0.75;
            const ch = 128;
            const searchHeight = 40;
            const spacing = 32;
            const margins = 112;
            const availableHeight = screenHeight - searchHeight - spacing - margins;
            const maxRows = Math.max(1, Math.ceil(availableHeight / ch));
            return maxRows * ch + searchHeight + spacing + margins;
        })()
        anchors.centerIn: parent

        Rectangle {
            anchors.fill: parent
            color: Config.styling.bg0
        }

        ColumnLayout {
            id: layoutRoot
            anchors {
                fill: parent
                leftMargin: 64
                rightMargin: 64
                topMargin: 48
                bottomMargin: 64
            }

            spacing: 32
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop

            Rectangle {
                id: searchBarBg
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: Math.min(parent.width * 0.4, 480)
                implicitWidth: Math.min(parent.width * 0.4, 480)
                Layout.preferredHeight: 40
                implicitHeight: 40

                radius: 20
                color: Config.styling.bg2
                border.color: Config.styling.bg4
                border.width: 1

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 1
                    radius: parent.radius - 1
                    color: "transparent"
                }

                TextInput {
                    id: searchInput
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    color: Config.styling.text0
                    selectionColor: Config.colors.sapphire
                    selectedTextColor: Config.styling.bg2
                    font.pixelSize: 14
                    verticalAlignment: TextInput.AlignVCenter
                    focus: true



                    Keys.onEscapePressed: close()

                    Keys.onUpPressed: grid.moveCurrentIndexUp()
                    Keys.onDownPressed: grid.moveCurrentIndexDown()
                    Keys.onLeftPressed: grid.moveCurrentIndexLeft()
                    Keys.onRightPressed: grid.moveCurrentIndexRight()

                    onAccepted: {
                        filteredApps[grid.currentIndex].execute();
                        close();
                    }
                }
            }

            Item {
                id: gridWrapper
                Layout.fillWidth: true
                Layout.fillHeight: true

                readonly property int columns: content.columns
                readonly property int cw: 160
                readonly property int ch: 110

                readonly property int preferredGridWidth: columns * cw

                GridView {
                    id: grid

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom

                    width: gridWrapper.preferredGridWidth
                    height: parent.height

                    cellWidth: gridWrapper.cw
                    cellHeight: gridWrapper.ch
                    snapMode: GridView.SnapToRow
                    clip: true

                    model: filteredApps

                    delegate: Item {
                        id: cell
                        width: grid.cellWidth
                        height: grid.cellHeight
                        required property int index
                        required property var modelData
                        property bool selected: index === grid.currentIndex
                        property bool hovered: hover.hovered

                        AppEntry {
                            id: entryItem
                            anchors.fill: parent
                            entry: cell.modelData
                            hovered: cell.hovered
                        }

                        HoverHandler {
                            id: hover
                            cursorShape: Qt.PointingHandCursor
                        }

                        TapHandler {
                            acceptedButtons: Qt.LeftButton
                            gesturePolicy: TapHandler.ReleaseWithinBounds
                            cursorShape: Qt.PointingHandCursor
                            onTapped: {
                                grid.currentIndex = cell.index;
                                cell.modelData.execute();
                                appLauncher.close();
                            }
                        }

                        Rectangle {
                            anchors.centerIn: entryItem
                            width: (cell.hovered || cell.selected) ? cell.width : 0
                            height: (cell.hovered || cell.selected) ? cell.height : 0
                            color: Config.styling.good
                            opacity: Config.styling.hoverBgOpacity
                            radius: Config.styling.rounded ? 20 : 0
                            Behavior on width { enabled: Config.styling.animation.enabled; NumberAnimation { duration: Config.styling.animation.calc(0.1); easing.type: Easing.Bezier; easing.bezierCurve: [0.4, 0.0, 0.2, 1.0] } }
                            Behavior on height { enabled: Config.styling.animation.enabled; NumberAnimation { duration: Config.styling.animation.calc(0.1); easing.type: Easing.Bezier; easing.bezierCurve: [0.4, 0.0, 0.2, 1.0] } }
                        }

                        Rectangle {
                            anchors.bottom: entryItem.bottom
                            anchors.horizontalCenter: entryItem.horizontalCenter
                            width: cell.width
                            height: 6
                            color: Config.styling.good
                            scale: cell.selected ? 1 : 0

                            Behavior on scale {
                                enabled: Config.styling.animation.enabled
                                NumberAnimation {
                                    duration: Config.styling.animation.calc(0.1)
                                    easing.type: Easing.Bezier
                                    easing.bezierCurve: [0.4, 0.0, 0.2, 1.0]
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}