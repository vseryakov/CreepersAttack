import QtQuick 1.1
import Box2D 1.0
import VPlay 1.0

EntityBase {
    id: entity
    entityType: "steve"
    property int num: 1
    transformOrigin: Item.TopLeft

    Keys.onSpacePressed: {
        event.accepted = true;
        fire();
    }

    function fire() {
        var imagePointInWorldCoordinates = mapToItem(level, image.imagePoints[0].x, image.imagePoints[0].y);
        entityManager.createEntityFromUrlWithProperties(Qt.resolvedUrl("Bullet.qml"), { x: imagePointInWorldCoordinates.x, y: imagePointInWorldCoordinates.y, rotation: entity.rotation });
    }

    function end() {
        smokeParticleEffect.start();
        smokeSound.play();
        timer.start()
    }

    Component {
        id: mouseJoint
        MouseJoint {
            maxForce: 30000
            dampingRatio: 1
            frequencyHz: 2
        }
    }

    Image {
        id: image
        source: "img/steve" + num + ".png"
        anchors.centerIn: parent
        width: boxCollider.width
        height: boxCollider.height
        // Start bullet from the front of the image
        property list<Item> imagePoints: [ Item { x: image.width/2 + 32 } ]
    }

    BoxCollider {
        id: boxCollider
        categories: Box.Category1
        width: 128
        height: 128
        anchors.centerIn: parent
        density: 20
        friction: 0.4
        restitution: 0.5
        body.bullet: true
        body.linearDamping: 10
        body.angularDamping: 15

        fixture.onBeginContact: {
            var fixture = other;
            var body = other.parent;
            var component = other.parent.parent;
            var collidedEntityType = component.owningEntity.entityType;
            console.log('steve: contact with: ', collidedEntityType)
            switch (collidedEntityType) {
            case "bullet": {
                health = Math.max(0, health - 0.05)
                if (health <= 0) entity.end();
                break;
            }

            case "creeper": {
                health = Math.max(0, health - 0.1)
                if (health <= 0) entity.end();
                break;
            }}
            entity.opacity = health + 0.4
        }
    }

    SmokeParticles {
        id: smokeParticleEffect
    }

    Timer {
        id: timer
        running: false
        interval: smokeParticleEffect.duration*1000+100
        onTriggered: {
            entity.destroy()
            scene.state = 'hide'
        }
    }
}
