import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import "../services"
import "../components"
import "../managers"

Item {
    id: root
    implicitWidth: height

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
            return Config.styling.critical;
        if ((vol ?? 0) === 0.0)
            return Config.styling.warning;
        return Config.styling.text0;
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
    IconImage {
        id: icon
        anchors.centerIn: parent
        anchors.margins: Math.floor(root.height * (1 - Config.styling.statusIconScaler) / 2)
        implicitSize: Math.round(root.height * Config.styling.statusIconScaler / 2) * 2
        source: Quickshell.iconPath(volumeIcon(root.sink?.audio?.volume, root.sink?.audio?.muted), "multimedia-volume-control")
        opacity: root.hasSink ? 1.0 : 0.7
    }

    ColorOverlay {
        anchors.fill: icon
        color: overlayColor(root.sink?.audio?.volume, root.sink?.audio?.muted)
        source: icon
    }

    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: {
            adjustMaster(event);
            event.accepted = true;
        }
    }

    property bool peeking: false

    HoverHandler {
        onHoveredChanged: {
            if (hovered) {
                peeking = true;
                QuickSettingsManager.open("audio", peeking);
            } else if (peeking) {
                QuickSettingsManager.close(500);
            }
        }
    }

    TapHandler {
        onSingleTapped: {
            peeking = false;
            QuickSettingsManager.toggle("audio", peeking);
        }
    }
}
