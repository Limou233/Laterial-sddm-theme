import QtQuick

Item {
    id: root

    property color color: "#FFFFFF"
    property bool running: true
    property bool animationsEnabled: true
    implicitWidth: 18
    implicitHeight: 18

    onColorChanged: spinnerCanvas.requestPaint()

    Canvas {
        id: spinnerCanvas
        anchors.fill: parent
        antialiasing: true
        renderTarget: Canvas.FramebufferObject

        onPaint: {
            var context = getContext("2d")
            context.reset()
            var centerX = width / 2
            var centerY = height / 2
            var radius = Math.min(width, height) / 2 - 2
            context.strokeStyle = root.color
            context.globalAlpha = 0.28
            context.lineWidth = 2
            context.lineCap = "round"
            context.beginPath()
            context.arc(centerX, centerY, radius, 0, Math.PI * 2)
            context.stroke()
            context.globalAlpha = 1
            context.beginPath()
            context.arc(centerX, centerY, radius, -Math.PI * 0.5, Math.PI * 0.15)
            context.stroke()
        }
    }

    RotationAnimator on rotation {
        from: 0
        to: 360
        duration: root.animationsEnabled ? 850 : 1
        loops: Animation.Infinite
        running: root.visible && root.running
    }
}
