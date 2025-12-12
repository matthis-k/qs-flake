import QtQuick
import "../services"

Item {
    id: root

    enum Side {
        Top,
        Right,
        Bottom,
        Left
    }

    enum AnimationMode {
        None = 0,
        GrowAlong = 1,
        GrowAcross = 2,
        GrowAll = 3
    }

    property bool active: true
    property bool bgActive: active

    property int side: ActiveIndicator.Side.Top
    property int animationMode: ActiveIndicator.AnimationMode.GrowAll

    property real duration: 200
    property real bgOpacity: 0.3
    property color color: Config.styling.activeIndicator

    readonly property bool horizontal: side === ActiveIndicator.Side.Top || side === ActiveIndicator.Side.Bottom
    readonly property bool vertical: !horizontal

    property real thickness: (horizontal ? height : width) * 0.1

    anchors.fill: parent
    clip: true

    Item {
        id: content
        anchors.fill: parent

        property real t: active ? 1 : 0

        Behavior on t {
            NumberAnimation {
                duration: root.duration
                easing.type: Easing.OutCubic
            }
        }

        readonly property bool animateNormal: (animationMode & ActiveIndicator.AnimationMode.GrowAlong) !== 0
        readonly property bool animateLength: (animationMode & ActiveIndicator.AnimationMode.GrowAcross) !== 0

        readonly property real normalScale: animateNormal ? t : 1.0
        readonly property real lengthScale: animateLength ? t : 1.0

        transform: Scale {
            id: mainScale

            xScale: root.horizontal ? content.lengthScale : content.normalScale
            yScale: root.horizontal ? content.normalScale : content.lengthScale

            origin.x: root.horizontal ? content.width / 2 : (side === ActiveIndicator.Side.Left ? 0 : content.width)
            origin.y: root.horizontal ? (side === ActiveIndicator.Side.Top ? 0 : content.height) : content.height / 2
        }

        opacity: content.t

        Rectangle {
            opacity: bgActive ? root.bgOpacity : 0
            color: root.color
            anchors.fill: parent
        }

        Rectangle {
            id: indicator
            color: root.color

            anchors {
                top: side === ActiveIndicator.Side.Top ? parent.top : undefined
                right: side === ActiveIndicator.Side.Right ? parent.right : undefined
                bottom: side === ActiveIndicator.Side.Bottom ? parent.bottom : undefined
                left: side === ActiveIndicator.Side.Left ? parent.left : undefined
            }

            implicitHeight: root.horizontal ? root.thickness : parent.height
            implicitWidth: root.vertical ? root.thickness : parent.width
        }
    }
}
