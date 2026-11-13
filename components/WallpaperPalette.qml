import QtQuick
import "../js/MaterialPalette.js" as MaterialPalette

Item {
    id: root

    property var imageItem: null
    property string lastSeed: ""
    signal seedExtracted(string seed)

    width: 64
    height: 40
    visible: imageItem !== null
    opacity: 0.001
    z: -1

    function extract() {
        if (!imageItem || imageItem.status !== Image.Ready) {
            return
        }
        sampleCanvas.requestPaint()
    }

    onImageItemChanged: extractionTimer.restart()

    Timer {
        id: extractionTimer
        interval: 80
        repeat: false
        onTriggered: root.extract()
    }

    Connections {
        target: root.imageItem
        function onStatusChanged() {
            if (root.imageItem.status === Image.Ready) {
                extractionTimer.restart()
            }
        }
    }

    Canvas {
        id: sampleCanvas
        anchors.fill: parent
        renderTarget: Canvas.Image
        renderStrategy: Canvas.Cooperative

        onPaint: {
            var context = getContext("2d")
            context.clearRect(0, 0, width, height)

            var image = root.imageItem
            if (!image || image.status !== Image.Ready) {
                return
            }

            var imageWidth = image.sourceSize.width || image.implicitWidth
            var imageHeight = image.sourceSize.height || image.implicitHeight
            if (imageWidth <= 0 || imageHeight <= 0) {
                return
            }

            try {
                context.drawImage(image, 0, 0, imageWidth, imageHeight, 0, 0, width, height)
                var pixels = context.getImageData(0, 0, width, height)
                var seed = MaterialPalette.seedFromPixels(pixels.data, width, height)
                if (seed && seed !== root.lastSeed) {
                    root.lastSeed = seed
                    root.seedExtracted(seed)
                }
            } catch (error) {
                // Keep the Material baseline palette when a remote or unusual
                // image source cannot be read back by Canvas.
            }
        }
    }
}
