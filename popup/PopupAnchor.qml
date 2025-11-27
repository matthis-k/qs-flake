import QtQuick
import "../services"

Item {
    id: root
    // Hosts a popup for a specific anchor and exposes an imperative API via controller
    property string verticalPosition: "top"
    property string horizontalPosition: "right"
    property real margin: 0
    property real padding: 16
    property real cornerRadius: Config.styling.rounded * 16
    property color backgroundColor: Config.styling.bg0
    property color borderColor: Config.styling.primaryAccent
    property real borderWidth: 1
    readonly property bool hasContent: loader.active
    property Component currentComponent: null
    property bool isPeeking: false
    property bool autoCloseOnHoverLeave: true
    property int defaultHoverCloseDelay: 500
    property int hoverCloseDelay: defaultHoverCloseDelay
    readonly property Item maskItem: loader.active ? popupContainer : null

    anchors.fill: parent

    readonly property QtObject controller: QtObject {
        readonly property bool visible: loader.active
        readonly property real width: loader.active ? popupContainer.width : 0
        readonly property real height: loader.active ? popupContainer.height : 0
        function show(component, options) {
            root.show(component, options);
        }
        function hide(timeout_ms) {
            root.hide(timeout_ms);
        }
        function toggle(component, options) {
            root.toggle(component, options);
        }
        function setContent(component, options) {
            root.setContent(component, options);
        }
        function cancelHide() {
            root.cancelHide();
        }
    }

    Timer {
        id: hideTimer
        repeat: false
        onTriggered: root.finishHide()
    }

    function assignComponent(component, properties) {
        if (!component)
            return;
        loader.active = false;
        loader.sourceComponent = component;
        loader.active = true;
        if (properties && loader.item) {
            for (const key of Object.keys(properties))
                loader.item[key] = properties[key];
        }
    }

    function normalizeOptions(options) {
        const opts = options || {};
        const normalized = {
            hoverCloseDelay: opts.hoverCloseDelay ?? defaultHoverCloseDelay,
            peeking: !!opts.peeking,
            autoClose: opts.autoClose !== undefined ? opts.autoClose : true,
            properties: opts.properties || null
        };
        if (normalized.peeking)
            normalized.hoverCloseDelay = Math.min(normalized.hoverCloseDelay, Config.styling.peekCloseDelay);
        return normalized;
    }

    function show(component, options) {
        const opts = normalizeOptions(options);
        hoverCloseDelay = opts.hoverCloseDelay;
        isPeeking = opts.peeking;
        autoCloseOnHoverLeave = opts.autoClose;
        cancelHide();
        if (currentComponent !== component) {
            currentComponent = component;
            assignComponent(component, opts.properties);
        } else {
            // Update properties without reloading
            if (opts.properties && loader.item) {
                for (const key of Object.keys(opts.properties))
                    loader.item[key] = opts.properties[key];
            }
        }
    }

    function hide(timeout_ms) {
        hideTimer.stop();
        const timeout = timeout_ms ?? 0;
        if (timeout <= 0) {
            finishHide();
        } else {
            hideTimer.interval = timeout;
            hideTimer.start();
        }
    }

    function finishHide() {
        hideTimer.stop();
        loader.active = false;
        loader.sourceComponent = null;
        currentComponent = null;
        isPeeking = false;
        autoCloseOnHoverLeave = true;
        hoverCloseDelay = defaultHoverCloseDelay;
    }

    function toggle(component, options) {
        const opts = normalizeOptions(options);
        if (loader.active && currentComponent === component) {
            if (opts.peeking !== isPeeking) {
                show(component, options);
                return;
            }
            hide(0);
        } else {
            show(component, options);
        }
    }

    function setContent(component, options) {
        const opts = options || {};
        cancelHide();
        currentComponent = component;
        assignComponent(component, opts.properties || null);
    }

    function cancelHide() {
        hideTimer.stop();
    }

    Item {
        id: popupContainer
        visible: loader.active
        z: 10
        anchors {
            top: verticalPosition === "top" ? parent.top : undefined
            bottom: verticalPosition === "bottom" ? parent.bottom : undefined
            verticalCenter: verticalPosition === "center" ? parent.verticalCenter : undefined
            left: horizontalPosition === "left" ? parent.left : undefined
            right: horizontalPosition === "right" ? parent.right : undefined
            horizontalCenter: horizontalPosition === "center" ? parent.horizontalCenter : undefined
            topMargin: verticalPosition === "top" ? margin : 0
            bottomMargin: verticalPosition === "bottom" ? margin : 0
            leftMargin: horizontalPosition === "left" ? margin : 0
            rightMargin: horizontalPosition === "right" ? margin : 0
        }

        HoverHandler {
            id: popupHover
            target: popupContainer
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onHoveredChanged: {
                if (hovered) {
                    root.cancelHide();
                } else if (loader.active && (autoCloseOnHoverLeave || root.isPeeking)) {
                    root.hide(root.hoverCloseDelay);
                }
            }
        }

        readonly property real contentImplicitWidth: loader.item ? Math.max(loader.item.implicitWidth || 0, 0) : 0
        readonly property real contentImplicitHeight: loader.item ? Math.max(loader.item.implicitHeight || 0, 0) : 0

        implicitWidth: Math.max(contentImplicitWidth, 0) + padding * 2
        implicitHeight: Math.max(contentImplicitHeight, 0) + padding * 2
        width: implicitWidth
        height: implicitHeight

        Rectangle {
            id: frame
            anchors.fill: parent
            radius: cornerRadius
            color: backgroundColor
            border.color: borderColor
            border.width: borderWidth
        }

        Item {
            id: contentHost
            anchors.fill: frame
            anchors.margins: padding
            clip: true

            Loader {
                id: loader
                active: false
                asynchronous: false
                anchors.fill: parent
            }
        }
    }
}
