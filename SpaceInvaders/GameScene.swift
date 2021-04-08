//
//  GameScene.swift
//  SpaceInvaders
//
//  Created by Guillermo Fernandez on 24/03/2021.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var spaceShip: SKSpriteNode!
    private let laserShootSound = SKAction.playSoundFileNamed("lasershoot.wav", waitForCompletion: false)
    let bombSound = SKAction.playSoundFileNamed("bomb.wav", waitForCompletion: false)
    let boomSound = SKAction.playSoundFileNamed("boom.wav", waitForCompletion: false)
    private var spaceshipTouch: UITouch?
    var scoreLabel: SKLabelNode!
    var bombTimer: Timer?
    var enemyMoveTimer: Timer?
    var direction : Direction = .right
    var prevDirection : Direction = .right
    var currentScore: Int = 0
    let enemiesVerticaSpacing: CGFloat = 50.0
    var houseImpacts = [0, 0, 0, 0]
    
    override func didMove(to view: SKView) {
        let spaceshipYPositon = -(self.size.height / 2) + 100
        
        self.backgroundColor = .black
        self.spaceShip = SKSpriteNode(imageNamed: "SpaceShip")
        self.spaceShip.name = "Player"
        self.spaceShip.size = CGSize(width: 50, height: 25)
        self.spaceShip.position = CGPoint(x: 0, y: spaceshipYPositon)
        self.spaceShip.physicsBody = SKPhysicsBody(texture: self.spaceShip.texture!, size: self.spaceShip.size)
        self.spaceShip.physicsBody?.categoryBitMask = 0x00000010
        self.spaceShip.physicsBody?.affectedByGravity = false
        self.spaceShip.physicsBody?.contactTestBitMask = 0x00000101
        self.spaceShip.physicsBody?.collisionBitMask = 0x00000000
        self.addChild(self.spaceShip)
        
        self.addHouses(spaceshipYPositon)
        
        self.addEnemies(at: 100)
        
        self.physicsWorld.contactDelegate = self
        
        self.scoreLabel = SKLabelNode(text: "SCORE: 0")
        self.scoreLabel.position = CGPoint(x: 0, y: (self.size.height / 2) - 50)
        self.addChild(self.scoreLabel)
        
        self.bombTimer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(dropBomb), userInfo: nil, repeats: true)
        self.enemyMoveTimer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(moveEnemies), userInfo: nil, repeats: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard self.spaceshipTouch == nil else {
            self.createShoot()
            run(self.laserShootSound)
            return
        }
        
        if let touch = touches.first {
            self.spaceshipTouch = touch
            let newPosition = touch.location(in: self)
            let action = SKAction.moveTo(x: newPosition.x, duration: 0.5)
            action.timingMode = .easeInEaseOut
            self.spaceShip.run(action)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch == self.spaceshipTouch {
                let newPosition = touch.location(in: self)
                let action = SKAction.moveTo(x: newPosition.x, duration: 0.05)
                action.timingMode = .easeInEaseOut
                self.spaceShip.run(action)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch == self.spaceshipTouch {
                self.spaceshipTouch = nil
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch == self.spaceshipTouch {
                self.spaceshipTouch = nil
            }
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        self.cleanPastShoots()
    }
}

extension GameScene {
    private func cleanPastShoots() {
        for node in children {
            guard node.name == "shoot" || node.name == "bomb" else { continue }
            if node.position.y > 700 || node.position.y < -700{
                node.removeFromParent()
            }
        }
    }
    
    @objc
    private func dropBomb()
    {
        let bottomEnemies = self.children.filter
        { node in
            guard let isEnemy = node.name?.hasPrefix("Enemy"), isEnemy == true else { return false }
            let bottomPosition = CGPoint(x: node.position.x, y: node.position.y - self.enemiesVerticaSpacing)
            let enemies = self.nodes(at: bottomPosition)
            
            return !enemies.reduce(false) { $0 || $1.name!.hasPrefix("Enemy") }
        }
        
        guard bottomEnemies.count > 0 else { return }
        
        let shooterEnemyIndex = Int.random(in: 0..<bottomEnemies.count)
        let shooterEnemy = bottomEnemies[shooterEnemyIndex]
        let bombPosition = CGPoint(x: shooterEnemy.position.x,
                                   y: shooterEnemy.position.y - self.enemiesVerticaSpacing / 2)
        self.createBomb(at: bombPosition)
    }
    
    @objc
    private func moveEnemies()
    {

        let enemySpacing = self.size.width / 16
        var actionArray : [SKAction] = []
        
        let enemies = self.children.filter
        {
            $0.name?.hasPrefix("Enemy") ?? false
        }
        
        switch self.direction
        {
            case .right:
                let maxX = enemies.reduce(CGFloat(Int.min)) { max($0,$1.position.x) }
                if((maxX + enemySpacing) >= self.size.width / 2)
                {
                    self.direction = .down
                    self.prevDirection = .right
                }
                break;
            case .left:
                let minX = enemies.reduce(CGFloat(Int.max)) { min($0,$1.position.x) }
                if((minX - enemySpacing) <= -self.size.width / 2)
                {
                    self.direction = .down
                    self.prevDirection = .left
                }
                break;
            case .down:
                switch self.prevDirection
                {
                    case .right:
                        self.direction = .left
                        break;
                    case .left:
                        self.direction = .right
                        break;
                    case .down:
                        self.direction = .down
                        break;
                }
                break;
        }
        
        enemies.forEach
        { (enemy) in
            let movingAction = SKAction.run({
                switch self.direction
                {
                    case .right:
                        enemy.run(SKAction.moveBy(x: enemySpacing, y: 0, duration: 0))
                        break;
                    case .left:
                        enemy.run(SKAction.moveBy(x: -enemySpacing, y: 0, duration: 0))
                        break;
                    case .down:
                        enemy.run(SKAction.moveBy(x: 0, y: -self.enemiesVerticaSpacing, duration: 0))
                        break;
                }
                
            })
            actionArray.append(movingAction)
        }
        
        self.run(SKAction.group(actionArray))
    }
}

enum Direction
{
    case left
    case right
    case down
}
