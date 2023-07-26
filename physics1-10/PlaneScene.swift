//
//  PlaneScene.swift
//  SpriteOne
//
//  Created by Haoran Wang on 2023/7/23.
//

import SpriteKit

class PlaneScene: SKScene {
    let plane = SKSpriteNode(imageNamed: "plane")
    var timer: Timer?
    override func didMove(to view: SKView) {
        size = CGSize(width: 400, height: 225);         scaleMode = .aspectFit
        plane.position = CGPoint(x: -30, y: 200);        addChild(plane)
        plane.size = CGSize(width: 27, height: 23)
        plane.physicsBody = SKPhysicsBody(texture: plane.texture!, size: plane.size)
        plane.physicsBody?.affectedByGravity = false
        plane.physicsBody?.mass = 1
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            let coin = SKShapeNode(circleOfRadius: 2)
            coin.fillColor = .yellow
            coin.strokeColor = .clear
            coin.name = "coin"
            coin.physicsBody = SKPhysicsBody()
            coin.physicsBody?.affectedByGravity = false
            coin.position.x = self.plane.position.x
            coin.position.y = self.plane.position.y - 15
            self.addChild(coin)
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        plane.physicsBody?.applyForce(CGVector(dx: 20, dy: 0))
        
        if plane.position.x > 450 {
            plane.position.x = -30
        }
        for node in children {
            if node.position.y < -20 {
                node.removeFromParent()
            }
            if node.name == "coin" {
                node.physicsBody?.applyForce(CGVector(dx: 0, dy: -5))
            }
        }
    }
}
