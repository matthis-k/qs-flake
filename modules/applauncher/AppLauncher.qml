import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "../../components"
import "../../services"

FocusScope {
    id: root
    focus: true

    readonly property int cellWidth: 160
    readonly property int cellHeight: 120
    readonly property real widthFraction: 0.75
    readonly property real heightFraction: 0.75
    readonly property real searchHeight: 44
    readonly property int outerPadding: 64
    readonly property int spacing: 24

    property string filterText: ""
    property var filteredApps: []

    readonly property real availableWidth: Math.max(cellWidth * 2, (screen ? screen.width : 1280) * widthFraction)
    readonly property real availableHeight: Math.max(cellHeight * 2, (screen ? screen.height : 720) * heightFraction)

    readonly property int calculatedColumns: Math.max(2, Math.floor(availableWidth / cellWidth))
    readonly property int columns: Math.max(2, calculatedColumns - (calculatedColumns % 2))
    readonly property int maxRows: Math.max(1, Math.floor(availableHeight / cellHeight))

    implicitWidth: Math.min(columns * cellWidth + outerPadding * 2, (screen ? screen.width : (columns * cellWidth + outerPadding * 2)))
    implicitHeight: Math.min(maxRows * cellHeight + searchHeight + spacing + outerPadding * 2, (screen ? screen.height : (maxRows * cellHeight + searchHeight + spacing + outerPadding * 2)))

    Keys.onEscapePressed: ShellState.getScreenByName(screen.name).appLauncher.close()

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
        forceActiveFocus();
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: Math.min(columns * cellWidth + outerPadding * 2, root.availableWidth)
        height: Math.min(maxRows * cellHeight + searchHeight + spacing + outerPadding * 2, root.availableHeight)
        color: Config.styling.bg0
        border.color: Config.styling.primaryAccent

        ColumnLayout {
            id: layoutRoot
            anchors.fill: parent
            anchors.margins: outerPadding
            spacing: spacing

            TextField {
                id: searchInput
                focus: true
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: Math.min(card.width - outerPadding, 480)
                Layout.minimumWidth: 320
                placeholderText: "Search apps"
                color: Config.styling.text0

                placeholderTextColor: Config.styling.bg7
                selectionColor: Config.colors.sapphire
                selectedTextColor: Config.styling.bg2
                font.pixelSize: 16
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

            Item {
                id: gridWrapper
                Layout.fillWidth: true
                Layout.fillHeight: true

                GridView {
                    id: grid
                    anchors.fill: parent
                    cellWidth: root.cellWidth
                    cellHeight: root.cellHeight
                    snapMode: GridView.SnapToRow
                    clip: true
                    model: root.filteredApps
                    focus: false
                    boundsBehavior: Flickable.StopAtBounds

                    delegate: Item {
                        id: cell
                        width: grid.cellWidth
                        height: grid.cellHeight
                        required property int index
                        required property var modelData
                        readonly property bool selected: index === grid.currentIndex

                        HoverScaler {
                            id: hoverHandler
                            hoverTarget: cell
                            scaleTarget: iconWrapper
                            hoveredScale: 1.0
                            unhoveredScale: 0.8
                        }

                        ActiveIndicator {
                            id: indicator
                            anchors.fill: parent
                            side: ActiveIndicator.Side.Bottom
                            color: Config.styling.good
                            active: cell.selected
                            bgActive: hoverHandler.hovered || cell.selected
                            animationMode: ActiveIndicator.AnimationMode.GrowAll
                        }

                        ColumnLayout {
                            id: entryContent
                            anchors.centerIn: parent
                            spacing: 4
                            width: Math.min(parent.width, 140)

                            Item {
                                id: iconWrapper
                                Layout.alignment: Qt.AlignHCenter
                                implicitWidth: 48
                                implicitHeight: 48

                                Icon {
                                    id: entryIcon
                                    anchors.centerIn: parent
                                    implicitSize: 48
                                    smooth: true
                                    source: Quickshell.iconPath(cell.modelData?.icon, "dialog-warning")
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                                text: cell.modelData?.name || ""
                                color: Config.styling.text0
                                font.pixelSize: 14
                                font.bold: true
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                                text: cell.modelData?.genericName || cell.modelData?.comment || ""
                                color: Config.styling.text2
                                font.pixelSize: 12
                                elide: Text.ElideRight
                            }
                        }

                        TapHandler {
                            acceptedButtons: Qt.LeftButton
                            gesturePolicy: TapHandler.ReleaseWithinBounds
                            cursorShape: Qt.PointingHandCursor
                            onTapped: {
                                grid.currentIndex = cell.index;
                                root.activateIndex(cell.index);
                            }
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
}
