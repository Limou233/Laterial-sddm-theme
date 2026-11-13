import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

Item {
    id: root

    property var configMap: ({})
    property var sddmApi: null
    property var userModelRef: null
    property var sessionModelRef: null
    property var screenModelRef: null
    property url themeBaseUrl: Qt.resolvedUrl("..")

    signal loginRequested(string username, string password, int sessionIndex)
    signal powerOffRequested()
    signal rebootRequested()
    signal hibernateRequested()

    readonly property bool compact: width < 620 || height < 700
    readonly property int panelWidth: Math.max(0, Math.min(compact ? 430 : 470,
        width - (compact ? 20 : 64)))
    readonly property real panelPadding: compact ? 20 : 30
    readonly property bool reducedMotion: !theme.animationsEnabled
    property string message: ""
    property bool messageIsError: false
    property bool busy: false
    property bool loginSucceeded: false
    property alias usernameInput: userNameField
    property alias passwordInput: passwordField
    property alias revealPasswordControl: revealPasswordButton
    property alias loginButtonControl: loginButton
    property alias sessionSelectorControl: sessionSelector
    property alias shutdownButtonControl: powerShutdownButton
    property alias rebootButtonControl: powerRebootButton
    property alias hibernateButtonControl: powerHibernateButton
    property alias panelControl: panel
    property alias clockControl: clock

    function normalizedBackgroundUrl(value) {
        var path = String(value || "").trim()
        if (path === "") {
            path = "assets/default-wallpaper.png"
        }
        if (path.indexOf("file:") === 0 || path.indexOf("qrc:") === 0
                || path.indexOf("http:") === 0 || path.indexOf("https:") === 0) {
            return path
        }
        if (path.charAt(0) === "/") {
            return Qt.resolvedUrl(path)
        }
        return String(themeBaseUrl) + path
    }

    function legacyBackgroundUrl(value) {
        var path = String(value || "").trim()
        return path.charAt(0) === "@"
            ? normalizedBackgroundUrl(path.substring(1))
            : ""
    }

    function preferredUserName() {
        if (theme.defaultUserName !== "") {
            return theme.defaultUserName
        }
        if (userModelRef && userModelRef.lastUser !== undefined) {
            return String(userModelRef.lastUser || "")
        }
        return ""
    }

    function setInitialUser() {
        if (userNameField.text.length === 0) {
            userNameField.text = preferredUserName()
        }
    }

    function focusLoginField() {
        if (userNameField.text.length > 0) {
            passwordField.forceActiveFocus(Qt.TabFocusReason)
        } else {
            userNameField.forceActiveFocus(Qt.TabFocusReason)
        }
    }

    function submitLogin() {
        if (busy) {
            return
        }
        if (userNameField.text.length === 0) {
            message = "请输入用户名"
            messageIsError = true
            userNameField.forceActiveFocus()
            return
        }
        message = ""
        busy = true
        loginButton.forceActiveFocus()
        var selectedSession = sessionSelector.currentIndex
        if (selectedSession < 0 && sessionSelector.sessionCount > 0) {
            selectedSession = Math.max(0, sessionSelector.model.lastIndex)
        }
        loginRequested(userNameField.text, passwordField.text, selectedSession)
    }

    function resetTransientState() {
        sessionSelector.closePopup()
        passwordRevealed = false
        message = ""
        messageIsError = false
        root.forceActiveFocus(Qt.OtherFocusReason)
    }

    property bool passwordRevealed: false

    Theme {
        id: theme
        sourceConfig: root.configMap
        sampledSeedHex: wallpaperPalette.lastSeed !== ""
            ? wallpaperPalette.lastSeed
            : "#6750A4"
    }

    BlurredWallpaper {
        id: backdrop
        anchors.fill: parent
        screens: root.screenModelRef
        source: root.normalizedBackgroundUrl(theme.backgroundValue)
        fallbackSource: root.legacyBackgroundUrl(theme.backgroundValue)
        backgroundType: theme.backgroundType
        fillModeName: theme.backgroundFillMode
        fallbackColor: theme.surface
        scrimColor: theme.wallpaperScrim
    }

    WallpaperPalette {
        id: wallpaperPalette
        imageItem: backdrop.sampleImage
        onSeedExtracted: seed => lastSeed = seed
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onPressed: root.forceActiveFocus(Qt.MouseFocusReason)
    }

    Item {
        id: panel
        anchors.centerIn: parent
        width: root.panelWidth
        height: Math.min(
            root.height - (theme.showClock ? (root.compact ? 184 : 164) : 24),
            contentLayout.implicitHeight + root.panelPadding * 2
        )
        opacity: 0
        scale: 0.92
        transform: Translate { id: shakeTransform }

        PanelBackdrop {
            id: panelBackdrop
            anchors.fill: parent
            sourceItem: backdrop.wallpaperLayerItem
            sourceRect: Qt.rect(panel.x, panel.y, panel.width, panel.height)
            cornerRadius: root.compact ? 28 : 34
            blurStrength: theme.panelBlurStrength
            effectEnabled: theme.blurRequested
                && GraphicsInfo.api !== GraphicsInfo.Software
        }

        Rectangle {
            id: panelSurface
            anchors.fill: parent
            radius: root.compact ? 28 : 34
            color: theme.dialogSurface
            border.width: 1
            border.color: theme.dialogOutline
            layer.enabled: true
            layer.effect: MultiEffect {
                autoPaddingEnabled: true
                shadowEnabled: true
                shadowColor: theme.dialogShadow
                shadowBlur: 0.92
                shadowOpacity: 0.54
                shadowVerticalOffset: root.compact ? 8 : 12
                shadowHorizontalOffset: 0
                shadowScale: 1.0
            }

            Rectangle {
                anchors.fill: parent
                anchors.margins: 1
                radius: parent.radius - 1
                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: Qt.rgba(1, 1, 1, theme.darkScheme ? 0.045 : 0.12)
                    }
                    GradientStop {
                        position: 0.42
                        color: "transparent"
                    }
                    GradientStop {
                        position: 1.0
                        color: Qt.rgba(0, 0, 0, theme.darkScheme ? 0.055 : 0.025)
                    }
                }
            }
        }

        ColumnLayout {
            id: contentLayout
            anchors.fill: parent
            anchors.margins: root.panelPadding
            spacing: root.compact ? 9 : 13

            FloatingTextField {
                id: userNameField
                objectName: "userNameField"
                Layout.fillWidth: true
                Layout.preferredHeight: root.compact ? 52 : 58
                label: "用户名"
                fieldBackground: theme.inputBackground
                fieldText: theme.inputText
                labelColor: theme.inputLabel
                outlineColor: theme.inputOutline
                focusColor: theme.inputFocus
                animationsEnabled: theme.animationsEnabled
                KeyNavigation.tab: passwordField
                KeyNavigation.backtab: powerHibernateButton

                onTextEdited: {
                    if (!root.busy) {
                        root.message = ""
                        root.messageIsError = false
                    }
                }
                Keys.onReturnPressed: passwordField.forceActiveFocus(Qt.TabFocusReason)
                Keys.onEnterPressed: passwordField.forceActiveFocus(Qt.TabFocusReason)
                Keys.onEscapePressed: {
                    root.resetTransientState()
                    event.accepted = true
                }
            }

            FloatingTextField {
                id: passwordField
                objectName: "passwordField"
                Layout.fillWidth: true
                Layout.preferredHeight: root.compact ? 52 : 58
                label: "密码"
                passwordMode: true
                revealPassword: root.passwordRevealed
                fieldBackground: theme.inputBackground
                fieldText: theme.inputText
                labelColor: theme.inputLabel
                outlineColor: theme.inputOutline
                focusColor: theme.inputFocus
                animationsEnabled: theme.animationsEnabled
                KeyNavigation.tab: revealPasswordButton
                KeyNavigation.backtab: userNameField

                onTextEdited: {
                    if (!root.busy) {
                        root.message = ""
                        root.messageIsError = false
                    }
                }
                Keys.onReturnPressed: root.submitLogin()
                Keys.onEnterPressed: root.submitLogin()
                Keys.onEscapePressed: {
                    root.resetTransientState()
                    event.accepted = true
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Layout.topMargin: -2

                M3Button {
                    id: revealPasswordButton
                    objectName: "revealPasswordButton"
                    variant: "text"
                    text: root.passwordRevealed ? "隐藏密码" : "显示密码"
                    iconKind: root.passwordRevealed ? "eye-off" : "eye"
                    backgroundColor: theme.revealText
                    foregroundColor: theme.revealText
                    stateColor: theme.revealText
                    animationsEnabled: theme.animationsEnabled
                    focusOnPress: false
                    implicitHeight: 34
                    implicitWidth: 118
                    leftPadding: 10
                    rightPadding: 10
                    KeyNavigation.tab: loginButton
                    KeyNavigation.backtab: passwordField
                    Accessible.description: "切换密码是否以明文显示"
                    onClicked: {
                        root.passwordRevealed = !root.passwordRevealed
                        passwordField.forceActiveFocus(Qt.TabFocusReason)
                    }
                }

                Item { Layout.fillWidth: true }
            }

            Text {
                Layout.fillWidth: true
                Layout.preferredHeight: 21
                text: {
                    if (root.busy) {
                        return "正在进行安全验证…"
                    }
                    if (root.message !== "") {
                        return root.message
                    }
                    if (userNameField.text.length === 0) {
                        return "请输入用户名"
                    }
                    return "按 Enter 登录"
                }
                color: root.message !== "" && root.messageIsError
                    ? theme.errorText
                    : theme.surfaceVariantForeground
                font.family: Qt.application.font.family
                font.pixelSize: 12
                font.weight: root.message !== "" ? Font.DemiBold : Font.Normal
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            M3Button {
                id: loginButton
                objectName: "loginButton"
                Layout.fillWidth: true
                Layout.preferredHeight: root.compact ? 48 : 52
                text: root.busy ? "正在登录…" : "登录"
                loading: root.busy
                backgroundColor: theme.loginBackground
                foregroundColor: theme.loginText
                stateColor: theme.loginText
                animationsEnabled: theme.animationsEnabled
                enabled: !root.busy
                    && userNameField.text.length > 0
                KeyNavigation.tab: sessionSelector
                KeyNavigation.backtab: revealPasswordButton
                onClicked: root.submitLogin()
            }

            SessionSelector {
                id: sessionSelector
                objectName: "sessionSelector"
                Layout.fillWidth: true
                Layout.preferredHeight: root.compact ? 48 : 52
                model: root.sessionModelRef
                backgroundColor: theme.sessionBackground
                popupBackgroundColor: theme.sessionPopupBackground
                textColor: theme.sessionText
                accentColor: theme.primary
                stateColor: theme.sessionText
                animationsEnabled: theme.animationsEnabled
                nextFocusItem: powerShutdownButton
                previousFocusItem: loginButton

                Component.onCompleted: ensureSelection()
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.topMargin: root.compact ? 1 : 2
                Layout.bottomMargin: root.compact ? 1 : 2
                implicitHeight: 1
                color: Qt.rgba(theme.outline.r, theme.outline.g, theme.outline.b, 0.27)
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: root.compact ? 60 : 68
                spacing: root.compact ? 5 : 9

                Item { Layout.fillWidth: true }

                PowerButton {
                    id: powerShutdownButton
                    objectName: "powerShutdownButton"
                    text: "关机"
                    iconKind: "power"
                    enabled: root.sddmApi && root.sddmApi.canPowerOff === true && !root.busy
                    backgroundColor: theme.powerBackground
                    foregroundColor: theme.powerText
                    stateColor: theme.powerText
                    animationsEnabled: theme.animationsEnabled
                    Layout.preferredWidth: root.compact ? 82 : 92
                    Layout.preferredHeight: root.compact ? 60 : 68
                    KeyNavigation.tab: powerRebootButton
                    KeyNavigation.backtab: sessionSelector
                    onClicked: root.powerOffRequested()
                }

                PowerButton {
                    id: powerRebootButton
                    objectName: "powerRebootButton"
                    text: "重启"
                    iconKind: "restart"
                    enabled: root.sddmApi && root.sddmApi.canReboot === true && !root.busy
                    backgroundColor: theme.powerBackground
                    foregroundColor: theme.powerText
                    stateColor: theme.powerText
                    animationsEnabled: theme.animationsEnabled
                    Layout.preferredWidth: root.compact ? 82 : 92
                    Layout.preferredHeight: root.compact ? 60 : 68
                    KeyNavigation.tab: powerHibernateButton
                    KeyNavigation.backtab: powerShutdownButton
                    onClicked: root.rebootRequested()
                }

                PowerButton {
                    id: powerHibernateButton
                    objectName: "powerHibernateButton"
                    text: "休眠"
                    iconKind: "hibernate"
                    enabled: root.sddmApi && root.sddmApi.canHibernate === true && !root.busy
                    backgroundColor: theme.powerBackground
                    foregroundColor: theme.powerText
                    stateColor: theme.powerText
                    animationsEnabled: theme.animationsEnabled
                    Layout.preferredWidth: root.compact ? 82 : 92
                    Layout.preferredHeight: root.compact ? 60 : 68
                    KeyNavigation.tab: userNameField
                    KeyNavigation.backtab: powerRebootButton
                    onClicked: root.hibernateRequested()
                }

                Item { Layout.fillWidth: true }
            }

        }
    }

    Connections {
        target: backdrop.sampleImage
        function onStatusChanged() {
            if (backdrop.sampleImage && backdrop.sampleImage.status === Image.Ready) {
                panelBackdrop.scheduleUpdate()
            }
        }
    }

    onWidthChanged: panelBackdrop.scheduleUpdate()
    onHeightChanged: panelBackdrop.scheduleUpdate()

    M3Clock {
        id: clock
        anchors.horizontalCenter: panel.horizontalCenter
        anchors.bottom: panel.top
        anchors.bottomMargin: root.compact ? 12 : 20
        visible: theme.showClock
        textColor: theme.clockText
        secondaryTextColor: theme.clockSecondaryText
        compact: root.compact
    }

    Connections {
        target: root.sddmApi

        function onLoginFailed() {
            root.busy = false
            root.message = "用户名或密码不正确"
            root.messageIsError = true
            passwordField.text = ""
            root.passwordRevealed = false
            passwordField.forceActiveFocus(Qt.OtherFocusReason)
            if (theme.animationsEnabled) {
                rejectAnimation.restart()
            }
        }

        function onLoginSucceeded() {
            root.busy = false
            root.loginSucceeded = true
            panel.opacity = 0
            clock.opacity = 0
        }
    }

    ParallelAnimation {
        id: entranceAnimation
        running: false

        SpringAnimation {
            target: panel
            property: "scale"
            to: 1.0
            spring: 4.2
            damping: 0.74
            epsilon: 0.001
        }

        NumberAnimation {
            target: panel
            property: "opacity"
            to: 1.0
            duration: root.reducedMotion ? 0 : 260
            easing.type: Easing.OutCubic
        }
    }

    SequentialAnimation {
        id: rejectAnimation
        running: false

        NumberAnimation { target: shakeTransform; property: "x"; to: -8; duration: 52 }
        NumberAnimation { target: shakeTransform; property: "x"; to: 8; duration: 72 }
        NumberAnimation { target: shakeTransform; property: "x"; to: -5; duration: 64 }
        NumberAnimation { target: shakeTransform; property: "x"; to: 4; duration: 58 }
        NumberAnimation { target: shakeTransform; property: "x"; to: 0; duration: 70 }
    }

    Timer {
        interval: 230
        running: true
        repeat: false
        onTriggered: {
            root.setInitialUser()
            root.focusLoginField()
            if (root.reducedMotion) {
                panel.scale = 1
                panel.opacity = 1
            } else {
                entranceAnimation.start()
            }
        }
    }

    Keys.onEscapePressed: {
        root.resetTransientState()
        event.accepted = true
    }
}
