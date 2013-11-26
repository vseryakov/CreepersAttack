import QtQuick 1.1
import Box2D 1.0
import VPlay 1.0

EntityBase {
    id: entity
    entityType: "wall"

    BoxCollider {
        id: boxCollider
        bodyType: Body.Static
        categories: Box.Category4
    }

    Rectangle {
        id: rect
        color: "black"
        anchors.fill: parent
    }
}

