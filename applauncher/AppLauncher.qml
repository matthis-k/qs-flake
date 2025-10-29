import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt.labs.qmlmodels
import QtQml.Models
import "../theme"
import "../components"

PanelWindow {
    id: appLauncherWin
    visible: false

    anchors {
        top: true
        right: true
        bottom: true
        left: true
    }

    color: "transparent"

    HyprlandFocusGrab {
        id: focusGrab
        windows: [appLauncherWin]
        active: false
        onCleared: {
            appLauncherWin.close();
        }
    }

    function open(resume: bool): void {
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
        if (appLauncherWin.visible)
            close();
        else
            open();
    }

    property string pointer: ""
    property list<DesktopEntry> filteredApps: {
        return DesktopEntries.applications.values.filter(data => !data.noDisplay).filter(data => data.name.toLowerCase().includes(searchInput.text.toLowerCase())).sort((lhs, rhs) => lhs.name.toLowerCase().localeCompare(rhs.name.toLowerCase()));
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.crust
        opacity: 0.9
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
            Layout.preferredHeight: 40

            radius: 20
            color: Theme.base
            border.color: Theme.surface1
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
                verticalAlignment: TextInput.AlignVCenter
                color: Theme.text
                selectionColor: Theme.sapphire
                selectedTextColor: Theme.base
                font.pixelSize: 14
                focus: true
                echoMode: TextInput.Normal

                onTextChanged: {
                    appLauncherWin.pointer = text;
                }

                Keys.onEscapePressed: appLauncherWin.close()

                Keys.onUpPressed: grid.moveCurrentIndexUp()
                Keys.onRightPressed: grid.moveCurrentIndexRight()
                Keys.onDownPressed: grid.moveCurrentIndexDown()
                Keys.onLeftPressed: grid.moveCurrentIndexLeft()

                onAccepted: {
                    filteredApps[grid.currentIndex].execute();
                    appLauncherWin.close();
                }
            }
        }

        Item {
            id: gridWrapper
            Layout.fillWidth: true
            Layout.fillHeight: true

            readonly property int columns: 8
            readonly property int cw: 160
            readonly property int ch: 128
            readonly property int hSpacing: 0

            readonly property int preferredGridWidth: (columns * cw) + ((columns - 1) * hSpacing)

            GridView {
                id: grid

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                width: gridWrapper.preferredGridWidth
                height: parent.height

                cellWidth: gridWrapper.cw
                cellHeight: gridWrapper.ch
                interactive: true
                boundsBehavior: Flickable.StopAtBounds
                snapMode: GridView.SnapToRow
                clip: true

                model: appLauncherWin.filteredApps

                delegate: Item {
                    id: entryItem
                    width: grid.cellWidth
                    height: grid.cellHeight

                    readonly property bool selected: index === grid.currentIndex
                    property bool hovered: hover.hovered

                    Rectangle {
                        id: hoverBg
                        anchors.margins: 4
                        anchors.fill: parent
                        radius: Theme.rounded ? 20 : 0
                        color: entryItem.selected || hovered ? Theme.surface0 : Theme.base
                        border.color: Theme.green
                        border.width: entryItem.selected * 2
                    }

                    ColumnLayout {
                        id: c
                        anchors.centerIn: parent
                        anchors.margins: 4
                        spacing: 8
                        width: parent.width
                        property int entrywidth: grid.cellWidth
                        Layout.preferredWidth: c.entrywidth
                        Layout.maximumWidth: c.entrywidth

                        IconImage {
                            Layout.alignment: Qt.AlignHCenter
                            source: Quickshell.iconPath(modelData.icon, true)
                            width: 48
                            height: 48
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: c.entrywidth
                            Layout.maximumWidth: c.entrywidth
                            text: modelData.name
                            color: Theme.text
                            font.pixelSize: 13
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                            wrapMode: Text.NoWrap
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: c.entrywidth
                            Layout.maximumWidth: c.entrywidth
                            text: modelData.genericName !== "" ? modelData.genericName : modelData.comment
                            color: Theme.subtext0
                            font.pixelSize: 11
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.NoWrap
                            elide: Text.ElideRight
                        }
                    }

                    HoverHandler {
                        id: hover
                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        acceptedButtons: Qt.LeftButton
                        gesturePolicy: TapHandler.ReleaseWithinBounds

                        onTapped: {
                            modelData.execute();
                            appLauncherWin.close();
                        }
                    }
                }
            }
        }
    }
}
