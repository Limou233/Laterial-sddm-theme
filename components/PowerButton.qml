import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: control

    property string text: ""
    property string iconKind: "power"
    property color backgroundColor: "#282B2A"
    property color foregroundColor: "#E6E1E5"
    property color stateColor: "#FFFFFF"
    property bool animationsEnabled: true
    property alias hoverEnabled: pointer.hoverEnabled
    property bool hovered: pointer.containsMouse
    property bool down: pointer.pressed

    signal clicked()

    implicitWidth: 92
    implicitHeight: 68
    activeFocusOnTab: true
    opacity: enabled ? 1.0 : 0.34

    Accessible.role: Accessible.Button
    Accessible.name: text
    Accessible.description: enabled ? "" : "此操作当前不可用"

    function activate() {
        if (enabled) {
            clicked()
        }
    }

    Keys.onReturnPressed: activate()
    Keys.onEnterPressed: activate()
    Keys.onSpacePressed: activate()

    ToolTip.visible: hovered && !enabled
    ToolTip.text: "此操作当前不可用"
    ToolTip.delay: 250

    Rectangle {
        id: fill
        anchors.fill: parent
        radius: 23
        color: control.backgroundColor
    }

    Rectangle {
        anchors.fill: parent
        radius: 23
        color: "transparent"
        border.width: control.activeFocus ? 2 : 1
        border.color: control.activeFocus
            ? control.foregroundColor
            : Qt.rgba(control.foregroundColor.r, control.foregroundColor.g,
                      control.foregroundColor.b, 0.12)
    }

    Rectangle {
        anchors.fill: parent
        radius: 23
        color: control.stateColor
        opacity: !control.enabled ? 0 : (control.down ? 0.14 : (control.hovered ? 0.075 : 0))

        Behavior on opacity {
            NumberAnimation {
                duration: control.animationsEnabled ? 120 : 0
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
            cornerRadius: 23
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 5

        Item { Layout.fillHeight: true }

        M3Icon {
            kind: control.iconKind
            color: control.foregroundColor
            implicitWidth: 25
            implicitHeight: 25
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: control.text
            color: control.foregroundColor
            font.family: Qt.application.font.family
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
        }

        Item { Layout.fillHeight: true }
    }

    MouseArea {
        id: pointer
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: control.enabled ? Qt.LeftButton : Qt.NoButton
        cursorShape: control.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

        onPressed: mouse => {
            control.forceActiveFocus(Qt.MouseFocusReason)
            if (control.enabled) {
                ripple.restart(mouse.x, mouse.y)
            }
        }
        onClicked: control.clicked()
    }

}
