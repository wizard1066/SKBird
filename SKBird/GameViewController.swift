//
//  GameViewController.swift
//  SKBird
//
//  Created by localadmin on 06.11.18.
//  Copyright © 2018 ch.cqd.skbird. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let skView = view as! SKView
        skView.showsFPS = true
//        skView.showsPhysics = true
        skView.shouldCullNonVisibleNodes = true
        let scene = GameScene()
        scene.size = view.bounds.size
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            return [.landscapeLeft, .landscapeRight]
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
