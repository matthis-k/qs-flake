import QtQuick
import QtQuick
import QtQuick.Layouts
import "../services" 1.0

Text {
    text: Time.time
    font.bold: true
    color: Config.styling.text0
}
