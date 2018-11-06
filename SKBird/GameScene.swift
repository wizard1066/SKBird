//
//  GameScene.swift
//  SKBird
//
//  Created by localadmin on 06.11.18.
//  Copyright © 2018 ch.cqd.skbird. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
//    var projectile: Projectile!
    var projectile: SKSpriteNode!
    var projectileIsDragged = false
    var touchCurrentPoint: CGPoint!
    var touchStartingPoint: CGPoint!

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        backgroundColor = UIColor.black
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.gravity = Settings.Game.gravity
        physicsWorld.speed = 0.5
        
        setupSlingshot()
        setupBoxes()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        func shouldStartDragging(touchLocation:CGPoint, threshold: CGFloat) -> Bool {
            let distance = fingerDistanceFromProjectileRestPosition(
                projectileRestPosition: Settings.Metrics.projectileRestPosition,
                fingerPosition: touchLocation
            )
            return distance < Settings.Metrics.projectileRadius + threshold
        }
        
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            
            if !projectileIsDragged && shouldStartDragging(touchLocation: touchLocation, threshold: Settings.Metrics.projectileTouchThreshold)  {
                touchStartingPoint = touchLocation
                touchCurrentPoint = touchLocation
                projectileIsDragged = true
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if projectileIsDragged {
            if let touch = touches.first {
                let touchLocation = touch.location(in: self)
                let distance = fingerDistanceFromProjectileRestPosition(projectileRestPosition: touchLocation, fingerPosition: touchStartingPoint)
                if distance < Settings.Metrics.rLimit  {
                    touchCurrentPoint = touchLocation
                } else {
                    touchCurrentPoint = projectilePositionForFingerPosition(
                        fingerPosition: touchLocation,
                        projectileRestPosition: touchStartingPoint,
                        rLimit: Settings.Metrics.rLimit
                    )
                }
            }
            projectile.position = touchCurrentPoint
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if projectileIsDragged {
            projectileIsDragged = false
            let distance = fingerDistanceFromProjectileRestPosition(projectileRestPosition: touchCurrentPoint, fingerPosition: touchStartingPoint)
            if distance > Settings.Metrics.projectileSnapLimit {
                let vectorX = touchStartingPoint.x - touchCurrentPoint.x
                let vectorY = touchStartingPoint.y - touchCurrentPoint.y
//                projectile.physicsBody = SKPhysicsBody(circleOfRadius: Settings.Metrics.projectileRadius)
                let redBird = SKTexture(imageNamed: "redBird")
                projectile.physicsBody = SKPhysicsBody(texture: redBird, size: redBird.size())
                
                projectile.physicsBody?.applyImpulse(
                    CGVector(
                        dx: vectorX * Settings.Metrics.forceMultiplier,
                        dy: vectorY * Settings.Metrics.forceMultiplier
                    )
                )
            } else {
                projectile.physicsBody = nil
                projectile.position = Settings.Metrics.projectileRestPosition
            }
        }
    }
    
    // Version I
    
//    func setupSlingshot() {
//        let slingshot_1 = SKSpriteNode(imageNamed: "slingshot_1")
//        slingshot_1.position = CGPoint(x: 100, y: 50)
//        addChild(slingshot_1)
//
//        let projectilePath = UIBezierPath(
//            arcCenter: CGPoint.zero,
//            radius: Settings.Metrics.projectileRadius,
//            startAngle: 0,
//            endAngle: CGFloat(CGFloat.pi * 2),
//            clockwise: true
//        )
//        projectile = Projectile(path: projectilePath, color: UIColor.red, borderColor: UIColor.white)
//        projectile.position = Settings.Metrics.projectileRestPosition
//        addChild(projectile)
//
//        let slingshot_2 = SKSpriteNode(imageNamed: "slingshot_2")
//        slingshot_2.position = CGPoint(x: 100, y: 50)
//        addChild(slingshot_2)
//    }
    
    func setupSlingshot() {
        let slingshot_1 = SKSpriteNode(imageNamed: "slingshot_1")
        slingshot_1.position = CGPoint(x: 100, y: 50)
        addChild(slingshot_1)
        
        let slingshot_2 = SKSpriteNode(imageNamed: "slingshot_2")
        slingshot_2.position = CGPoint(x: 100, y: 50)
        addChild(slingshot_2)
        
        projectile = SKSpriteNode(imageNamed:"redBird")
        projectile.position = Settings.Metrics.projectileRestPosition
        addChild(projectile)
    }
    
    func setupBoxes() {
        for i in 1...2 {
            for j in 1...8 {
                let box = Box(imageNamed: "box_2")
                box.integrity = 2
                box.position = CGPoint(x: 400 + (i * 20 + 5 * i), y:  j * 20 + j)
                box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                addChild(box)
            }
        }
    }
    
    // MARK: helper functions
    
    func fingerDistanceFromProjectileRestPosition(projectileRestPosition: CGPoint, fingerPosition: CGPoint) -> CGFloat {
        return sqrt(pow(projectileRestPosition.x - fingerPosition.x,2) + pow(projectileRestPosition.y - fingerPosition.y,2))
    }

    func projectilePositionForFingerPosition(fingerPosition: CGPoint, projectileRestPosition:CGPoint, rLimit:CGFloat) -> CGPoint {
        let θ = atan2(fingerPosition.x - projectileRestPosition.x, fingerPosition.y - projectileRestPosition.y)
        let cX = sin(θ) * rLimit
        let cY = cos(θ) * rLimit
        return CGPoint(x: cX + projectileRestPosition.x, y: cY + projectileRestPosition.y)
    }
    
    

}
