import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../services"

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
    property real minimumHeight: 28

    property real radius: Config.styling.rounded * implicitHeight / 2

    property color headerBackground: Config.styling.bg2
    property color contentBackground: Config.styling.bg4

    property real headerContentImplicitHeight: {
        if (!root.hasHeader || !loader.item)
            return 0;
        return loader.item.implicitHeight > 0 ? loader.item.implicitHeight : (loader.item.height || 0);
    }

    property real headerContentImplicitWidth: {
        if (!root.hasHeader || !loader.item)
            return 0;
        return loader.item.implicitWidth > 0 ? loader.item.implicitWidth : (loader.item.width || 0);
    }

    implicitWidth: connector.width
    implicitHeight: {
        const h = headerContentImplicitHeight;
        const c = content.implicitHeight || 0;
        return Math.max(minimumHeight, h, c);
    }

    Rectangle {
        id: connector
        anchors {
            left: header.left
            right: content.right
            top: parent.top
            bottom: parent.bottom
            rightMargin: root.hasChildren && content.childrenRect.width > 0 ? -root.radius : 0
        }
        radius: root.radius
        color: root.contentBackground
    }

    Rectangle {
        id: header
        visible: root.hasHeader
        color: root.headerBackground

        height: parent.height
        implicitHeight: Math.max(root.minimumHeight, root.headerContentImplicitHeight)

        implicitWidth: root.hasHeader ? Math.max(root.headerContentImplicitWidth, implicitHeight) : (root.radius - root.margin / 2)

        radius: root.radius
        clip: true
        layer.enabled: true
        layer.smooth: true

        Loader {
            id: loader
            anchors.fill: parent
            anchors.centerIn: parent

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: header.width
                    height: header.height
                    radius: root.radius
                }
            }

            sourceComponent: root.header
        }
    }

    RowLayout {
        id: content
        anchors.left: header.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.leftMargin: root.hasChildren && content.childrenRect.width > 0 ? Math.min(root.radius, root.margin) : 0
        data: root.children
    }
}
