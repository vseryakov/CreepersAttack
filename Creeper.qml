import QtQuick 1.1
import Box2D 1.0
import VPlay 1.0

EntityBase {
    id: entity
    entityType: "creeper"
    property int num: 1

    function restart(x, y) {
        moveEffect.running = false;
        moveEffect.running = true;
    }

    Component.onCompleted: {
        appearEffect.running = true;
        soundEffect.play()
    }

    BoxCollider {
        id: boxCollider
        categories: Box.Category3
        collidesWith: Box.Category1 | Box.Category2  | Box.Category4
        width: sprite.width
        height: sprite.height
        anchors.centerIn: parent
        fixture.friction: 0.6
        fixture.restitution: 0.5
        fixture.density: 1000

        fixture.onBeginContact: {
            if (hideEffect.running || explodeEffect.running) return;
            var fixture = other;
            var body = other.parent;
            var component = other.parent.parent;
            var collidedEntityType = component.owningEntity.entityType;
            var collidedVariationType = component.owningEntity.variationType;
            console.debug('creeper: contact with: ', collidedEntityType, collidedVariationType)
            switch (collidedEntityType) {
            case "wall":
                hideEffect.running = true;
                console.log("hit the wall")
                break;

            case "bullet": {
                moveEffect.running = false;
                explodeEffect.running = true;
                break;
            }}
        }
    }

    Sound {
        id: soundEffect
        source: "snd/creeper" + parent.num + ".mp3"
    }

    Image {
        id: sprite
        source: "img/creeper" + parent.num + ".png"
        width: 32
        height: 32
        anchors.centerIn: boxCollider
    }

    FireParticles {
        id: fireParticleEffect
    }

    ParallelAnimation {
        id: appearEffect
        running: false
        NumberAnimation { target: entity; properties: "scale"; from: 0; to: 1; duration: 500; }
        onRunningChanged: {
            if (!appearEffect.running) moveEffect.running = true;
        }
    }

    ParallelAnimation {
        id: moveEffect
        running: false
        NumberAnimation { target: entity; properties: "rotation"; from: 0; to: 2; loops: Animation.Infinite; easing { type: Easing.InOutBounce } }
        NumberAnimation { target: entity; properties: "x"; to: targetX; duration: 18000; }
        NumberAnimation { target: entity; properties: "y"; to: targetY; duration: 18000; }
    }

    ParallelAnimation {
        id: explodeEffect
        running: false
        ScriptAction { script: { fireParticleEffect.start(); explodeSound.play(); } }
        NumberAnimation { to: 0; duration: 600; target: entity; property: "opacity" }
        NumberAnimation { to: 0; duration: 500; target: entity; property: "scale" }
        NumberAnimation { to: 360; duration: 500; target: entity; property: "rotation" }
        onRunningChanged: {
            if (!explodeEffect.running) entity.destroy()
        }
    }

    ParallelAnimation {
         id: hideEffect
         running: false
         NumberAnimation { to: 0; duration: 300; target: entity; property: "opacity" }
         NumberAnimation { to: 0; duration: 300; target: entity; property: "scale" }
         onRunningChanged: {
             if (!hideEffect.running) entity.destroy()
         }
    }

}

