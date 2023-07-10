//
//  GameThree.swift
//  SpriteThree
//
//  Created by Haoran Wang on 2023/7/10.
//

import Foundation
import SpriteKit

class GameThree: SKScene, SKPhysicsContactDelegate {
    
    let bgSize = CGSize(width: 1024, height: 768)
    let player = SKSpriteNode(imageNamed: "plane")
    let scoreLabel = SKLabelNode(fontNamed: "Baskerville-Bold")
    let music = SKAudioNode(fileNamed: "the-hero")
    let gameOver = SKSpriteNode(imageNamed: "game-over")
    
    var timer: Timer?
    
    var score = 0 {
        didSet {
            scoreLabel.text = "SCORE: \(score)"
        }
    }
    
    override func sceneDidLoad() {
        self.size = bgSize
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.scaleMode = .aspectFit
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -5)
        self.physicsWorld.contactDelegate = self
        
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.texture!.size())
        player.zPosition = 1
        player.position = CGPoint(x: -400, y: 250)
        player.physicsBody?.categoryBitMask = 0x00000001
        player.physicsBody?.collisionBitMask = 0x00000000
        self.addChild(player)
        
        parallaxScroll(image: "sky", y: 0, z: -3, duration: 10, needsPhysics: false)
        parallaxScroll(image: "ground", y: -349, z: -1, duration: 6, needsPhysics: true)
        
        scoreLabel.fontColor = .black.withAlphaComponent(0.5)
        scoreLabel.position.y = 320
        self.addChild(scoreLabel)
        
        self.addChild(music)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { timer in
            self.createObstacle()
        }
        
        score = 0
    }
    
    override func update(_ currentTime: TimeInterval) {
        let value = player.physicsBody!.velocity.dy * 0.001
        player.run(.rotate(toAngle: value, duration: 0.1))
        
        if player.position.y > 300 {
            player.position.y = 300
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        player.physicsBody?.velocity = CGVector(dx: 0, dy: 300)
        guard let touch = touches.first else { return }
        if let tappedNode = self.nodes(at: touch.location(in: self)).first {
            if tappedNode == gameOver {
                self.isUserInteractionEnabled = false
                gameOver.removeFromParent()
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.view?.presentScene(GameThree(), transition: .crossFade(withDuration: 1))
                }
            }
        }
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        if nodeA == player {
            playerHit(nodeB)
        } else {
            playerHit(nodeA)
        }
    }
    
    func parallaxScroll(image: String, y: CGFloat, z: CGFloat, duration: Double, needsPhysics: Bool) {
        for i in 0 ... 1 {
            let node = SKSpriteNode(imageNamed: image)
            node.position = CGPoint(x: 1023 * CGFloat(i), y: y)
            node.zPosition = z
            self.addChild(node)
            let sequence = SKAction.sequence([
                .moveBy(x: -1024, y: 0, duration: duration),
                .moveBy(x: 1024, y: 0, duration: 0)
                               ])
            node.run(.repeatForever(sequence))
            if needsPhysics {
                node.physicsBody = SKPhysicsBody(texture: node.texture!, size: node.size)
                node.physicsBody?.isDynamic = false
                node.physicsBody?.contactTestBitMask = 0x00000001
                node.name = "obstacle"
            }
            
        }
        
    }
    
    func createObstacle() {
        let obstacle = SKSpriteNode(imageNamed: "enemy-balloon")
        obstacle.zPosition = -2
        obstacle.position.x = 768
        obstacle.position.y = CGFloat.random(in: -300 ..< 350)
        self.addChild(obstacle)
        
        obstacle.physicsBody = SKPhysicsBody(texture: obstacle.texture!, size: obstacle.size)
        obstacle.physicsBody?.isDynamic = false
        obstacle.physicsBody?.contactTestBitMask = 0x00000001
        obstacle.name = "obstacle"
        obstacle.run(.sequence([.moveTo(x: -768, duration: 9), .removeFromParent()]))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            let coin = SKSpriteNode(imageNamed: "coin")
            coin.position = CGPoint(x: 768, y: Double.random(in: -300 ..< 350))
            coin.zPosition = -2
            self.addChild(coin)
            
            coin.physicsBody = SKPhysicsBody(texture: coin.texture!, size: coin.size)
            coin.physicsBody?.isDynamic = false
            coin.physicsBody?.contactTestBitMask = 0x00000001
            coin.name = "coin"
            coin.run(.sequence([.moveTo(x: -768, duration: TimeInterval.random(in: 1 ..< 11)), .removeFromParent()]))
            
        }
        
    }
    
    func playerHit(_ node: SKNode) {
        guard !self.children.contains(gameOver) else { return } //因碰撞检测可能发生两次
        if node.name == "obstacle" {
            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                explosion.position = player.position
                self.addChild(explosion)
                self.run(.playSoundFileNamed("explosion", waitForCompletion: false))
            }
            
            player.removeFromParent()
            music.removeFromParent()
            
            gameOver.zPosition = 5
            self.addChild(gameOver)
            
            
        } else if node.name == "coin" {
            score += 1
            self.run(.playSoundFileNamed("score", waitForCompletion: false))
            node.removeFromParent()
        }
    }
    
}
