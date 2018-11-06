//
//  GameScene.swift
//  SKBird
//
//  Created by localadmin on 06.11.18.
//  Copyright © 2018 ch.cqd.skbird. All rights reserved.
//

import SpriteKit
import GameplayKit



class GameScene: SKScene, touchMe, SKPhysicsContactDelegate  {
    
    let src = [
        // bottom row: left, center, right
        vector_float2(0.0, 0.0),
        vector_float2(0.5, 0.0),
        vector_float2(1.0, 0.0),
        
        // middle row: left, center, right
        vector_float2(0.0, 0.5),
        vector_float2(0.5, 0.5),
        vector_float2(1.0, 0.5),
        
        // top row: left, center, right
        vector_float2(0.0, 1.0),
        vector_float2(0.5, 1.0),
        vector_float2(1.0, 1.0)
    ]
    
    enum categories {
        static let noCat:UInt32 = 0
        static let birdCat:UInt32 = 0b1
        static let boxCat:UInt32 = 0b1 << 1
        static let floorCat: UInt32 = 0b1 << 2
    }
    
    func spriteTouched(box: TouchableSprite) {
        if box.name == "restart" {
            let scene = GameScene()
            scene.size = view!.bounds.size
            scene.scaleMode = .aspectFill
            let doors = SKTransition.crossFade(withDuration: 2)
            doors.pausesIncomingScene = false
            doors.pausesOutgoingScene = true
            self.view!.presentScene(scene, transition: doors)
        } else {
            let bird2Select = "\(box.name!)"
            let kids = scene?.children
            for kid in kids! {
                if kid.name == bird2Select {
                    kid.run(SKAction.fadeOut(withDuration: 1))
                }
            }
            projectile = SKSpriteNode(imageNamed:bird2Select)
            projectile.position = Settings.Metrics.projectileRestPosition
            projectile.name = bird2Select
            projectile.run(SKAction.fadeOut(withDuration: 0))
            addChild(projectile)
            projectile.run(SKAction.fadeIn(withDuration: 1))
            
        }
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        print("contact cA \(contact.bodyA.node?.name) cB \(contact.bodyB.node?.name)")
        let cA = contact.bodyA.node?.name
        let cB = contact.bodyB.node?.name
        if cA == "box" {
            let cAx = (contact.bodyA.node as! Box)
            cAx.integrity -= 1
        }
    }
    
    
//    var projectile: Projectile!
    var restartButton: TouchableSprite!
    var projectile: SKSpriteNode!
    var projectileIsDragged = false
    var touchCurrentPoint: CGPoint!
    var touchStartingPoint: CGPoint!

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        backgroundColor = UIColor.black
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody?.contactTestBitMask = categories.floorCat
        physicsBody?.categoryBitMask = categories.floorCat
        physicsBody?.collisionBitMask = categories.floorCat
        physicsWorld.gravity = Settings.Game.gravity
        physicsWorld.speed = 0.5
        physicsWorld.contactDelegate = self
        
        
        setupSlingshot()
        setupBoxes()
        setupRestart()
        setupBirds()
        
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
                var birdName = "\(projectile.name!)"
                let birdX = SKTexture(imageNamed: birdName)
                projectile.physicsBody = SKPhysicsBody(texture: birdX, size: birdX.size())
                projectile?.physicsBody?.categoryBitMask = categories.birdCat
                // category that defines which bodies will react it
//                projectile?.physicsBody?.collisionBitMask = categories.noCat
                // respond with cause delegate calls
                projectile?.physicsBody?.contactTestBitMask = categories.boxCat
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
    
    func setupRestart() {
        restartButton = TouchableSprite(imageNamed: "64x200")
        restartButton.name = "restart"
        restartButton.delegate = self
        restartButton.position = CGPoint(x: self.view!.bounds.midX, y: self.view!.bounds.midY)
        restartButton.run(SKAction.fadeOut(withDuration: 0))
        addChild(restartButton)
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
        
//        projectile = SKSpriteNode(imageNamed:"redBird")
//        projectile.position = Settings.Metrics.projectileRestPosition
//        addChild(projectile)
    }
    
    func setupBirds() {
        var birdNames = ["red","blue","yellow","white"]
        var xCord = self.view!.bounds.midX + 128
        for _ in 0..<birdNames.count {
            let bird = birdNames.popLast()
        
            let bird2Show = "\(bird!)Bird"
            let birdSprite = TouchableSprite(imageNamed:bird2Show)
            
            birdSprite.position = CGPoint(x: xCord, y: self.view!.bounds.maxY - 64)
            birdSprite.name = bird2Show
            birdSprite.delegate = self
            xCord -= 96
            addChild(birdSprite)
        }
    }
    
    func setupBoxes() {
        for i in 1...2 {
            for j in 1...8 {
                let box = Box(imageNamed: "box_2")
                box.integrity = 2
                box.position = CGPoint(x: 400 + (i * 20 + 5 * i), y:  j * 20 + j)
                let bigBox = CGSize(width: 40, height: 40)
                box.size = bigBox
                box.physicsBody = SKPhysicsBody(rectangleOf: bigBox)
                box.physicsBody?.isDynamic = true
//                box.physicsBody?.affectedByGravity = true
                box.physicsBody?.categoryBitMask = categories.boxCat
               // category that defines which bodies will react it
//                box.physicsBody?.collisionBitMask = categories.birdCat
                // respond with cause delegate calls
                box.physicsBody?.contactTestBitMask = categories.birdCat
                box.name = "box"
                addChild(box)
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if projectile != nil {
            if projectile.physicsBody != nil {
                if (projectile.physicsBody!.isResting) {
                    restartButton.run(SKAction.fadeIn(withDuration: 2))
                }
//                print("projectile \(projectile.physicsBody!.velocity)")
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
