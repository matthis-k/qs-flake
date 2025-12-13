import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "../../components"
import "../../services"
import "../../utils"

Item {
    id: root
    focus: true

    implicitHeight: wrapper.implicitHeight + 16
    implicitWidth: wrapper.implicitWidth + 32

    property string filterText: ""
    property var filteredApps: []

    function refreshFilter() {
        const apps = (DesktopEntries.applications?.values || []).filter(entry => !entry.noDisplay).filter(entry => {
            if (!filterText)
                return true;
            const query = filterText.toLowerCase();
            const name = (entry.name || "").toLowerCase();
            const generic = (entry.genericName || "").toLowerCase();
            const comment = (entry.comment || "").toLowerCase();
            return name.includes(query) || generic.includes(query) || comment.includes(query);
        }).sort((lhs, rhs) => (lhs.name || "").toLowerCase().localeCompare((rhs.name || "").toLowerCase()));
        filteredApps = apps;
        if (apps.length === 0) {
            grid.currentIndex = -1;
            return;
        }
        if (grid.currentIndex < 0 || grid.currentIndex >= apps.length) {
            grid.currentIndex = 0;
        }
    }

    function activateIndex(idx) {
        if (idx < 0 || idx >= filteredApps.length)
            return;
        const entry = filteredApps[idx];
        if (entry && entry.execute) {
            entry.execute();
            ShellState.getScreenByName(screen.name).appLauncher.close();
        }
    }

    Connections {
        target: DesktopEntries
        ignoreUnknownSignals: true
        function onApplicationsChanged() {
            root.refreshFilter();
        }
    }

    Component.onCompleted: {
        refreshFilter();
        searchInput.forceActiveFocus();
    }

    Rectangle {
        id: bg
        color: Config.styling.bg0
        border.width: 1
        border.color: Config.styling.primaryAccent
        anchors.fill: parent
    }

    Item {
        id: wrapper
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        implicitHeight: inputWrapper.implicitHeight + gridWrapper.implicitHeight
        implicitWidth: gridWrapper.implicitWidth
        Item {
            id: inputWrapper
            implicitHeight: Pixels.mm(30, screen)
            anchors.top: parent.top
            anchors.left: gridWrapper.left
            anchors.right: gridWrapper.right
            height: implicitHeight

            TextField {
                id: searchInput
                anchors.centerIn: parent
                implicitHeight: parent.height / 3
                implicitWidth: parent.width / 3
                placeholderText: "Search apps"

                focus: true

                color: Config.styling.text0
                placeholderTextColor: Config.styling.bg7
                selectionColor: Config.colors.sapphire
                selectedTextColor: Config.styling.bg2

                font.pixelSize: height * 0.6
                verticalAlignment: TextInput.AlignVCenter
                background: Rectangle {
                    color: Config.styling.bg2
                    border.width: 1
                    border.color: searchInput.activeFocus ? Config.styling.primaryAccent : Config.styling.bg4
                }

                Keys.onEscapePressed: ShellState.getScreenByName(screen.name).appLauncher.close()
                Keys.onReturnPressed: root.activateIndex(grid.currentIndex)
                Keys.onEnterPressed: root.activateIndex(grid.currentIndex)
                Keys.onUpPressed: grid.moveCurrentIndexUp()
                Keys.onDownPressed: grid.moveCurrentIndexDown()
                Keys.onLeftPressed: grid.moveCurrentIndexLeft()
                Keys.onRightPressed: grid.moveCurrentIndexRight()

                onTextChanged: {
                    root.filterText = text.trim().toLowerCase();
                    root.refreshFilter();
                    grid.positionViewAtBeginning();
                }
            }
        }
        Item {
            id: gridWrapper
            anchors.top: inputWrapper.bottom
            implicitWidth: grid.implicitWidth
            implicitHeight: grid.implicitHeight
            width: implicitWidth
            height: implicitHeight
            GridView {
                id: grid
                cellWidth: Pixels.mm(50, screen)
                cellHeight: Pixels.mm(30, screen)
                implicitWidth: cellWidth * 6
                implicitHeight: cellHeight * 6
                width: implicitWidth
                height: implicitHeight

                snapMode: GridView.SnapToRow
                clip: true
                model: root.filteredApps
                focus: false
                boundsBehavior: Flickable.StopAtBounds

                delegate: Entry {
                    id: entry
                    property bool isCurrentItem
                    implicitHeight: grid.cellHeight
                    implicitWidth: grid.cellWidth
                    required property var modelData
                    desktopEntry: modelData

                    ActiveIndicator {
                        side: ActiveIndicator.Side.Bottom
                        animationMode: ActiveIndicator.AnimationMode.GrowAll
                        active: entry.GridView.isCurrentItem
                        bgActive: hoverHandler.hovered || entry.GridView.isCurrentItem
                        thickness: 8
                    }
                    HoverScaler {
                        id: hoverHandler
                        hoverTarget: entry
                        scaleTarget: entry.icon
                        baseScale: isCurrentItem ? 1.0 : 0.8
                    }
                    TapHandler {
                        target: parent
                        onTapped: {
                            entry.desktopEntry.execute();
                            ShellState.getScreenByName(screen.name).appLauncher.close();
                        }
                    }
                }

                Text {
                    anchors.centerIn: grid
                    text: filterText ? "No matching applications" : "No applications available"
                    visible: root.filteredApps.length === 0
                    color: Config.styling.text2
                    font.pixelSize: 14
                }
            }
        }
    }

    component Entry: Item {
        required property DesktopEntry desktopEntry
        readonly property alias icon: icon
        Item {
            id: iconWrapper
            implicitHeight: parent.height * 0.5
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.left: parent.left
            Icon {
                id: icon
                anchors.centerIn: parent
                implicitSize: parent.height
                smooth: true
                source: Quickshell.iconPath(desktopEntry?.icon, "dialog-warning")
            }
        }
        Item {
            anchors.top: iconWrapper.bottom
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            Text {
                id: entryName
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.top: parent.top
                horizontalAlignment: Text.AlignHCenter
                text: desktopEntry?.name || ""
                color: Config.styling.text0
                font.pixelSize: parent.height / 4
                font.bold: true
                elide: Text.ElideRight
            }

            Text {
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.top: entryName.bottom
                horizontalAlignment: Text.AlignHCenter
                text: desktopEntry?.genericName || desktopEntry?.comment || ""
                color: Config.styling.text2
                font.pixelSize: parent.height / 5
                elide: Text.ElideRight
            }
        }
    }
}
