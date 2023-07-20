//
//  GameRole.swift
//  animation0
//
//  Created by Haoran Wang on 2023/7/18.
//

import SpriteKit

class GameRole: SKSpriteNode {
    var characterType: String = "Archer-Green" {
        didSet {
            shouldResetTexture = true
        }
    }
    
    var facingDirection: Direction = .south
    
    var shouldResetTexture: Bool = false
    var shouldContinueMoving: Bool = false
    
    var idleTexture: SKTexture {
        animations[characterType]![facingDirection]![.move]![0]
    }
    
    func configuration() {
        size = CGSize(width: 32, height: 32)
        texture = idleTexture
        
        physicsBody = SKPhysicsBody(texture: texture!, size: size)
        physicsBody?.affectedByGravity = false
        physicsBody?.mass = 1
        physicsBody?.allowsRotation = false
    }
    
    func handleBtnMove() {
        shouldContinueMoving = true
        
        removeAllActions()
        
        let physicsMove = SKAction.move(by: moveVectors[facingDirection]!, duration: moveDuration)
        if action(forKey: "physicsMove") != nil {
            removeAction(forKey: "physicsMove")
        }
        run(physicsMove, withKey: "physicsMove")
        
        let moveAnimation = animations[characterType]![facingDirection]![.move]!
        let playMoveAnimation = SKAction.animate(with: moveAnimation, timePerFrame: timePerFrame)
        
        if action(forKey: "playMoveAnimation") != nil {
            removeAction(forKey: "playMoveAnimation")
        }
        run(SKAction.sequence([playMoveAnimation, .run{
            self.loopAnimation()
        }]), withKey: "playMoveAnimation")
    }
    
    func loopAnimation() {
        if shouldContinueMoving {
            
            removeAllActions()
            
            run(.move(by: moveVectors[facingDirection]!, duration: moveDuration))
            run(.animate(with: animations[characterType]![facingDirection]![.move]!, timePerFrame: timePerFrame)) {
                self.shouldResetTexture = true
                self.loopAnimation()
            }
        } else {
            shouldResetTexture = true
        }
    }
    
    func handleActionTouch(name: String) {
        var animation: [SKTexture]
        let set = animations[characterType]![facingDirection]!
        if let animationType = AnimationType(rawValue: name) {
            animation = set[animationType]!
            
            if action(forKey: "playActionAnimation") == nil {
                run(.sequence([.animate(with: animation, timePerFrame: timePerFrame), .run {
                    if name != "dead" {
                        self.shouldResetTexture = true
                    }
                }]), withKey: "playActionAnimation")
            }

            
        }
        
        if name == "changeRole" {
            
            removeAllActions()
            
            characterType = characterNames.randomElement()!
        }
        
        
    }
    
    func endTouching() {
        if shouldContinueMoving {
            shouldContinueMoving = false
            shouldResetTexture = true

        }
    }
    
    func handleUpdate() {
        if shouldResetTexture {
            texture = idleTexture
            shouldResetTexture = false
        }
        

    }
    
}
