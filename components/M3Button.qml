import QtQuick
import QtQuick.Layouts

Item {
    id: control

    property string text: ""
    property color backgroundColor: "#6750A4"
    property color foregroundColor: "#FFFFFF"
    property color stateColor: "#FFFFFF"
    property string variant: "filled"
    property string iconKind: ""
    property string trailingIconKind: ""
    property real trailingIconRotation: 0
    property bool loading: false
    property bool animationsEnabled: true
    property bool focusOnPress: true
    property real cornerRadius: height / 2
    property real leftPadding: 22
    property real rightPadding: 22

    property alias hoverEnabled: pointer.hoverEnabled
    property bool hovered: pointer.containsMouse
    property bool down: pointer.pressed

    signal pressStarted()
    signal clicked()

    implicitHeight: 52
    implicitWidth: Math.max(112, contentLayout.implicitWidth + leftPadding + rightPadding)
    activeFocusOnTab: true
    opacity: enabled ? 1.0 : 0.48

    readonly property color resolvedBackground: variant === "text"
        ? "transparent"
        : backgroundColor
    readonly property color resolvedForeground: variant === "text"
        ? backgroundColor
        : foregroundColor

    Accessible.role: Accessible.Button
    Accessible.name: text
    Accessible.description: loading ? "正在登录" : ""

    function activate() {
        if (enabled && !loading) {
            clicked()
        }
    }

    Keys.onReturnPressed: activate()
    Keys.onEnterPressed: activate()
    Keys.onSpacePressed: activate()

    Rectangle {
        id: fill
        anchors.fill: parent
        radius: control.cornerRadius
        color: control.resolvedBackground
    }

    Rectangle {
        anchors.fill: parent
        radius: control.cornerRadius
        color: "transparent"
        border.width: control.activeFocus ? 2 : 0
        border.color: control.variant === "text"
            ? control.resolvedForeground
            : control.foregroundColor
        opacity: 0.68
    }

    Rectangle {
        anchors.fill: parent
        radius: control.cornerRadius
        color: control.stateColor
        opacity: !control.enabled ? 0 : (control.down ? 0.14 : (control.hovered ? 0.08 : 0))

        Behavior on opacity {
            NumberAnimation {
                duration: control.animationsEnabled ? 120 : 0
                easing.type: Easing.OutCubic
            }
        }
    }

    Item {
        anchors.fill: parent
        clip: true

        Ripple {
            id: ripple
            color: control.stateColor
            animationsEnabled: control.animationsEnabled
            cornerRadius: control.cornerRadius
        }
    }

    RowLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.leftMargin: control.leftPadding
        anchors.rightMargin: control.rightPadding
        spacing: 9

        M3Spinner {
            visible: control.loading
            running: control.loading
            color: control.resolvedForeground
            animationsEnabled: control.animationsEnabled
            Layout.preferredWidth: 18
            Layout.preferredHeight: 18
        }

        M3Icon {
            visible: !control.loading && control.iconKind !== ""
            kind: control.iconKind
            color: control.resolvedForeground
            implicitWidth: 19
            implicitHeight: 19
            Layout.preferredWidth: 19
            Layout.preferredHeight: 19
        }

        Text {
            text: control.text
            color: control.resolvedForeground
            font.family: Qt.application.font.family
            font.pixelSize: 15
            font.weight: Font.DemiBold
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: control.iconKind === "" && control.trailingIconKind === ""
                ? Text.AlignHCenter
                : Text.AlignLeft
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
        }

        M3Icon {
            visible: !control.loading && control.trailingIconKind !== ""
            kind: control.trailingIconKind
            color: control.resolvedForeground
            rotation: control.trailingIconRotation
            transformOrigin: Item.Center
            implicitWidth: 18
            implicitHeight: 18
            Layout.preferredWidth: 18
            Layout.preferredHeight: 18

            Behavior on rotation {
                NumberAnimation {
                    duration: control.animationsEnabled ? 190 : 0
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    MouseArea {
        id: pointer
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: control.enabled ? Qt.LeftButton : Qt.NoButton
        cursorShape: control.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

        onPressed: mouse => {
            if (control.focusOnPress) {
                control.forceActiveFocus(Qt.MouseFocusReason)
            }
            if (control.enabled) {
                control.pressStarted()
                ripple.restart(mouse.x, mouse.y)
            }
        }
        onClicked: control.clicked()
    }

}
