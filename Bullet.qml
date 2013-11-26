// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import Box2D 1.0
import VPlay 1.0

EntityBase {
    id: entity
    entityType: "bullet"

    function applyForwardImpulse(speed) {
        var localForward = boxCollider.body.getWorldVector(Qt.point(speed, 0));
        boxCollider.body.applyLinearImpulse(localForward, boxCollider.body.getWorldCenter());
    }

    Component.onCompleted: {
        applyForwardImpulse(1500);
    }

    BoxCollider {
        id: boxCollider
        categories: Box.Category2
        width: 16
        height: 16
        anchors.centerIn: parent
        density: 25
        friction: 0.2
        restitution: 0
        linearDamping: 0
        angularDamping: 0
        body.bullet: true
        body.fixedRotation: true

        fixture.onBeginContact: {
            var fixture = other;
            var body = other.parent;
            var component = other.parent.parent;
            var collidedEntityType = component.owningEntity.entityType;
            console.debug('bullet: contact with: ', collidedEntityType)
            switch (collidedEntityType) {
            case "creeper": {
                hits++;
                health = Math.min(1, health + 0.1);
            }

            case "wall":
            case "steve":
            case "bullet": {
                hidingEffect.running = true;
                boxCollider.body.linearVelocity = Qt.point(0,0);
                applyForwardImpulse(100);
                break;
            }}
        }
    }

    Image {
        id: image
        source: "img/bullet.png"
        anchors.centerIn: parent
        width: boxCollider.width
        height: boxCollider.height
    }

    FireParticles {
        id: fireParticleEffect
    }

    SmokeParticles {
        id: smokeParticleEffect
    }

    SequentialAnimation {
        id: hidingEffect
        running: false
        ScriptAction { script: { fireParticleEffect.start(); pindropSound.play(); } }
        PauseAnimation { duration: 600 }
        ScriptAction { script: { fireParticleEffect.stop(); smokeParticleEffect.start(); } }
        PauseAnimation { duration: 500 }
        onRunningChanged: {
            if (!hidingEffect.running) entity.destroy()
        }
   }
}
