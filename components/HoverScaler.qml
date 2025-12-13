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
    property int scaleAnimationDuration: 150
    property var scaleAnimationEasing: Easing.OutCubic

    function updateScale() {
        if (!scaleTarget)
            return;

        const hoverFactor = hovered ? hoveredScale : unhoveredScale;
        const targetScale = baseScale * hoverFactor;

        scaleAnimation.stop();

        if (scaleAnimationDuration <= 0) {
            scaleTarget.scale = targetScale;
            return;
        }

        scaleAnimation.to = targetScale;
        scaleAnimation.start();
    }

    NumberAnimation {
        id: scaleAnimation
        target: root.scaleTarget
        property: "scale"
        duration: root.scaleAnimationDuration
        easing.type: root.scaleAnimationEasing
    }

    HoverHandler {
        id: hoverHandler
        target: hoverTarget
    }

    onBaseScaleChanged: updateScale()
    onHoveredChanged: root.updateScale()
    Component.onCompleted: updateScale()
}
