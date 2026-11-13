import QtQuick
import QtQuick.Controls

Item {
    id: root

    property var model: null
    property int currentIndex: -1
    property color backgroundColor: "#333735"
    property color popupBackgroundColor: backgroundColor
    property color textColor: "#E6E1E5"
    property color accentColor: "#D0BCFF"
    property color stateColor: "#FFFFFF"
    property bool animationsEnabled: true
    property bool popupIntentOpen: false
    property bool arrowExpanded: false
    property bool suppressNextClick: false
    property Item nextFocusItem: null
    property Item previousFocusItem: null
    property int highlightedIndex: -1
    property alias buttonControl: sessionButton
    property alias popupControl: popup
    readonly property bool popupOpened: popup.opened
    signal sessionChanged(int index)

    readonly property int sessionCount: model && model.count !== undefined ? model.count : 0
    readonly property string currentName: {
        var entry = sessions.objectAt(currentIndex)
        return entry ? entry.sessionName : ""
    }

    implicitHeight: sessionButton.implicitHeight

    function ensureSelection() {
        if (sessionCount <= 0) {
            currentIndex = -1
            return
        }

        var lastIndex = model && model.lastIndex !== undefined ? model.lastIndex : -1
        if (currentIndex < 0 || currentIndex >= sessionCount) {
            currentIndex = lastIndex >= 0 && lastIndex < sessionCount ? lastIndex : 0
        }
    }

    function closePopup() {
        popupIntentOpen = false
        arrowExpanded = false
        suppressNextClick = false
        popup.close()
    }

    function openPopup() {
        if (sessionCount <= 0) {
            return
        }
        ensureSelection()
        highlightedIndex = Math.max(0, currentIndex)
        popupIntentOpen = true
        arrowExpanded = true
        popup.open()
    }

    function selectIndex(index) {
        if (index < 0 || index >= sessionCount) {
            return
        }
        currentIndex = index
        highlightedIndex = index
        popupIntentOpen = false
        arrowExpanded = false
        suppressNextClick = false
        popup.close()
        sessionButton.forceActiveFocus(Qt.TabFocusReason)
        root.sessionChanged(currentIndex)
    }

    Component.onCompleted: Qt.callLater(ensureSelection)
    onSessionCountChanged: Qt.callLater(ensureSelection)

    Instantiator {
        id: sessions
        model: root.model
        delegate: QtObject {
            property int sessionIndex: model.index
            property string sessionName: model.name
        }
    }

    M3Button {
        id: sessionButton
        anchors.fill: parent

        text: root.currentName !== "" ? root.currentName : "无可用桌面环境"
        iconKind: "desktop"
        trailingIconKind: "chevron-down"
        trailingIconRotation: root.arrowExpanded ? 180 : 0
        backgroundColor: root.backgroundColor
        foregroundColor: root.textColor
        stateColor: root.stateColor
        animationsEnabled: root.animationsEnabled
        enabled: root.sessionCount > 0
        focusPolicy: Qt.StrongFocus
        Accessible.name: "桌面环境：" + text
        KeyNavigation.tab: root.nextFocusItem
        KeyNavigation.backtab: root.previousFocusItem
        onPressStarted: {
            if (root.popupOpened || root.popupIntentOpen || root.arrowExpanded) {
                root.suppressNextClick = true
            }
        }
        onClicked: {
            if (root.suppressNextClick) {
                root.suppressNextClick = false
                root.popupIntentOpen = false
                root.arrowExpanded = false
                popup.close()
                return
            }
            if (root.popupIntentOpen) {
                root.popupIntentOpen = false
                root.arrowExpanded = false
                popup.close()
                return
            }
            root.popupIntentOpen = true
            root.arrowExpanded = true
            root.openPopup()
        }
    }

    Popup {
        id: popup
        parent: sessionButton
        x: 0
        y: -height - 8
        width: sessionButton.width
        height: Math.min(246, Math.max(54, sessionList.contentHeight + 16))
        padding: 8
        modal: false
        focus: true
        transformOrigin: Item.Bottom
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        enter: Transition {
            ParallelAnimation {
                NumberAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: root.animationsEnabled ? 160 : 0
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    property: "scale"
                    from: 0.94
                    to: 1
                    duration: root.animationsEnabled ? 210 : 0
                    easing.type: Easing.OutCubic
                }
            }
        }
        exit: Transition {
            ParallelAnimation {
                NumberAnimation {
                    property: "opacity"
                    from: 1
                    to: 0
                    duration: root.animationsEnabled ? 120 : 0
                    easing.type: Easing.InCubic
                }
                NumberAnimation {
                    property: "scale"
                    from: 1
                    to: 0.97
                    duration: root.animationsEnabled ? 140 : 0
                    easing.type: Easing.InCubic
                }
            }
        }
        onOpened: {
            root.popupIntentOpen = true
            closeGuard.stop()
            Qt.callLater(function () {
                sessionList.currentIndex = root.highlightedIndex
                sessionList.positionViewAtIndex(root.highlightedIndex, ListView.Center)
                sessionList.forceActiveFocus(Qt.PopupFocusReason)
            })
        }
        onClosed: {
            root.arrowExpanded = false
            closeGuard.restart()
        }

        background: Rectangle {
            radius: 22
            color: Qt.rgba(root.popupBackgroundColor.r,
                           root.popupBackgroundColor.g,
                           root.popupBackgroundColor.b,
                           1.0)
            border.width: 1
            border.color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.20)
        }

        contentItem: ListView {
            id: sessionList
            clip: true
            spacing: 2
            model: root.model
            boundsBehavior: Flickable.StopAtBounds
            focus: true

            ScrollBar.vertical: ScrollBar {
                id: sessionScrollBar
                policy: ScrollBar.AsNeeded
                width: 6

                background: Item {}
                contentItem: Rectangle {
                    implicitWidth: 5
                    radius: 2.5
                    color: root.accentColor
                    opacity: sessionScrollBar.active ? 0.58 : 0.30
                }
            }

            Keys.onUpPressed: event => {
                root.highlightedIndex = Math.max(0, root.highlightedIndex - 1)
                positionViewAtIndex(root.highlightedIndex, ListView.Contain)
                event.accepted = true
            }
            Keys.onDownPressed: event => {
                root.highlightedIndex = Math.min(root.sessionCount - 1, root.highlightedIndex + 1)
                positionViewAtIndex(root.highlightedIndex, ListView.Contain)
                event.accepted = true
            }
            Keys.onReturnPressed: event => {
                root.selectIndex(root.highlightedIndex)
                event.accepted = true
            }
            Keys.onEnterPressed: event => {
                root.selectIndex(root.highlightedIndex)
                event.accepted = true
            }
            Keys.onSpacePressed: event => {
                root.selectIndex(root.highlightedIndex)
                event.accepted = true
            }
            Keys.onEscapePressed: event => {
                root.closePopup()
                sessionButton.forceActiveFocus(Qt.TabFocusReason)
                event.accepted = true
            }
            Keys.onPressed: event => {
                if (event.key === Qt.Key_Home) {
                    root.highlightedIndex = 0
                    positionViewAtIndex(0, ListView.Contain)
                    event.accepted = true
                } else if (event.key === Qt.Key_End) {
                    root.highlightedIndex = root.sessionCount - 1
                    positionViewAtIndex(root.highlightedIndex, ListView.Contain)
                    event.accepted = true
                }
            }

            delegate: Item {
                id: itemDelegate
                width: sessionList.width
                height: 48
                Accessible.role: Accessible.ListItem
                Accessible.name: model.name
                Accessible.selected: model.index === root.currentIndex

                Rectangle {
                    anchors.fill: parent
                    radius: 14
                    color: root.accentColor
                    opacity: itemMouse.containsMouse || model.index === root.highlightedIndex
                        ? 0.10
                        : (model.index === root.currentIndex ? 0.06 : 0)

                    Behavior on opacity {
                        NumberAnimation {
                            duration: root.animationsEnabled ? 110 : 0
                        }
                    }
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 14
                    anchors.right: selectedMark.left
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: model.name || "未命名桌面环境"
                    color: root.textColor
                    font.family: Qt.application.font.family
                    font.pixelSize: 15
                    font.weight: model.index === root.currentIndex ? Font.DemiBold : Font.Normal
                    elide: Text.ElideRight
                }

                M3Icon {
                    id: selectedMark
                    visible: model.index === root.currentIndex
                    anchors.right: parent.right
                    anchors.rightMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    kind: "check"
                    color: root.accentColor
                    implicitWidth: 19
                    implicitHeight: 19
                }

                MouseArea {
                    id: itemMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.selectIndex(model.index)
                }
            }
        }
    }

    Timer {
        id: closeGuard
        interval: 260
        repeat: false
        onTriggered: root.popupIntentOpen = false
    }
}
