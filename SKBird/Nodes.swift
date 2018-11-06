//
//  Nodes.swift
//  SKBird
//
//  Created by localadmin on 06.11.18.
//  Copyright © 2018 ch.cqd.skbird. All rights reserved.
//

import SpriteKit

class Projectile: SKShapeNode {
    convenience init(path: UIBezierPath, color: UIColor, borderColor: UIColor) {
        self.init()
        self.path = path.cgPath
        self.fillColor = color
        self.strokeColor = borderColor
    }
}

class Box: SKSpriteNode {
    var integrity: Int = 2 {
        didSet {
            if integrity > 2 {
                integrity = 2
            }
            if integrity < 0 {
                removeFromParent()
            }
            texture = SKTexture(imageNamed: "box_\(integrity)")
        }
    }
}
