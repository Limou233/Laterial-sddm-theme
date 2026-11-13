import QtQuick
import QtQuick.Effects

Item {
    id: root

    property Item sourceItem: null
    property rect sourceRect: Qt.rect(0, 0, width, height)
    property real cornerRadius: 34
    property real blurStrength: 0.8
    property bool effectEnabled: true

    function scheduleUpdate() {
        if (effectEnabled) {
            captureTimer.restart()
        }
    }

    onWidthChanged: scheduleUpdate()
    onHeightChanged: scheduleUpdate()
    onSourceRectChanged: scheduleUpdate()
    onSourceItemChanged: scheduleUpdate()
    onEffectEnabledChanged: scheduleUpdate()

    ShaderEffectSource {
        id: wallpaperCapture
        anchors.fill: parent
        sourceItem: root.sourceItem
        sourceRect: root.sourceRect
        textureSize: Qt.size(
            Math.max(1, Math.round(width)),
            Math.max(1, Math.round(height))
        )
        hideSource: false
        live: false
        recursive: false
        smooth: true
        visible: false
    }

    Item {
        id: maskHost
        anchors.fill: parent

        Rectangle {
            id: maskShape
            anchors.fill: parent
            radius: root.cornerRadius
            color: "#FFFFFF"
        }

        ShaderEffectSource {
            id: maskTexture
            anchors.fill: parent
            sourceItem: maskShape
            hideSource: true
            live: true
            recursive: true
            visible: false
        }
    }

    MultiEffect {
        anchors.fill: parent
        visible: root.effectEnabled && root.sourceItem !== null
        source: wallpaperCapture
        autoPaddingEnabled: false
        blurEnabled: true
        blurMax: 80
        blur: root.blurStrength
        maskEnabled: true
        maskSource: maskTexture
    }

    Timer {
        id: captureTimer
        interval: 120
        repeat: false
        onTriggered: wallpaperCapture.scheduleUpdate()
    }

    Timer {
        interval: 320
        running: true
        repeat: false
        onTriggered: wallpaperCapture.scheduleUpdate()
    }
}
