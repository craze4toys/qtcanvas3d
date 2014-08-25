import QtQuick 2.2
import QtQuick.Window 2.1
import QtCanvas3D 1.0
import QtQuick.Enterprise.Controls 1.1
import QtQuick.Enterprise.Controls.Styles 1.1
import QtQuick.Layouts 1.1

import "jsonmodels.js" as GLCode

Window {
    visible: true
    width: 1200
    height: 900

    //! [3]
    property int previousY: 0
    property int previousX: 0
    //! [3]

    ColumnLayout {
        anchors.fill: parent
        RowLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Canvas3D {
                id: canvas3d
                Layout.fillHeight: true
                Layout.fillWidth: true
                imageLoader: textureImageLoader
                //! [1]
                property double xRot: 0.0
                property double yRot: 45.0
                property double distance: 2.0
                //! [1]
                property double itemSize: 1.0
                property double lightX: 0.0
                property double lightY: 45.0
                property double lightDistance: 2.0
                property bool animatingLight: false
                property bool animatingCamera: false
                property bool drawWireframe: false

                onInitGL: {
                    GLCode.initGL(canvas3d, textureImageLoader);
                }

                onRenderGL: {
                    GLCode.renderGL(canvas3d);
                }

                //! [0]
                MouseArea {
                    anchors.fill: parent
                    //! [0]
                    //! [2]
                    onMouseXChanged: {
                        // Do not rotate if we don't have previous value
                        if (previousY !== 0)
                            canvas3d.yRot += mouseY - previousY
                        previousY = mouseY
                        // Limit the rotation to -90...90 degrees
                        if (canvas3d.yRot > 90)
                            canvas3d.yRot = 90
                        if (canvas3d.yRot < -90)
                            canvas3d.yRot = -90
                    }
                    onMouseYChanged: {
                        // Do not rotate if we don't have previous value
                        if (previousX !== 0)
                            canvas3d.xRot += mouseX - previousX
                        previousX = mouseX
                        // Wrap the rotation around
                        if (canvas3d.xRot > 180)
                            canvas3d.xRot -= 360
                        if (canvas3d.xRot < -180)
                            canvas3d.xRot += 360
                    }
                    onReleased: {
                        // Reset previous mouse positions to avoid rotation jumping
                        previousX = 0
                        previousY = 0
                    }
                    //! [2]
                    //! [4]
                    onWheel: {
                        canvas3d.distance -= wheel.angleDelta.y / 1000.0
                        // Limit the distance to 0.5...10
                        if (canvas3d.distance < 0.5)
                            canvas3d.distance = 0.5
                        if (canvas3d.distance > 10)
                            canvas3d.distance = 10
                    }
                    //! [4]
                }
            }

            ColumnLayout {
                CircularGauge {
                    minimumValue: -180
                    maximumValue: 180
                    value: canvas3d.xRot
                    style: CircularGaugeStyle {
                        labelStepSize: 30
                        tickmarkStepSize: 15
                        background: Canvas {
                            Text {
                                font.pixelSize: 20
                                text: "x angle: " + angle
                                color: "lightgray"
                                horizontalAlignment: Text.AlignHCenter
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.top: parent.verticalCenter
                                anchors.topMargin: parent.height / 8
                                readonly property int angle: canvas3d.xRot
                            }
                        }
                    }
                }
                CircularGauge {
                    minimumValue: -90
                    maximumValue: 90
                    value: canvas3d.yRot
                    style: CircularGaugeStyle {
                        labelStepSize: 30
                        tickmarkStepSize: 15
                        background: Canvas {
                            Text {
                                font.pixelSize: 20
                                text: "y angle: " + angle
                                color: "lightgray"
                                horizontalAlignment: Text.AlignHCenter
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.top: parent.verticalCenter
                                anchors.topMargin: parent.height / 8
                                readonly property int angle: canvas3d.yRot
                            }
                        }
                    }
                }
                CircularGauge {
                    minimumValue: 0
                    maximumValue: 100
                    value: canvas3d.distance * 10
                    style: CircularGaugeStyle {
                        labelStepSize: 20
                        tickmarkStepSize: 10
                        background: Canvas {
                            Text {
                                font.pixelSize: 20
                                text: "distance: " + distance
                                color: "lightgray"
                                horizontalAlignment: Text.AlignHCenter
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.top: parent.verticalCenter
                                anchors.topMargin: parent.height / 8
                                readonly property int distance: canvas3d.distance * 10
                            }
                        }
                    }
                }
            }
        }
        RowLayout {
            Layout.fillWidth: true
            ToggleButton {
                id: lightButton
                text: "Animate Light"
                onCheckedChanged: canvas3d.animatingLight = checked
            }
            ToggleButton {
                id: cameraButton
                text: "Animate Camera"
                onCheckedChanged: canvas3d.animatingCamera = checked
            }
            ToggleButton {
                id: drawButton
                text: "Wireframe"
                onCheckedChanged: canvas3d.drawWireframe = checked
            }
            DelayButton {
                text: "Reset"
                delay: 1000
                onCheckedChanged: {
                    canvas3d.xRot = 0.0
                    canvas3d.yRot = 45.0
                    canvas3d.distance = 2.0
                    canvas3d.itemSize = 1.0
                    canvas3d.lightX = 0.0
                    canvas3d.lightY = 45.0
                    canvas3d.lightDistance = 2.0
                    lightButton.checked = false
                    cameraButton.checked = false
                    drawButton.checked = false
                    checked = false
                }
            }
            DelayButton {
                text: "Quit"
                delay: 1000
                onCheckedChanged: Qt.quit()
            }
        }
    }

    SequentialAnimation {
        loops: Animation.Infinite
        running: canvas3d.animatingLight
        NumberAnimation {
            target: canvas3d
            property: "lightX"
            from: 0.0
            to: 360.0
            duration: 5000
        }
    }

    SequentialAnimation {
        loops: Animation.Infinite
        running: canvas3d.animatingLight
        NumberAnimation {
            target: canvas3d
            property: "lightY"
            from: 0.0
            to: 90.0
            duration: 10000
        }
        NumberAnimation {
            target: canvas3d
            property: "lightY"
            from: 90.0
            to: 0.0
            duration: 10000
        }
    }

    SequentialAnimation {
        loops: Animation.Infinite
        running: canvas3d.animatingLight
        NumberAnimation {
            target: canvas3d
            property: "lightDistance"
            from: 10.0
            to: 0.5
            duration: 30000
        }
        NumberAnimation {
            target: canvas3d
            property: "lightDistance"
            from: 0.5
            to: 10.0
            duration: 30000
        }
    }

    SequentialAnimation {
        loops: Animation.Infinite
        running: canvas3d.animatingCamera
        NumberAnimation {
            target: canvas3d
            property: "xRot"
            from: -180.0
            to: 180.0
            duration: 5000
            easing.type: Easing.InOutSine
        }
        NumberAnimation {
            target: canvas3d
            property: "xRot"
            from: 180.0
            to: -180.0
            duration: 5000
            easing.type: Easing.InOutSine
        }
    }

    SequentialAnimation {
        loops: Animation.Infinite
        running: canvas3d.animatingCamera
        NumberAnimation {
            target: canvas3d
            property: "yRot"
            from: 0.0
            to: 90.0
            duration: 10000
            easing.type: Easing.InOutSine
        }
        NumberAnimation {
            target: canvas3d
            property: "yRot"
            from: 90.0
            to: 0.0
            duration: 10000
            easing.type: Easing.InOutSine
        }
    }

    SequentialAnimation {
        loops: Animation.Infinite
        running: canvas3d.animatingCamera
        NumberAnimation {
            target: canvas3d
            property: "distance"
            from: 10.0
            to: 0.5
            duration: 30000
            easing.type: Easing.InOutSine
        }
        NumberAnimation {
            target: canvas3d
            property: "distance"
            from: 0.5
            to: 10.0
            duration: 30000
            easing.type: Easing.InOutSine
        }
    }

    TextureImageLoader {
        id: textureImageLoader

        function loadTexture(file) {
            return textureImageLoader.loadImage("qrc:///"+file);
        }

        onImageLoaded: {
            GLCode.textureLoaded(image);
        }

        onImageLoadingFailed: {
            if (GLCode.textureLoadError !== undefined) {
                GLCode.textureLoadError(image);
            }
        }
    }
}
