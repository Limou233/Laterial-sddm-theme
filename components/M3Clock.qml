import QtQuick
import QtQuick.Effects

Item {
    id: root

    property color textColor: "#FFFFFF"
    property color secondaryTextColor: "#D9FFFFFF"
    property color shadowColor: "#B0000000"
    property bool showDate: true
    property bool compact: false

    implicitWidth: clockColumn.implicitWidth + 24
    implicitHeight: clockColumn.implicitHeight + 14

    function currentTimeText() {
        var now = clockTimer.currentDate
        var hour = now.getHours() % 12
        if (hour === 0) {
            hour = 12
        }
        var minute = now.getMinutes()
        var suffix = now.getHours() >= 12 ? "p.m." : "a.m."
        return hour + ":" + (minute < 10 ? "0" + minute : minute) + " " + suffix
    }

    Timer {
        id: clockTimer
        property date currentDate: new Date()
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            currentDate = new Date()
            root.clockMinuteChanged()
        }
    }

    signal clockMinuteChanged()

    Item {
        id: clockLayer
        anchors.centerIn: parent
        width: clockColumn.implicitWidth
        height: clockColumn.implicitHeight

        Column {
            id: clockColumn
            anchors.centerIn: parent
            spacing: root.compact ? 1 : 3

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.currentTimeText()
                color: root.textColor
                font.family: Qt.application.font.family
                font.pixelSize: root.compact ? 49 : 62
                font.weight: Font.Light
                renderType: Text.NativeRendering
            }

            Text {
                visible: root.showDate
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDate(clockTimer.currentDate, "dddd · MMMM d")
                color: root.secondaryTextColor
                font.family: Qt.application.font.family
                font.pixelSize: root.compact ? 12 : 14
                font.weight: Font.Medium
            }
        }
    }

    MultiEffect {
        anchors.fill: clockLayer
        source: clockLayer
        autoPaddingEnabled: true
        paddingRect: Qt.rect(-24, -24, width + 48, height + 48)
        shadowEnabled: true
        shadowColor: root.shadowColor
        shadowBlur: 0.82
        shadowVerticalOffset: root.compact ? 3 : 5
        shadowHorizontalOffset: 0
        shadowScale: 1.02
    }
}
