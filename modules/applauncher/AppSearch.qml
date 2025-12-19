import QtQuick
import QtQuick.Controls
import Quickshell
import "../../components"
import "../../services"
import "../../utils"
import "../../utils/types"
import "."

Item {
    id: search

    required property var view
    property var closeHandler: null

    focus: true
    property string searchTerm: ""
    property bool suppressSearchInputSync: false
    property var filteredApps: []

    implicitHeight: wrapper.implicitHeight + 16
    implicitWidth: wrapper.implicitWidth + 32

    function refreshFilter() {
        const apps = (DesktopEntries.applications?.values || []).filter(entry => !entry.noDisplay).filter(entry => {
            if (!searchTerm)
                return true;
            const query = searchTerm.toLowerCase();
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
            if (closeHandler)
                closeHandler();
        }
    }

    onSearchTermChanged: {
        if (!suppressSearchInputSync && searchInput && searchInput.text !== searchTerm)
            searchInput.text = searchTerm;
        refreshFilter();
        grid.positionViewAtBeginning();
    }

    Connections {
        target: DesktopEntries
        ignoreUnknownSignals: true
        function onApplicationsChanged() {
            search.refreshFilter();
        }
    }

    function onEnter() {
        refreshFilter();
        searchInput.forceActiveFocus();
    }

    Component.onCompleted: onEnter()

    Rectangle {
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
                placeholderTextColor: Config.styling.placeholderText
                selectionColor: Config.styling.selectionBackground
                selectedTextColor: Config.styling.selectionText
                font.pixelSize: height * 0.6
                verticalAlignment: TextInput.AlignVCenter
                background: Rectangle {
                    color: Config.styling.bg3
                    border.width: 1
                    border.color: searchInput.activeFocus ? Config.styling.primaryAccent : Config.styling.bg4
                }

                Keys.onEscapePressed: {
                    if (closeHandler)
                        closeHandler();
                }
                Keys.onReturnPressed: search.activateIndex(grid.currentIndex)
                Keys.onEnterPressed: search.activateIndex(grid.currentIndex)
                Keys.onUpPressed: grid.moveCurrentIndexUp()
                Keys.onDownPressed: grid.moveCurrentIndexDown()
                Keys.onLeftPressed: grid.moveCurrentIndexLeft()
                Keys.onRightPressed: grid.moveCurrentIndexRight()
                Keys.onPressed: event => {
                    if ((event.modifiers & Qt.ControlModifier) !== 0) {
                        switch (event.key) {
                        case Qt.Key_H:
                            grid.moveCurrentIndexLeft();
                            event.accepted = true;
                            return;
                        case Qt.Key_J:
                            grid.moveCurrentIndexDown();
                            event.accepted = true;
                            return;
                        case Qt.Key_K:
                            grid.moveCurrentIndexUp();
                            event.accepted = true;
                            return;
                        case Qt.Key_L:
                            grid.moveCurrentIndexRight();
                            event.accepted = true;
                            return;
                        }
                    }
                    if (event.key === Qt.Key_Question) {
                        event.accepted = true;
                        view.openDetails(grid.currentItem.desktopEntry);
                    }
                }

                onTextChanged: {
                    const normalizedText = text.trim().toLowerCase();
                    if (search.searchTerm === normalizedText)
                        return;
                    search.suppressSearchInputSync = true;
                    search.searchTerm = normalizedText;
                    search.suppressSearchInputSync = false;
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
                model: search.filteredApps
                focus: false
                boundsBehavior: Flickable.StopAtBounds

                delegate: Item {
                    required property var modelData
                    readonly property DesktopEntry desktopEntry: modelData
                    property bool isCurrentItem: GridView.isCurrentItem
                    implicitHeight: grid.cellHeight
                    implicitWidth: grid.cellWidth

                    ActiveIndicator {
                        side: ActiveIndicator.Side.Bottom
                        animationMode: ActiveIndicator.AnimationMode.GrowAll
                        active: isCurrentItem
                        bgActive: hoverHandler.hovered || isCurrentItem
                        thickness: 8
                    }

                    HoverScaler {
                        id: hoverHandler
                        scaleTarget: entry.icon
                        baseScale: isCurrentItem ? 1.0 : 0.8
                    }

                    TapHandler {
                        target: entry
                        onTapped: {
                            entry.desktopEntry.execute();
                            if (search.closeHandler)
                                search.closeHandler();
                        }
                    }
                    AppLauncherEntry {
                        id: entry
                        anchors.fill: parent
                        desktopEntry: modelData
                    }
                }

                Text {
                    anchors.centerIn: grid
                    text: searchTerm ? "No matching applications" : "No applications available"
                    visible: search.filteredApps.length === 0
                    color: Config.styling.text2
                    font.pixelSize: 14
                }
            }
        }
    }
}
