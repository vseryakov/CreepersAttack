import QtQuick 1.1
import Box2D 1.0
import VPlay 1.0

GameWindow {
    id: window
    width: sceneWidth * 2
    height: sceneHeight * 2
    displayFpsEnabled: false
    property real health: 1
    property int hits: 0
    property real targetX: 0
    property real targetY: 0
    property int sceneWidth: 960
    property int sceneHeight: 640

    Component.onCompleted: {
        entityManager.createMusic()
    }

    BackgroundMusic {
        id: bgMusic
        volume: 0.2
    }

    Scene {
        id: scene
        width: sceneWidth
        height: sceneHeight
        state: 'hide'

        Component {
            id: mouseJoint
            MouseJoint {
                maxForce: 30000
                dampingRatio: 1
                frequencyHz: 2
            }
        }

        MouseArea {
            anchors.fill: parent
            property Body obj: null
            property MouseJoint join: null

            onPressed: {
                var body = physicsWorld.bodyAt(Qt.point(mouseX, mouseY));
                if (body && body.parent.owningEntity.entityType == "steve") {
                    join = mouseJoint.createObject(physicsWorld)
                    join.targetPoint = Qt.point(mouseX, mouseY)
                    join.targetBody = body;
                    join.world = physicsWorld;
                    obj = body;
                }
            }

            onPositionChanged: {
                if (join) {
                    join.targetPoint = Qt.point(mouseX, mouseY)
                    targetX = mouseX
                    targetY = mouseY
                }
            }

            onReleased: {
                if (obj) {
                    obj.parent.owningEntity.fire();
                    obj = null;
                    if (join) join.destroy()
                    entityManager.updateCreepers()
                }
            }
        }

        Item {
            id: level
            anchors.fill: parent

            Sound {
                id: smokeSound
                source: "snd/smoke.mp3"
            }

            Sound {
                id: fireSound
                source: "snd/fire.mp3"
            }

            Sound {
                id: shotgunSound
                source: "snd/shotgun.mp3"
            }

            Sound {
                id: pindropSound
                source: "snd/pindrop.mp3"
            }

            Sound {
                id: missleSound
                source: "snd/fire.mp3"
            }

            Sound {
                id: explodeSound
                source: "snd/explode.mp3"
            }

            Image {
                source: "img/bg.png"
                anchors.fill: parent
            }

            Wall {
                variationType: "top"
                x: 0
                y: 0
                width: scene.width
                height: 1
            }
            Wall {
                variationType: "bottom"
                x: 0
                y: scene.height - 33
                width: scene.width
                height: 1
            }
            Wall {
                variationType: "left"
                x: 0
                y: 0
                width: 1
                height: scene.height
            }
            Wall {
                variationType: "right"
                x: scene.width-1
                y: 0
                width: 1
                height: scene.height
            }

            Rectangle {
                x: 1
                y: scene.height - 32
                width: scene.width-2
                height: 33
                color: "darkgreen"

                Row {
                    anchors { fill: parent; margins: 2 }
                    spacing: 10

                    Image {
                        source: "img/button.png"
                        width: 60
                        height: parent.height

                        Text {
                            color: "black"
                            text: Math.round(health * 100) + "%"
                            font.pixelSize: 14
                            font.family: hudFont.name
                            anchors.centerIn: parent
                        }
                    }

                    Image {
                        source: "img/button.png"
                        width: 60
                        height: parent.height

                        Text {
                            color: "black"
                            text: hits + " Hits"
                            font.pixelSize: 14
                            font.family: hudFont.name
                            anchors.centerIn: parent
                        }
                    }

                    Image {
                        source: "img/button.png"
                        width: 70
                        height: parent.height

                        Text {
                            color: "black"
                            text: "Restart"
                            font.pixelSize: 14
                            font.family: hudFont.name
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            anchors.fill: parent
                            onPressed: {
                                scene.state = 'hide'
                            }
                        }
                    }
                }
            }
        }

        PhysicsWorld {
            id: physicsWorld
            z: 1
            updatesPerSecondForPhysics: 60
            velocityIterations: 5
            positionIterations: 5
        }

        Timer {
            id: timer
            repeat: true
            running: false
            interval: 1000
            onTriggered: {
                entityManager.createCreeper();
                timer.interval = entityManager.randomInt(2000, 5000);
            }
        }

        states: [
                 State {
                     name: ""
                     PropertyChanges { target: scene; opacity: 1 }
                     StateChangeScript {
                         script: {
                             entityManager.createMusic()
                             entityManager.createSteve();
                             timer.start();
                         }
                     }
                 },

                 State {
                     name: "hide"
                     PropertyChanges { target: scene; opacity: 0 }
                     StateChangeScript {
                         script: {
                             timer.stop();
                             entityManager.createMusic()
                             entityManager.removeAllEntities();
                             loading.state = ''
                         }
                     }
                 }
                 ]

        transitions: Transition {
            NumberAnimation { target: loading; duration: 900; property: "opacity"; easing.type: Easing.InOutQuad }
        }
    }

    FontLoader {
      id: jellyFont
      source: "fonts/JellyBelly.ttf"
    }

    FontLoader {
      id: hudFont
      source: "fonts/COOPBL.ttf"
    }

    EntityManager {
        id: entityManager
        entityContainer: level

        function randomInt(min, max) {
            return Math.floor(Math.random() * (max - min + 1)) + min;
        }
        function createCreeper() {
            var x = randomInt(level.width/2, level.width - 32*2);
            var y = randomInt(32*2, level.height - 32*2);
            var num = randomInt(1, 10);
            entityManager.createEntityFromUrlWithProperties(Qt.resolvedUrl("Creeper.qml"), { x: x, y: y, num: num });
        }
        function destroyCreeper(obj) {
            if (!obj) return;
            var idx = items.indexOf(obj.entityId);
            if (idx > -1) items.splice(idx, 1);
            obj.destroy();
        }
        function updateCreepers() {
            var items = getEntityArrayByType('creeper');
            for (var i = 0; i < items.length; i++) {
                items[i].restart();
            }
        }
        function createSteve() {
            hits = 0
            health = 1
            targetX = 32 * 2
            targetY = scene.height/2
            entityManager.createEntityFromUrlWithProperties(Qt.resolvedUrl("Steve.qml"), { x: targetX, y: targetY, num: randomInt(1, 8) });
        }
        function createMusic() {
            bgMusic.stop();
            bgMusic.source = "snd/bg" + entityManager.randomInt(1, 6) + ".mp3";
            bgMusic.play();
        }
    }

    Scene {
        id: loading
        width: sceneWidth
        height: sceneHeight
        focus: true

        Keys.onPressed: {
            loading.state = "hide"
        }

        MouseArea {
            anchors.fill: parent

            onPressed: {
                loading.state = "hide"
            }
        }

        Image {
            source: "img/bg.png"
            anchors.fill: parent
        }

        Text {
            text: "Creepers Attack"
            color: "black"
            font.family: jellyFont.name
            font.pixelSize: 48
            y: parent.height/5
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Column {
            x: 50
            y: 75
            spacing: 10
            anchors.centerIn: parent

            Text {
                text: "You are Steve, a lone warrior against aliens..."
                color: "brown"
                font.family: hudFont.name
                font.pixelSize: 16
            }

            Text {
                text: "Creepers falling from the sky..."
                color: "brown"
                font.family: hudFont.name
                font.pixelSize: 16
            }

            Text {
                text: "But of course Steve can fly!..."
                color: "brown"
                font.family: hudFont.name
                font.pixelSize: 16
            }

            Text {
                text: "Just move Steve around and tap to shoot..."
                color: "brown"
                font.family: hudFont.name
                font.pixelSize: 16
            }

            Text {
                text: "Tab to continue"
                color: "black"
                font.family: jellyFont.name
                font.pixelSize: 28
            }
        }

        states: [
          State {
              name: ""
              PropertyChanges { target: loading; opacity: 1 }
              StateChangeScript {
                  script: {
                      loading.forceActiveFocus()
                  }
              }
          },
          State {
              name: "hide"
              PropertyChanges { target: loading; opacity: 0 }
              StateChangeScript {
                  script: {
                      scene.state = ''
                  }
              }
          }
        ]

        transitions: Transition {
            NumberAnimation { target: loading; duration: 900; property: "opacity"; easing.type: Easing.InOutQuad}
        }
    }
}

