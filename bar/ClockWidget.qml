import QtQuick
import QtQuick
import QtQuick.Layouts
import "../services"

Text {
    text: Time.time
    font.bold: true
    color: Config.styling.text0
    font.pixelSize: Math.round(height * 0.8)
    verticalAlignment: Qt.AlignVCenter
}
