import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import "../theme"
import "../components"

Item {
    id: root
    implicitWidth: parent?.height ?? 24
    implicitHeight: parent?.height ?? 24

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool hasSink: !!sink && !!sink.audio
    readonly property real maxVol: 1.0

    function pct(v) {
        return Math.round((v ?? 0) * 100);
    }

    function volumeIcon(vol, muted) {
        if (muted || (vol ?? 0) <= 0.001)
            return "audio-volume-muted-symbolic";
        const p = (vol ?? 0);
        if (p < 0.34)
            return "audio-volume-low-symbolic";
        if (p < 0.67)
            return "audio-volume-medium-symbolic";
        return "audio-volume-high-symbolic";
    }

    function overlayColor(vol, muted) {
        if (muted)
            return Theme.red;
        if ((vol ?? 0) === 0.0)
            return Theme.peach;
        return Theme.text;
    }

    function clampVol(v) {
        return Math.max(0.0, Math.min(root.maxVol, v));
    }
    function wheelDeltaToStep(event) {
        const notches = (event.angleDelta?.y ?? 0) / 120;
        const step = (event.modifiers & Qt.ShiftModifier) ? 0.05 : 0.02;
        return notches * step;
    }
    function adjustMaster(event) {
        if (!root.hasSink)
            return;
        root.sink.audio.volume = clampVol(root.sink.audio.volume + wheelDeltaToStep(event));
    }
    function adjustStream(stream, event) {
        if (!stream?.audio)
            return;
        stream.audio.volume = clampVol(stream.audio.volume + wheelDeltaToStep(event));
    }

    function streamDisplayName(s) {
        if (!s)
            return "Application";
        const p = s.properties || {};
        return (s.description || p["node.description"] || p["media.name"] || s.nickname || p["node.nick"] || p["application.name"] || s.description || s.name || "Application");
    }

    PwNodeLinkTracker {
        id: sinkLinks
        node: root.sink
    }

    PwObjectTracker {
        id: binder
        objects: {
            const objs = [];
            if (root.sink)
                objs.push(root.sink);
            for (let i = 0; i < sinkLinks.linkGroups.length; ++i) {
                const lg = sinkLinks.linkGroups[i];
                if (lg?.source)
                    objs.push(lg.source);
                if (lg?.target)
                    objs.push(lg.target);
            }
            return objs;
        }
    }

    ColorOverlay {
        anchors.centerIn: parent
        anchors.fill: parent
        color: overlayColor(root.sink?.audio?.volume, root.sink?.audio?.muted)
        source: IconImage {
            anchors.fill: parent
            anchors.margins: 4
            implicitSize: 24
            source: Quickshell.iconPath(volumeIcon(root.sink?.audio?.volume, root.sink?.audio?.muted), "multimedia-volume-control")
            opacity: root.hasSink ? 1.0 : 0.7
        }
    }
    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: {
            adjustMaster(event);
            event.accepted = true;
        }
    }

    GenericTooltip {
        anchors.centerIn: parent
        anchors.fill: parent
        background: Theme.crust
        canEnterTooltip: true
        popupWidth: 300

        tooltipContent: ColumnLayout {
            spacing: 10

            RowLayout {
                id: masterRow
                Layout.fillWidth: true
                Layout.leftMargin: 4
                spacing: 10

                ColorOverlay {
                    implicitWidth: 32
                    implicitHeight: 32
                    color: overlayColor(root.sink?.audio?.volume, root.sink?.audio?.muted)
                    source: IconImage {
                        anchors.centerIn: parent
                        implicitSize: 32
                        source: Quickshell.iconPath(volumeIcon(root.sink?.audio?.volume, root.sink?.audio?.muted), "multimedia-volume-control")
                    }
                    TapHandler {
                        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad | PointerDevice.Stylus
                        gesturePolicy: TapHandler.ReleaseWithinBounds
                        onTapped: if (root.hasSink)
                            root.sink.audio.muted = !root.sink.audio.muted
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignLeft
                            elide: Text.ElideRight
                            color: Theme.text
                            text: root.hasSink ? `${root.sink.nickname || root.sink.description || "Output"}` : "No output device"
                        }
                        Text {
                            Layout.alignment: Qt.AlignRight
                            color: Theme.subtext0
                            text: root.hasSink ? `${pct(root.sink.audio.volume)}%` : "--%"
                            width: 56
                            horizontalAlignment: Text.AlignRight
                        }
                    }

                    Slider {
                        id: masterSlider
                        Layout.fillWidth: true
                        from: 0.0
                        to: root.maxVol
                        stepSize: 0
                        value: root.hasSink ? root.sink.audio.volume : 0
                        onMoved: if (root.hasSink)
                            root.sink.audio.volume = value
                    }
                }

                WheelHandler {
                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                    onWheel: {
                        adjustMaster(event);
                        event.accepted = true;
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    color: Theme.subtext1
                    text: "Apps"
                    font.bold: true
                }

                ListView {
                    id: appList
                    visible: root.hasSink
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(280, contentHeight)
                    clip: true
                    spacing: 6
                    model: sinkLinks.linkGroups

                    delegate: Item {
                        required property var modelData
                        width: appList.width
                        height: row.implicitHeight

                        readonly property var stream: modelData?.source
                        readonly property bool isAudio: !!stream && !!stream.audio
                        visible: isAudio

                        RowLayout {
                            id: row
                            anchors.fill: parent
                            anchors.margins: 2
                            spacing: 8

                            ColorOverlay {
                                implicitWidth: 18
                                implicitHeight: 18
                                color: overlayColor(stream?.audio?.volume, stream?.audio?.muted)
                                source: IconImage {
                                    implicitSize: 18
                                    source: Quickshell.iconPath(volumeIcon(stream?.audio?.volume, stream?.audio?.muted), "multimedia-volume-control")
                                }

                                TapHandler {
                                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad | PointerDevice.Stylus
                                    gesturePolicy: TapHandler.ReleaseWithinBounds
                                    onTapped: if (stream?.audio)
                                        stream.audio.muted = !stream.audio.muted
                                }
                                WheelHandler {
                                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                                    onWheel: {
                                        adjustStream(stream, event);
                                        event.accepted = true;
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 4

                                    Text {
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                        color: Theme.text
                                        text: streamDisplayName(stream)
                                    }
                                    Text {
                                        width: 56
                                        horizontalAlignment: Text.AlignRight
                                        color: Theme.text
                                        text: stream?.audio ? `${pct(stream.audio.volume)}%` : "--%"
                                    }
                                }

                                Slider {
                                    Layout.fillWidth: true
                                    from: 0.0
                                    to: root.maxVol
                                    stepSize: 0
                                    enabled: !!stream?.audio
                                    value: stream?.audio?.volume ?? 0
                                    onMoved: if (stream?.audio)
                                        stream.audio.volume = value
                                }
                            }
                        }

                        WheelHandler {
                            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                            onWheel: {
                                adjustStream(stream, event);
                                event.accepted = true;
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 1
                            y: row.implicitHeight + 2
                            color: Theme.surface1
                        }
                    }
                }

                Text {
                    visible: root.hasSink && appList.count === 0
                    color: Theme.subtext0
                    text: "No active app streams"
                }
                Text {
                    visible: !root.hasSink
                    color: Theme.subtext0
                    text: "No output sink available"
                }
            }
        }
    }
}
