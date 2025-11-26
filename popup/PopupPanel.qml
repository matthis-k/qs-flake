import QtQuick
import QtQuick
import Quickshell
import "./"


PanelWindow {
    id: root
    color: "transparent"
    visible: hasActivePopups
    mask: hasActivePopups ? maskRegion : null

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    readonly property var anchorItems: [topLeftAnchor, topCenterAnchor, topRightAnchor, middleLeftAnchor, middleCenterAnchor, middleRightAnchor, bottomLeftAnchor, bottomCenterAnchor, bottomRightAnchor]

    readonly property bool hasActivePopups: anchorItems.some(anchor => anchor.hasContent)

    readonly property QtObject topLeft: topLeftAnchor.controller
    readonly property QtObject topCenter: topCenterAnchor.controller
    readonly property QtObject topRight: topRightAnchor.controller
    readonly property QtObject middleLeft: middleLeftAnchor.controller
    readonly property QtObject middleCenter: middleCenterAnchor.controller
    readonly property QtObject middleRight: middleRightAnchor.controller
    readonly property QtObject bottomLeft: bottomLeftAnchor.controller
    readonly property QtObject bottomCenter: bottomCenterAnchor.controller
    readonly property QtObject bottomRight: bottomRightAnchor.controller

    function hideAll(timeout_ms) {
        const timeout = timeout_ms ?? 0;
        anchorItems.forEach(anchor => anchor.controller.hide(timeout));
    }

    Region {
        id: maskRegion

        Region { item: topLeftAnchor.maskItem }
        Region { item: topCenterAnchor.maskItem }
        Region { item: topRightAnchor.maskItem }
        Region { item: middleLeftAnchor.maskItem }
        Region { item: middleCenterAnchor.maskItem }
        Region { item: middleRightAnchor.maskItem }
        Region { item: bottomLeftAnchor.maskItem }
        Region { item: bottomCenterAnchor.maskItem }
        Region { item: bottomRightAnchor.maskItem }
    }

    PopupAnchor {
        id: topLeftAnchor
        anchors.fill: parent
        verticalPosition: "top"
        horizontalPosition: "left"
    }

    PopupAnchor {
        id: topCenterAnchor
        anchors.fill: parent
        verticalPosition: "top"
        horizontalPosition: "center"
    }

    PopupAnchor {
        id: topRightAnchor
        anchors.fill: parent
        verticalPosition: "top"
        horizontalPosition: "right"
    }

    PopupAnchor {
        id: middleLeftAnchor
        anchors.fill: parent
        verticalPosition: "center"
        horizontalPosition: "left"
    }

    PopupAnchor {
        id: middleCenterAnchor
        anchors.fill: parent
        verticalPosition: "center"
        horizontalPosition: "center"
    }

    PopupAnchor {
        id: middleRightAnchor
        anchors.fill: parent
        verticalPosition: "center"
        horizontalPosition: "right"
    }

    PopupAnchor {
        id: bottomLeftAnchor
        anchors.fill: parent
        verticalPosition: "bottom"
        horizontalPosition: "left"
    }

    PopupAnchor {
        id: bottomCenterAnchor
        anchors.fill: parent
        verticalPosition: "bottom"
        horizontalPosition: "center"
    }

    PopupAnchor {
        id: bottomRightAnchor
        anchors.fill: parent
        verticalPosition: "bottom"
        horizontalPosition: "right"
    }
}
