import QtQuick

Item {
    id: root

    property var screens: null
    property string source: ""
    property string fallbackSource: ""
    property string backgroundType: "image"
    property string fillModeName: "cover"
    property color fallbackColor: "#191C1B"
    property color scrimColor: "#40000000"
    property var sampleImage: null
    property alias wallpaperLayerItem: wallpaperLayer
    property bool usingFallback: false

    readonly property int resolvedFillMode: {
        if (fillModeName === "contain")
            return Image.PreserveAspectFit
        if (fillModeName === "stretch")
            return Image.Stretch
        return Image.PreserveAspectCrop
    }

    onSourceChanged: usingFallback = false
    onFallbackSourceChanged: usingFallback = false

    Rectangle {
        anchors.fill: parent
        color: root.fallbackColor
    }

    Item {
        id: wallpaperLayer
        anchors.fill: parent

        Repeater {
            model: root.screens && root.screens.count !== undefined ? root.screens : 1
            delegate: Image {
                id: wallpaperImage
                readonly property var screenInfo: typeof model !== "undefined" && model
                    && model.geometry !== undefined ? model.geometry : null

                x: screenInfo ? screenInfo.x : 0
                y: screenInfo ? screenInfo.y : 0
                width: screenInfo ? screenInfo.width : root.width
                height: screenInfo ? screenInfo.height : root.height
                source: root.backgroundType === "image"
                    ? (root.usingFallback ? root.fallbackSource : root.source)
                    : ""
                fillMode: root.resolvedFillMode
                sourceSize.width: Math.max(1, Math.round(width))
                sourceSize.height: Math.max(1, Math.round(height))
                asynchronous: true
                cache: true
                smooth: true
                visible: root.backgroundType === "image"

                onStatusChanged: {
                    if (status === Image.Error && !root.usingFallback
                            && root.fallbackSource !== "") {
                        root.usingFallback = true
                    }
                }

                Component.onCompleted: {
                    if (index === 0) {
                        root.sampleImage = wallpaperImage
                    }
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: root.scrimColor
        opacity: 0.55
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#22000000" }
            GradientStop { position: 0.48; color: "#00000000" }
            GradientStop { position: 1.0; color: "#44000000" }
        }
    }

}
