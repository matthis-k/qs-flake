import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import "../theme"
import "../components"
import "../managers"

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

    TapHandler {
        onSingleTapped: {
            QuickSettingsManager.toggle("audio");
        }
    }
}
