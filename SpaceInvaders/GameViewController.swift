//
//  GameViewController.swift
//  SpaceInvaders
//
//  Created by Guillermo Fernandez on 24/03/2021.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController, GameSceneDelegate {
    func restartGame()
    {
        if let view = self.view as! SKView? {
            createScene(view)
        }
    }
    

    @IBOutlet weak var launchImage: UIImageView!
    var mainScene : GameScene?
    
    func createScene(_ view: SKView) {
        // Load the SKScene from 'GameScene.sks'
        mainScene = SKScene(fileNamed: "GameScene") as? GameScene
        mainScene?.gameDelegate = self
        // Set the scale mode to scale to fit the window
        mainScene?.scaleMode = .aspectFit
        // Present the scene
        view.presentScene(mainScene)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            createScene(view)
                        
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.launchImage.isHidden = true
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
