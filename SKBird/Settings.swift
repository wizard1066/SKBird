//
//  Settings.swift
//  SKBird
//
//  Created by localadmin on 06.11.18.
//  Copyright © 2018 ch.cqd.skbird. All rights reserved.
//

import SpriteKit

struct Settings {
    struct Metrics {
        static let projectileRadius = CGFloat(10)
        static let projectileRestPosition = CGPoint(x: 100, y: 100)
        static let projectileTouchThreshold = CGFloat(10)
        static let projectileSnapLimit = CGFloat(20)
        static let forceMultiplier = CGFloat(4)
        static let rLimit = CGFloat(50)
    }
    struct Game {
        static let gravity = CGVector(dx: 0,dy: -4.5)
    }
}
