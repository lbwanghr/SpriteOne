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
        dataSource.animations[characterType]![facingDirection]![.move]![0]
    }
    
    init() {
        super.init(texture: nil, color: .gray, size: .zero)
        
        characterType = "Human-Soldier-Cyan"
        size = CGSize(width: 32, height: 32)
        texture = idleTexture
        
        physicsBody = SKPhysicsBody(texture: texture!, size: size)
        physicsBody?.affectedByGravity = false
        physicsBody?.mass = 1
        physicsBody?.allowsRotation = false
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func handleBtnMove() {
        shouldContinueMoving = true
        let moveAction = SKAction.move(by: dataSource.moveVectors[facingDirection]!, duration: moveDuration)
        run(moveAction)
        let animation = dataSource.animations[characterType]![facingDirection]![.move]!
        let animationAction = SKAction.animate(with: animation, timePerFrame: timePerFrame)
        run(animationAction){
            self.loopAnimation()
        }
    }
    
    func loopAnimation() {
        if shouldContinueMoving {
            run(.move(by: dataSource.moveVectors[facingDirection]!, duration: moveDuration))
            run(.animate(with: dataSource.animations[characterType]![facingDirection]![.move]!, timePerFrame: timePerFrame)) {
                self.shouldResetTexture = true
                self.loopAnimation()
            }
        }
    }
    
    func handleOtherTouch(name: String) {
        var animation: [SKTexture]
        let set = dataSource.animations[characterType]![facingDirection]!
        if let animationType = AnimationType(rawValue: name) {
            animation = set[animationType]!
            run(.animate(with: animation, timePerFrame: timePerFrame)) {
                if name != "dead" {
                    self.shouldResetTexture = true
                }
            }
        }
        
        if name == "changeRole" {
            characterType = characterAssets.randomElement()!
        }
        
        
    }
    
    func endTouching() {
        if shouldContinueMoving {
            shouldContinueMoving = false
            shouldResetTexture = true
            removeAllActions()
        }
    }
    
    func handleUpdate() {
        if shouldResetTexture {
            texture = idleTexture
            shouldResetTexture = false
        }
        
        if hasActions() {
            isUserInteractionEnabled = false
        } else {
            isUserInteractionEnabled = true
        }
    }
    
}
