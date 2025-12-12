import QtQuick

Item {
    id: root

    anchors.fill: parent

    property Item hoverTarget: root.parent
    property Item scaleTarget: root.parent

    property alias hovered: hoverHandler.hovered

    property real hoveredScale: 1.0
    property real unhoveredScale: 0.8
    property real baseScale: 1.0

    function updateScale() {
        if (!scaleTarget)
            return;
        const hoverFactor = hovered ? hoveredScale : unhoveredScale;
        scaleTarget.scale = baseScale * hoverFactor;
    }

    HoverHandler {
        id: hoverHandler
        target: hoverTarget
    }

    onBaseScaleChanged: updateScale()
    onHoveredChanged: root.updateScale()
    Component.onCompleted: updateScale()
}
