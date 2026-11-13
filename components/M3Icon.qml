import QtQuick
import QtQuick.Shapes

Item {
    id: root

    property string kind: "user"
    property color color: "#FFFFFF"
    property real strokeWidth: 1.8

    implicitWidth: 24
    implicitHeight: 24

    readonly property string vectorPath: {
        if (kind === "power") {
            return "M11.29,11.71Q11,11.43 11,11V3q0-0.43 0.29-0.71T12,2t0.71,0.29T13,3v8q0,0.42-0.29,0.71T12,12t-0.71-0.29Zm-2.8,8.58q-1.64-0.71-2.85-1.93T3.71,15.51T3,12q0-1.53 0.5-2.96T4.95,6.4q0.28-0.35 0.7-0.34T6.4,6.4Q6.68,6.68 6.65,7.07T6.38,7.82Q5.7,8.73 5.35,9.8Q5,10.88 5,12q0,2.92 2.04,4.96T12,19t4.96-2.04Q19,14.93 19,12q0-1.15-0.34-2.24T17.6,7.77q-0.25-0.32-0.28-0.71T17.58,6.4q0.3-0.3 0.73-0.31T19,6.4q0.98,1.2 1.49,2.63T21,12q0,1.88-0.71,3.51t-1.93,2.85t-2.85,1.93T12,21T8.49,20.29Z"
        }
        if (kind === "restart") {
            return "M11,20.95q-3.02-0.38-5.01-2.64T4,13q0-1.65 0.65-3.16T6.5,7.2L7.93,8.63Q6.98,9.48 6.49,10.6T6,13q0,2.2 1.4,3.89T11,18.95v2Zm2,0v-2q2.18-0.4 3.59-2.07T18,13q0-2.5-1.75-4.25T12,7H11.93l1.1,1.1l-1.4,1.4L8.13,6l3.5-3.5l1.4,1.4L11.93,5H12q3.35,0 5.68,2.32T20,13q0,3.02-1.99,5.29Q16.03,20.55 13,20.95Z"
        }
        if (kind === "hibernate") {
            return "M12.1,22Q10,22 8.16,21.2q-1.84-0.8-3.2-2.16T2.8,15.84T2,11.9Q2,8.25 4.33,5.46T10.25,2Q9.8,4.47 10.53,6.84t2.5,4.14t4.14,2.5T22,13.75q-0.65,3.6-3.45,5.93T12.1,22Zm0-2q2.2,0 4.07-1.1t2.95-3.02q-2.15-0.2-4.07-1.09T11.6,12.38T9.18,8.92T8.1,4.85Q6.18,5.93 5.09,7.81T4,11.9q0,3.38 2.36,5.74T12.1,20Zm-0.5-7.63Z"
        }
        if (kind === "eye") {
            return "M15.19,14.69q1.31-1.31 1.31-3.19T15.19,8.31T12,7T8.81,8.31T7.5,11.5t1.31,3.19T12,16t3.19-1.31Zm-5.1-1.28Q9.3,12.63 9.3,11.5t0.79-1.91T12,8.8t1.91,0.79q0.79,0.79 0.79,1.91t-0.79,1.91T12,14.2t-1.91-0.79ZM5.35,16.96Q2.35,14.93 1,11.5Q2.35,8.07 5.35,6.04T12,4t6.65,2.04T23,11.5q-1.35,3.42-4.35,5.46T12,19T5.35,16.96ZM12,11.5Zm5.19,4.01q2.36-1.49 3.61-4.01q-1.25-2.53-3.61-4.01T12,6Q9.18,6 6.81,7.49T3.2,11.5q1.25,2.52 3.61,4.01T12,17t5.19-1.49Z"
        }
        if (kind === "eye-off") {
            return "M16.1,13.3l-1.45-1.45q0.22-1.18-0.67-2.2q-0.9-1.02-2.33-0.8L10.2,7.4q0.42-0.2 0.86-0.3T12,7q1.88,0 3.19,1.31T16.5,11.5q0,0.5-0.1,0.94T16.1,13.3Zm3.2,3.15l-1.45-1.4q0.95-0.72 1.69-1.59T20.8,11.5q-1.25-2.53-3.59-4.01T12,6q-0.72,0-1.42,0.1T9.2,6.4L7.65,4.85q1.03-0.43 2.1-0.64T12,4q3.78,0 6.73,2.09T23,11.5q-0.57,1.47-1.51,2.74T19.3,16.45Zm0.5,6.15l-4.2-4.15q-0.88,0.28-1.76,0.41T12,19q-3.78,0-6.73-2.09T1,11.5q0.53-1.33 1.33-2.46T4.15,7L1.4,4.2L2.8,2.8L21.2,21.2l-1.4,1.4ZM5.55,8.4Q4.83,9.05 4.23,9.82T3.2,11.5q1.25,2.52 3.59,4.01T12,17q0.5,0 0.98-0.06t0.97-0.14l-0.9-0.95q-0.28,0.07-0.53,0.11T12,16q-1.88,0-3.19-1.31T7.5,11.5q0-0.28 0.04-0.53t0.11-0.53L5.55,8.4Zm7.98,2.33ZM9.75,12.6Z"
        }
        return ""
    }
    readonly property bool hasVectorIcon: vectorPath !== ""

    onColorChanged: canvas.requestPaint()
    onKindChanged: canvas.requestPaint()
    onStrokeWidthChanged: canvas.requestPaint()

    Shape {
        width: 24
        height: 24
        visible: root.hasVectorIcon
        x: (root.width - 24) / 2
        y: (root.height - 24) / 2
        scale: Math.min(root.width / 24, root.height / 24)

        ShapePath {
            fillColor: root.color
            strokeColor: "transparent"
            PathSvg { path: root.vectorPath }
        }
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        visible: !root.hasVectorIcon
        antialiasing: true
        renderTarget: Canvas.FramebufferObject

        onPaint: {
            var context = getContext("2d")
            context.reset()
            var scaleX = width / 24
            var scaleY = height / 24
            context.scale(scaleX, scaleY)
            context.strokeStyle = root.color
            context.fillStyle = root.color
            context.lineWidth = root.strokeWidth
            context.lineCap = "round"
            context.lineJoin = "round"

            if (root.kind === "user") {
                context.beginPath()
                context.arc(12, 7.4, 3.2, 0, Math.PI * 2)
                context.stroke()
                context.beginPath()
                context.moveTo(5.1, 19.2)
                context.bezierCurveTo(5.8, 15.4, 8.2, 13.3, 12, 13.3)
                context.bezierCurveTo(15.8, 13.3, 18.2, 15.4, 18.9, 19.2)
                context.stroke()
            } else if (root.kind === "lock") {
                context.beginPath()
                context.moveTo(7.0, 10.2)
                context.lineTo(5.0, 10.2)
                context.lineTo(5.0, 20.4)
                context.lineTo(19.0, 20.4)
                context.lineTo(19.0, 10.2)
                context.lineTo(17.0, 10.2)
                context.stroke()
                context.beginPath()
                context.arc(12, 10.4, 4.2, Math.PI, Math.PI * 2)
                context.stroke()
                context.beginPath()
                context.arc(12, 15.2, 1.15, 0, Math.PI * 2)
                context.fill()
            } else if (root.kind === "chevron-down") {
                context.beginPath()
                context.moveTo(6.5, 9.2)
                context.lineTo(12, 14.7)
                context.lineTo(17.5, 9.2)
                context.stroke()
            } else if (root.kind === "check") {
                context.beginPath()
                context.moveTo(5.4, 12.4)
                context.lineTo(10.0, 17.0)
                context.lineTo(18.7, 7.2)
                context.stroke()
            } else if (root.kind === "desktop") {
                context.beginPath()
                context.moveTo(5.0, 5.0)
                context.lineTo(19.0, 5.0)
                context.lineTo(20.5, 6.5)
                context.lineTo(20.5, 15.7)
                context.lineTo(19.0, 17.2)
                context.lineTo(5.0, 17.2)
                context.lineTo(3.5, 15.7)
                context.lineTo(3.5, 6.5)
                context.closePath()
                context.stroke()
                context.beginPath()
                context.moveTo(9.3, 20.0)
                context.lineTo(14.7, 20.0)
                context.moveTo(12, 17.0)
                context.lineTo(12, 20.0)
                context.stroke()
            }
        }
    }
}
