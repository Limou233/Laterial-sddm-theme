import QtQuick
import QtQuick.Effects

Item {
    id: root

    property color color: "#40FFFFFF"
    property bool animationsEnabled: true
    property real cornerRadius: Math.min(width, height) / 2
    anchors.fill: parent

    function restart(originX, originY) {
        var farthestX = Math.max(originX, width - originX)
        var farthestY = Math.max(originY, height - originY)
        var radius = Math.sqrt(farthestX * farthestX + farthestY * farthestY)

        ripple.width = radius * 2
        ripple.height = radius * 2
        ripple.radius = radius
        ripple.x = originX - radius
        ripple.y = originY - radius
        ripple.scale = 0.08
        ripple.opacity = 0.20
        rippleAnimation.restart()
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

    Item {
        id: rippleLayer
        anchors.fill: parent
        layer.enabled: true
        layer.effect: MultiEffect {
            maskEnabled: true
            maskSource: maskTexture
        }

        Rectangle {
            id: ripple
            color: root.color
            opacity: 0
            transformOrigin: Item.Center
        }
    }

    ParallelAnimation {
        id: rippleAnimation
        running: false

        NumberAnimation {
            target: ripple
            property: "scale"
            to: 1.0
            duration: root.animationsEnabled ? 420 : 1
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: ripple
            property: "opacity"
            to: 0
            duration: root.animationsEnabled ? 460 : 1
            easing.type: Easing.OutQuad
        }
    }
}
