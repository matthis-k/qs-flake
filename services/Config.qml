pragma Singleton
import QtQml
import QtQuick
import Quickshell

Singleton {
    id: cfg

    PersistentProperties {
        id: colorsObj
        reloadableId: "persitentColors"

        property color rosewater: "#f5e0dc"
        property color flamingo: "#f2cdcd"
        property color pink: "#f5c2e7"
        property color mauve: "#cba6f7"
        property color red: "#f38ba8"
        property color maroon: "#eba0ac"
        property color peach: "#fab387"
        property color yellow: "#f9e2af"
        property color green: "#a6e3a1"
        property color teal: "#94e2d5"
        property color sky: "#89dceb"
        property color sapphire: "#74c7ec"
        property color blue: "#89b4fa"
        property color lavender: "#b4befe"

        property color text: "#cdd6f4"
        property color subtext1: "#bac2de"
        property color subtext0: "#a6adc8"
        property color overlay2: "#9399b2"
        property color overlay1: "#7f849c"
        property color overlay0: "#6c7086"
        property color surface2: "#585b70"
        property color surface1: "#45475a"
        property color surface0: "#313244"
        property color base: "#1e1e2e"
        property color mantle: "#181825"
        property color crust: "#11111b"
    }

    PersistentProperties {
        id: stylingObj
        reloadableId: "persitentStyling"

        property color bg0: colorsObj.crust
        property color bg1: colorsObj.mantle
        property color bg2: colorsObj.base
        property color bg3: colorsObj.surface0
        property color bg4: colorsObj.surface1
        property color bg5: colorsObj.surface2
        property color bg6: colorsObj.overlay0
        property color bg7: colorsObj.overlay1
        property color bg8: colorsObj.overlay2

        property color text0: colorsObj.text
        property color text1: colorsObj.subtext0
        property color text2: colorsObj.subtext1

        property color primaryAccent: colorsObj.blue
        property color secondaryAccent: colorsObj.sky

        property color good: colorsObj.green
        property color normal: colorsObj.text
        property color warning: colorsObj.peach
        property color critical: colorsObj.red

        property color bluetooth: colorsObj.blue
        property color activeIndicator: colorsObj.green

        property bool rounded: false
        property int radius: 8 * rounded
        property int margin: radius

        property double statusIconScaler: 0.8

        readonly property QtObject animation: QtObject {
            property double duration_multiplier: 1.0
            readonly property bool enabled: duration_multiplier !== 0
            function calc(baseDurationSeconds) {
                return baseDurationSeconds * 1000 * (duration_multiplier || 0);
            }
        }
    }

    readonly property PersistentProperties colors: colorsObj
    readonly property PersistentProperties styling: stylingObj
}
