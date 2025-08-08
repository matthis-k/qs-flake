import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../theme"

Item {
    id: root
    default property list<Item> children
    property Component header: null

    property bool hasHeader: root.header != null
    property bool hasChildren: {
        for (let i = 0; i < root.children.length; ++i) {
            if (root.children[i].visible) {
                return true;
            }
        }
        return false;
    }

    property real margin: 4
    property real radius: Theme.rounded * height / 2
    property color headerBackground: Theme.base
    property color contentBackground: Theme.surface1

    implicitWidth: connector.width

    Rectangle {
        id: connector
        anchors.left: header.left
        anchors.right: content.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.rightMargin: root.hasChildren && content.childrenRect.width > 0 ? -root.radius : 0
        radius: root.radius
        color: root.contentBackground
    }

    Rectangle {
        id: header
        visible: root.hasHeader
        color: root.headerBackground
        implicitHeight: root.height
        implicitWidth: Math.max(root.hasHeader * (loader.item?.implicitWidth || 0), root.hasHeader * root.height, !root.hasHeader * (root.radius - root.margin / 2))
        radius: root.radius
        clip: true
        layer.enabled: true
        layer.smooth: true
        Loader {
            id: loader
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: header.width
                    height: header.height
                    radius: root.radius
                }
            }
            anchors.fill: parent
            anchors.centerIn: parent
            sourceComponent: root.header
        }
    }

    RowLayout {
        id: content
        anchors.left: header.right
        anchors.top: parent.top
        anchors.bottom: header.bottom
        anchors.leftMargin: root.hasChildren && content.childrenRect.width > 0 ? Math.min(root.radius, root.margin) : 0
        data: root.children
    }
}
