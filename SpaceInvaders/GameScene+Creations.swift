//
//  GameScene+Creations.swift
//  SpaceInvaders
//
//  Created by Guillermo Fernandez on 29/03/2021.
//

import SpriteKit
import GameplayKit

extension GameScene {
    
    func createShoot() {
        let sprite = SKSpriteNode(imageNamed: "Shoot")
        sprite.position = self.spaceShip.position
        sprite.name = "shoot"
        sprite.zPosition = 1
        addChild(sprite)
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.velocity = CGVector(dx: 0, dy: 500)
        sprite.physicsBody?.affectedByGravity = false
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.contactTestBitMask = 0x00000101
    }
    

    func addHouses(_ spaceshipYPositon: CGFloat) {
        let houseSpacing = self.size.width / 9
        var startX = -(self.size.width / 2) + 0.5
            * houseSpacing
        for n in (0...3) {
            self.addHouse(n, at: CGPoint(x: startX, y: spaceshipYPositon + 150))
            startX += 2.2 * houseSpacing
        }
    }
    
    private func addHouse(_ number: Int, at center: CGPoint) {
        let rowHeights: [CGFloat] = [11, 25, 26]
        for n in (0..<9) {
            let row = (n / 3) % 3
            let column = n % 3
            let houseX = center.x + ((CGFloat(column) + 1) * 30)
            let houseY = center.y + ((CGFloat(row) - 1) * -rowHeights[row])
            let texture = SKTexture(imageNamed: "house_\(row)\(column)")
            let sprite = SKSpriteNode(texture: texture, size: texture.size())

            sprite.name = "house"
            sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
            sprite.position = CGPoint(x: houseX, y: houseY)
            sprite.physicsBody?.affectedByGravity = false
            sprite.physicsBody?.categoryBitMask = 0x00000100
            sprite.physicsBody?.isDynamic = false
            
            self.addChild(sprite)
        }

    }
 
    private func getPosition(from matrix: [[CGSize]], at: CGPoint, center: CGPoint) -> CGPoint {
        
        if at == CGPoint.zero { return center }
        var position = center
        for x in (1...Int(at.x)) {
                position.x += matrix[x-1][0].width
        }
        
        return position
    }
        
    func addEnemies(at y: CGFloat) {
        let enemySpacing = self.size.width / 16
        let startX = -(self.size.width / 2) + 30
        var startY = (self.size.height / 2) - 100

        for n in 0...8 {
            addEnemy(1, at: CGPoint(x: startX + ( 1.5 * CGFloat(n) * enemySpacing ), y: startY))
        }
        
        startY -= self.enemiesVerticaSpacing
        for n in 0...8 {
            addEnemy(2, at: CGPoint(x: startX + ( 1.5 * CGFloat(n) * enemySpacing ), y: startY))
        }
        
        startY -= self.enemiesVerticaSpacing
        for n in 0...8 {
            addEnemy(2, at: CGPoint(x: startX + ( 1.5 * CGFloat(n) * enemySpacing ), y: startY))
        }
        
        startY -= self.enemiesVerticaSpacing
        for n in 0...8 {
            addEnemy(3, at: CGPoint(x: startX + ( 1.5 * CGFloat(n) * enemySpacing ), y: startY))
        }

        startY -= self.enemiesVerticaSpacing
        for n in 0...8 {
            addEnemy(3, at: CGPoint(x: startX + ( 1.5 * CGFloat(n) * enemySpacing ), y: startY))
        }

    }
    
    private func addEnemy(_ number: Int, at position: CGPoint) {
        let enemyAnimatedAtlas = SKTextureAtlas(named: "Enemy\(number)")
        var moveFrames: [SKTexture] = []
        
        let numImages = enemyAnimatedAtlas.textureNames.count
        for i in 1...numImages {
            let enemyTextureName = "Enemy_\(number)_\(i)"
            moveFrames.append(enemyAnimatedAtlas.textureNamed(enemyTextureName))
        }
        
        let firstFrameTexture = moveFrames[0]
        let enemy = SKSpriteNode(texture: firstFrameTexture)
        enemy.size.resize(to: 0.35)
        enemy.position = position
        enemy.physicsBody = SKPhysicsBody(texture: enemy.texture!, size: enemy.size)
        enemy.physicsBody?.categoryBitMask = 0x00000001
        enemy.physicsBody?.contactTestBitMask = 0x00000000
        enemy.physicsBody?.collisionBitMask = 0x00000000
        enemy.name = "Enemy_\(number)"
        enemy.physicsBody?.affectedByGravity = false
        self.addChild(enemy)

        enemy.run(SKAction.repeatForever(SKAction.animate(with: moveFrames,
                                                          timePerFrame: 1,
                                                          resize: false,
                                                          restore: true)))
    }
    
    func createBomb(at position: CGPoint) {
        let sprite = SKSpriteNode(imageNamed: "Shoot")
        sprite.position = position
        sprite.name = "bomb"
        sprite.zPosition = 1
        addChild(sprite)
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.affectedByGravity = true
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.contactTestBitMask = 0x00000110
    }

}
