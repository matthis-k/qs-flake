import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Services.Pipewire
import "../services"
import "../components"
import "../managers"
import "../panels"

Item {
    id: root
    implicitWidth: height

    Component {
        id: audioPopupComponent
        AudioPanel {}
    }

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
        root.sink.audio.volume = root.clampVol(root.sink.audio.volume + wheelDeltaToStep(event));
    }
    function adjustStream(stream, event) {
        if (!stream?.audio)
            return;
        stream.audio.volume = root.clampVol(stream.audio.volume + wheelDeltaToStep(event));
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
    StatusIcon {
        anchors.fill: parent
        iconName: root.volumeIcon(root.sink?.audio?.volume, root.sink?.audio?.muted)
        overlayColor: root.overlayColor(root.sink?.audio?.volume, root.sink?.audio?.muted)
        popupComponent: audioPopupComponent
        opacity: root.hasSink ? 1.0 : 0.7
    }

    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: {
            root.adjustMaster(event);
            event.accepted = true;
        }
    }
}
