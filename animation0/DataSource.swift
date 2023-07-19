//
//  DataSource.swift
//  animation0
//
//  Created by Haoran Wang on 2023/7/17.
//

import SpriteKit
import CoreImage

enum Direction: Int, CaseIterable { case southwest = 0, west, northwest, north, northeast, east, southeast, south }
enum AnimationType: String, CaseIterable { case move, slash, shoot, cast, hurt, dead }
enum ActionType: String, CaseIterable { case slash, shoot, cast, hurt, dead, changeRole }
typealias AnimationSet = [Direction: [AnimationType: [SKTexture]]]



class DataSource {
    var animations: [String: AnimationSet] = [:]
    var bg = SKNode()
    var moveBtnSet = SKNode()
    var actionBtnSet = SKNode()
    var loadProgress = 0.0
    
    let moveVectors: [Direction: CGVector] = [
        .southwest: CGVector(dx: -sqrt(moveSpeed), dy: -sqrt(moveSpeed)),
        .west: CGVector(dx: -moveSpeed, dy: 0),
        .northwest: CGVector(dx: -sqrt(moveSpeed), dy: sqrt(moveSpeed)),
        .north: CGVector(dx: 0, dy: moveSpeed),
        .northeast: CGVector(dx: sqrt(moveSpeed), dy: sqrt(moveSpeed)),
        .east: CGVector(dx: moveSpeed, dy: 0),
        .southeast: CGVector(dx: sqrt(moveSpeed), dy: -sqrt(moveSpeed)),
        .south: CGVector(dx: 0, dy: -moveSpeed)
    ]
    
    /// Generate animation library including all characters's all animations by direction and action.
    func loadAnimations() {
        let context = CIContext()
        for characterName in characterAssets {
            let input = CIImage(image: UIImage(named: characterName)!)!
            var results = AnimationSet()
            
            for direction in Direction.allCases {
                results[direction] = [:]
                
                var actionOffSet = -1
                for action in AnimationType.allCases {
                    actionOffSet += 1
                    results[direction]![action] = []
                    for index in 0 ..< 4 {
                        let result = context.createCGImage(input, from: input.regionOfInterest(for: input, in: CGRect(x: (actionOffSet * 4 + index) * 32, y: direction.rawValue * 32, width: 32, height: 32)))
                        results[direction]![action]!.append(SKTexture(cgImage: result!))
                    }
                }
                
            }
            animations[characterName] = results
        }
    }
    
    /// Generate background
    /// - Tiles are attached to a sknode called bg.
    /// - Note: sknode has no anchorPoint property, that means the anchorPoint is .zero.
    func loadBackground() {
        let (rows, cols) = (Int(resolution.height) / 16, Int(resolution.width) / 16)
        let bgCells = ["Dirt", "Grass1", "Grass2"]
        let bgTree = "Tree"
        
        bg.position = CGPoint(x: resolution.width / -2, y: resolution.height / -2)
        
        // Generate tiles(designate tile's anchorPoint to .zero)
        for row in 0 ..< rows {
            for col in 0 ..< cols {
                let tile = SKSpriteNode(imageNamed: bgCells.randomElement()!)
                tile.anchorPoint = .zero
                tile.position = CGPoint(x: col * 16, y: row * 16)
                tile.zPosition = -1
                
                bg.addChild(tile)
            }
        }
        // Generate trees(tree's anchorPoint is default .center)
        for _ in 0 ..< numberOfTree {
            let tree = SKSpriteNode(imageNamed: bgTree)
            tree.position = CGPoint(x: Double.random(in: 0 ..< resolution.width), y: Double.random(in: 0 ..< resolution.height))
            
            let physicsBody = SKPhysicsBody(texture: tree.texture!, size: tree.size)
            tree.physicsBody = physicsBody
            physicsBody.mass = 1000
            physicsBody.allowsRotation = false
            physicsBody.affectedByGravity = false
            
            bg.addChild(tree)
        }
    }
    
    /// Load buttons' texture and arrange their position
    /// - Buttons are attached to two btnSet sknodes.
    func loadButtons() {
        for direction in Direction.allCases {
            let btn = SKSpriteNode()
            let uiImg = UIImage(systemName: "arrowshape.down.fill")!
            btn.texture = SKTexture(image: uiImg)
            btn.zRotation = CGFloat.pi / 4 * -1 * CGFloat(direction.rawValue - 7)
            btn.zPosition = 1
            btn.alpha = btnAlpha
            btn.position = CGPoint(x: (CGFloat(direction.rawValue) - 3.5) * btnInterval, y: 0)
            btn.size = btnSize
            btn.name = "move\(direction.rawValue)"
            moveBtnSet.addChild(btn)
            moveBtnSet.position = moveBtnPosition
            
        }
        
        var actionBtnXOffset = -1
        for actionType in ActionType.allCases {
            actionBtnXOffset += 1
            let btn = SKSpriteNode()
            btn.zPosition = 1
            let btnCount = ActionType.allCases.count
            btn.position.x = (CGFloat(actionBtnXOffset) - CGFloat(btnCount - 1) * 0.5) * btnInterval
            btn.alpha = btnAlpha
            
            let imgName = actionType.rawValue
            btn.texture = SKTexture(imageNamed: imgName)
            
            btn.size = btnSize
            btn.name = imgName
            actionBtnSet.addChild(btn)
            actionBtnSet.position = actionBtnPosition
        }
    }
}
