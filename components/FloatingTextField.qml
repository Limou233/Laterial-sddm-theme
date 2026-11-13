import QtQuick
import QtQuick.Controls

TextField {
    id: root

    property string label: ""
    property color fieldBackground: "#282B2A"
    property color fieldText: "#FFFFFF"
    property color labelColor: "#CAC4D0"
    property color outlineColor: "#79747E"
    property color focusColor: "#D0BCFF"
    property bool passwordMode: false
    property bool revealPassword: false
    property bool animationsEnabled: true

    readonly property bool floated: activeFocus || text.length > 0
    onFloatedChanged: borderCanvas.requestPaint()
    onActiveFocusChanged: borderCanvas.requestPaint()
    onWidthChanged: borderCanvas.requestPaint()
    onHeightChanged: borderCanvas.requestPaint()
    onOutlineColorChanged: borderCanvas.requestPaint()
    onFocusColorChanged: borderCanvas.requestPaint()

    implicitHeight: 58
    leftPadding: 17
    rightPadding: 17
    topPadding: 10
    bottomPadding: 2
    color: fieldText
    selectionColor: Qt.rgba(focusColor.r, focusColor.g, focusColor.b, 0.34)
    selectedTextColor: fieldText
    placeholderText: ""
    echoMode: passwordMode && !revealPassword ? TextInput.Password : TextInput.Normal
    passwordCharacter: "*"
    passwordMaskDelay: 0
    selectByMouse: true
    focusPolicy: Qt.StrongFocus

    font.family: Qt.application.font.family
    font.pixelSize: 16

    Accessible.name: label
    Accessible.description: passwordMode ? "密码输入框" : "用户名输入框"

    background: Item {
        Item {
            anchors.fill: parent
            clip: true

            Rectangle {
                anchors.fill: parent
                radius: 15
                color: root.fieldBackground
            }

            Rectangle {
                anchors.fill: parent
                radius: 15
                color: root.focusColor
                opacity: root.hovered && !root.activeFocus ? 0.055 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: root.animationsEnabled ? 120 : 0
                    }
                }
            }
        }

        Canvas {
            id: borderCanvas
            anchors.fill: parent
            antialiasing: true
            renderTarget: Canvas.FramebufferObject

            onPaint: {
                var context = getContext("2d")
                context.reset()

                var lineWidth = root.activeFocus ? 2 : 1
                var left = lineWidth / 2
                var top = lineWidth / 2
                var right = width - lineWidth / 2
                var bottom = height - lineWidth / 2
                var radius = 15

                context.strokeStyle = root.activeFocus
                    ? root.focusColor
                    : Qt.rgba(root.outlineColor.r, root.outlineColor.g,
                              root.outlineColor.b, 0.58)
                context.lineWidth = lineWidth
                context.lineCap = "round"
                context.lineJoin = "round"
                context.beginPath()

                if (root.floated) {
                    var labelOrigin = floatingLabelSlot.mapToItem(borderCanvas, 0, 0)
                    var gapStart = Math.max(left + radius, labelOrigin.x)
                    var gapEnd = Math.min(right - radius,
                        labelOrigin.x + floatingLabelSlot.width)

                    context.moveTo(gapEnd, top)
                    context.lineTo(right - radius, top)
                    context.arc(right - radius, top + radius, radius,
                        -Math.PI / 2, 0, false)
                    context.lineTo(right, bottom - radius)
                    context.arc(right - radius, bottom - radius, radius,
                        0, Math.PI / 2, false)
                    context.lineTo(left + radius, bottom)
                    context.arc(left + radius, bottom - radius, radius,
                        Math.PI / 2, Math.PI, false)
                    context.lineTo(left, top + radius)
                    context.arc(left + radius, top + radius, radius,
                        Math.PI, Math.PI * 1.5, false)
                    context.lineTo(gapStart, top)
                } else {
                    context.moveTo(left + radius, top)
                    context.lineTo(right - radius, top)
                    context.arc(right - radius, top + radius, radius,
                        -Math.PI / 2, 0, false)
                    context.lineTo(right, bottom - radius)
                    context.arc(right - radius, bottom - radius, radius,
                        0, Math.PI / 2, false)
                    context.lineTo(left + radius, bottom)
                    context.arc(left + radius, bottom - radius, radius,
                        Math.PI / 2, Math.PI, false)
                    context.lineTo(left, top + radius)
                    context.arc(left + radius, top + radius, radius,
                        Math.PI, Math.PI * 1.5, false)
                    context.closePath()
                }
                context.stroke()
            }
        }
    }

    Item {
        id: floatingLabelSlot
        z: 3
        width: root.floated
            ? floatingLabel.implicitWidth + 8
            : floatingLabel.implicitWidth
        height: floatingLabel.implicitHeight
        x: root.floated ? 18 : 17
        y: root.floated
            ? -height / 2 + (root.activeFocus ? 1 : 0.5)
            : (root.height - height) / 2
        onXChanged: borderCanvas.requestPaint()
        onWidthChanged: borderCanvas.requestPaint()
        onHeightChanged: borderCanvas.requestPaint()
        onYChanged: borderCanvas.requestPaint()

        Behavior on x {
            NumberAnimation {
                duration: root.animationsEnabled ? 190 : 0
                easing.type: Easing.OutCubic
            }
        }
        Behavior on y {
            NumberAnimation {
                duration: root.animationsEnabled ? 190 : 0
                easing.type: Easing.OutCubic
            }
        }

        Text {
            id: floatingLabel
            anchors.fill: parent
            text: root.label
            enabled: false
            color: root.activeFocus ? root.focusColor : root.labelColor
            font.family: root.font.family
            font.pixelSize: root.floated ? 12 : 16
            font.weight: root.activeFocus ? Font.DemiBold : Font.Normal
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            Behavior on color {
                ColorAnimation {
                    duration: root.animationsEnabled ? 160 : 0
                }
            }
            Behavior on font.pixelSize {
                NumberAnimation {
                    duration: root.animationsEnabled ? 190 : 0
                    easing.type: Easing.OutCubic
                }
            }
        }
    }
}
