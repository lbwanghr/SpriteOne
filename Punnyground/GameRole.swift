//
//  GameRole.swift
//  animation0
//
//  Created by Haoran Wang on 2023/7/18.
//

import SpriteKit

class GameRole: SKSpriteNode {
    var roleType: String = "Archer-Green"
    var facing: Direction = .south
    var lastPosition: CGPoint = roleStartPoint
    
    var idleTexture: SKTexture { animations[roleType]![facing]![.move]![0] }
    
    var isPlaying: Bool { isPlayingMove || isPlayingAction }
    var isMoving: Bool { physicsBody!.velocity != .zero }
    var isPlayingMove: Bool { action(forKey: "playMoveAnimation") != nil}
    var isPlayingAction: Bool { action(forKey: "playActionAnimation") != nil }
    
    func configuration() {
        position = roleStartPoint
        size = CGSize(width: 32, height: 32)
        texture = idleTexture
        physicsBody = SKPhysicsBody(texture: texture!, size: size)
        physicsBody?.mass = 1
        physicsBody?.affectedByGravity = false
        physicsBody?.allowsRotation = false
        
    }

    func playMoveAnimation() {
        let moveAnimation = animations[roleType]![facing]![.move]!
        // completion belongs to action with key "playMoveAnimation"
        let completion = { if self.isMoving && !self.isPlayingAction{ self.playMoveAnimation() } }
        run(.sequence([.animate(with: moveAnimation, timePerFrame: timePerFrame), .run(completion)]), withKey: "playMoveAnimation")
    }
    
    func playActionAnimation(animationType: AnimationType) {
        guard !isPlayingAction else { return }
        let actionAnimation = animations[roleType]![facing]![animationType]!
        let completion = { if self.isMoving { self.playMoveAnimation() } }
        run(.sequence([.animate(with: actionAnimation, timePerFrame: timePerFrame), .run(completion)]), withKey: "playActionAnimation")
    }
    
}
