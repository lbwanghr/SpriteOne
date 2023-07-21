//
//  GameRole.swift
//  animation0
//
//  Created by Haoran Wang on 2023/7/18.
//

import SpriteKit

class GameRole: SKSpriteNode {
    var characterType: String = "Archer-Green"
    var facingDirection: Direction = .south
    
    var shouldContinueMoving: Bool = false
    
    var idleTexture: SKTexture { animations[characterType]![facingDirection]![.move]![0] }
    
    var isMoving: Bool { action(forKey: "physicsMove") != nil }
    var hasMoveAnimation: Bool { action(forKey: "playMoveAnimation") != nil }
    var hasActionAnimation: Bool { action(forKey: "playActionAnimation") != nil }
    
    func configuration() {
        size = CGSize(width: 32, height: 32)
        texture = idleTexture
        let body = SKPhysicsBody(texture: texture!, size: size)
        physicsBody = body
        body.mass = 1
        body.affectedByGravity = false
        body.allowsRotation = false
    }
    
    func handleMoveBtnTouchBegan() {
        shouldContinueMoving = true
        physicsMoveCompleted()
        moveAnimationCompleted()
    }
    
    func handleMoveBtnTouchEnd() {
        if shouldContinueMoving { shouldContinueMoving = false }
        
    }
    
    func handleActionBtnTouchBegan(name: String) {
        if let animationType = AnimationType(rawValue: name) {
            let actionAnimation = animations[characterType]![facingDirection]![animationType]!

            if !hasActionAnimation {
                // removeMoveAction to avoid triggering moveAction's completion hander.
                if hasMoveAnimation { removeAction(forKey: "playMoveAnimation") }
                
                let actions: [SKAction] = [.animate(with: actionAnimation, timePerFrame: timePerFrame), .run(actionAnimationCompleted)]
                run(.sequence(actions), withKey: "playActionAnimation")
            }

        }
        
        if name == "changeRole" {
            removeAllActions()
            characterType = characterNames.randomElement()!
        }
        
        
    }
    
    
    // Called when gameScene updates.
    func update() {
        if !hasMoveAnimation && !hasActionAnimation {
            texture = idleTexture
        }
        
    }
    
    func physicsMoveCompleted() {
        if shouldContinueMoving {
            if isMoving { removeAction(forKey: "physicsMove") }
            let actions: [SKAction] = [.move(by: moveVectors[facingDirection]!, duration: moveDuration), .run(physicsMoveCompleted)]
            run(.sequence(actions), withKey: "physicsMove")
            
        }
    }
    
    func moveAnimationCompleted() {
        // If role is acting, don't play move animation.
        guard !hasActionAnimation else { return }

        if shouldContinueMoving {
            let actions: [SKAction] = [.animate(with: animations[characterType]![facingDirection]![.move]!, timePerFrame: timePerFrame), .run(moveAnimationCompleted)]
            run(.sequence(actions), withKey: "playMoveAnimation")
        }
        
    }
    
    func actionAnimationCompleted() {
        if shouldContinueMoving {
            if !hasMoveAnimation {
                let actions: [SKAction] = [.animate(with: animations[characterType]![facingDirection]![.move]!, timePerFrame: timePerFrame), .run(moveAnimationCompleted)]
                run(.sequence(actions), withKey: "playMoveAnimation")
            }
        }
    }
    
}
