import QtQuick
import "components"

Item {
    id: root

    width: Screen.width > 0 ? Screen.width : 1600
    height: Screen.height > 0 ? Screen.height : 900

    Greeter {
        id: greeter
        anchors.fill: parent
        configMap: config
        sddmApi: sddm
        userModelRef: userModel
        sessionModelRef: sessionModel
        screenModelRef: screenModel
        themeBaseUrl: Qt.resolvedUrl(".")

        onLoginRequested: (username, password, sessionIndex) => {
            sddm.login(username, password, sessionIndex)
        }
        onPowerOffRequested: sddm.powerOff()
        onRebootRequested: sddm.reboot()
        onHibernateRequested: sddm.hibernate()
    }
}
